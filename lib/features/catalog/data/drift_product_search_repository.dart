import 'package:drift/drift.dart';
import 'package:flow/core/database/database.dart';
import 'package:flow/core/money/money_core.dart';
import 'package:flow/core/result/failure.dart';
import 'package:flow/core/result/result.dart';
import 'package:flow/core/utils/logger.dart';
import 'package:flow/features/settings/domain/business_profile.dart';
import 'package:flow/features/settings/domain/use_cases/load_business_profile.dart';

import '../domain/product.dart';
import '../domain/product_search.dart';
import '../domain/product_search_repository.dart';
import 'drift_product_repository.dart';

/// Drift-backed [ProductSearchRepository] (`P2-06`).
///
/// Two things define this class:
///
/// * **Ordering is keyset, never `OFFSET`.** Every page continues from the pair
///   `(name, id)` of the previous one. That pair is a total order, so a page
///   boundary cannot duplicate a row and cannot drop one — even while products
///   are being inserted between two pages. An offset would shift every later
///   row the moment something was added near the front of the alphabet, which
///   is exactly the bug the acceptance of this step forbids.
/// * **The index is derived state.** It is rebuilt from `products`, never
///   written as a business fact, so this repository appends no audit entry and
///   keeps no clock: [rebuild] restores a view of rows that already exist.
///
/// The name search runs on the `product_search` FTS5 table when the platform
/// ships one (`docs/P0-11_sqlite_spike.md`, decision 1). When that query cannot
/// be built or executed — an FTS5-less SQLite, or a damaged index — the same
/// page semantics are answered by a `LIKE` scan, so search degrades in speed
/// but never in results. [rebuild] is the documented way back to the index.
///
/// Barcodes are deliberately *not* in the FTS index: they are matched through
/// the unique index on `barcodes.code` with a prefix range, which needs no
/// tokenizer and answers a scanned code exactly.
final class DriftProductSearchRepository implements ProductSearchRepository {
  /// Creates the repository over its injected collaborators.
  ///
  /// There is no [AuditService] and no [Clock] on purpose: reading a derived
  /// index changes nothing an audit row could explain.
  const DriftProductSearchRepository({
    required this.database,
    required this.unitOfWork,
    required this.loadBusinessProfile,
  });

  static const String _logName = 'catalog.product_search_repository';
  static const String _searchFailedMessage = 'Could not search the products.';
  static const String _rebuildFailedMessage =
      'Could not rebuild the search index.';

  /// Logged when the indexed query is abandoned in favour of the scan.
  static const String _fallbackNote =
      'The full-text index could not be queried; falling back to a name scan.';

  /// The largest Unicode code point, appended to a barcode term to turn it into
  /// an upper bound.
  ///
  /// `barcodes.code` is compared with the default `BINARY` collation, i.e. by
  /// UTF-8 bytes. Every valid UTF-8 string that *starts with* [term] therefore
  /// sorts at or below `term + this`, while an exact code sorts above `term`
  /// alone. One range (`code >= term AND code < term + ceiling`) covers both a
  /// scanned full code and every label that merely starts with it, and it stays
  /// a seek on the unique index instead of a `LIKE '%…%'` scan.
  static const String _prefixCeiling = '\u{10FFFF}';

  /// Reads a page through the full-text index.
  ///
  /// The barcode branch is an `IN` over the barcode index, not an `EXISTS`
  /// correlated per product: a scanned label has to be found by seeking the
  /// code index, and a per-row subquery would make the database read all 50 000
  /// products to answer a term only one of them carries. The same range is used
  /// to report *which* label matched, ordered and limited to one row, so a
  /// product carrying several matching labels still appears exactly once.
  static const String _indexedSearchSql = '''
SELECT
  p.id AS id,
  p.name AS name,
  (SELECT b.code FROM barcodes b
    WHERE b.product_id = p.id
      AND b.disabled_at IS NULL
      AND b.code >= ? AND b.code < ?
    ORDER BY b.code
    LIMIT 1) AS matched_barcode
FROM products p
WHERE (
  p.rowid IN (SELECT rowid FROM product_search WHERE product_search MATCH ?)
  OR p.id IN (
    SELECT b.product_id FROM barcodes b
    WHERE b.disabled_at IS NULL
      AND b.code >= ? AND b.code < ?
  )
)
AND (? IS NULL OR p.name > ? OR (p.name = ? AND p.id > ?))
ORDER BY p.name ASC, p.id ASC
LIMIT ?
''';

  /// Reads a page with a name scan, for platforms without a usable index.
  ///
  /// Everything but the name predicate is byte-for-byte the query above, so the
  /// two paths are held to one set of semantics: same ordering, same keyset
  /// continuation, same barcode handling, same "disabled products are still
  /// returned" contract that `readAll()` has.
  static const String _scanSearchSql = '''
SELECT
  p.id AS id,
  p.name AS name,
  (SELECT b.code FROM barcodes b
    WHERE b.product_id = p.id
      AND b.disabled_at IS NULL
      AND b.code >= ? AND b.code < ?
    ORDER BY b.code
    LIMIT 1) AS matched_barcode
FROM products p
WHERE (
  p.name LIKE ? ESCAPE '\\'
  OR p.id IN (
    SELECT b.product_id FROM barcodes b
    WHERE b.disabled_at IS NULL
      AND b.code >= ? AND b.code < ?
  )
)
AND (? IS NULL OR p.name > ? OR (p.name = ? AND p.id > ?))
ORDER BY p.name ASC, p.id ASC
LIMIT ?
''';

  /// A word is only worth sending to the tokenizer when it has one.
  ///
  /// Unicode's own letter/number classes are used rather than `[A-Za-z0-9]`
  /// because the catalogue is not Latin-only: Arabic product names must be
  /// indexed, and punctuation-only fragments (`---`, `**`) must not become an
  /// empty phrase that the FTS grammar could reject.
  static final RegExp _tokenCharacter = RegExp(r'[\p{L}\p{N}]', unicode: true);

  /// The database the catalogue tables live in.
  final AppDatabase database;

  /// Groups the rebuild's writes into one transaction.
  final UnitOfWork unitOfWork;

  /// Reads the shop profile, whose currency every price is expressed in.
  final LoadBusinessProfile loadBusinessProfile;

  @override
  Future<Result<ProductSearchPage>> search({
    required String term,
    required int limit,
    ProductSearchCursor? after,
  }) async {
    try {
      final String query = term.trim();
      // A page nobody asked for is answered without touching the database, so a
      // blank search box cannot turn into a full-table read.
      if (query.isEmpty || limit < 1) {
        return const Result<ProductSearchPage>.ok(ProductSearchPage.empty);
      }

      final String? match = _ftsMatch(query);
      List<QueryRow>? rows;
      if (match != null) {
        try {
          rows = await database
              .customSelect(
                _indexedSearchSql,
                variables: _searchVariables(
                  term: query,
                  namePredicate: match,
                  pageSize: limit,
                  after: after,
                ),
              )
              .get();
        } on Object catch (error, stackTrace) {
          // Degrade, never fail: P0-11 keeps the scan precisely so a platform
          // without FTS5 still answers the search box.
          AppLogger.instance.warning(
            _fallbackNote,
            name: _logName,
            error: error,
            stackTrace: stackTrace,
          );
        }
      }
      rows ??= await database
          .customSelect(
            _scanSearchSql,
            variables: _searchVariables(
              term: query,
              namePredicate: '%${_escapeLike(query)}%',
              pageSize: limit,
              after: after,
            ),
          )
          .get();

      // One row too many is how the page knows whether another one follows:
      // the extra row is dropped, never returned, and never counted.
      final bool hasMore = rows.length > limit;
      final List<QueryRow> pageRows = hasMore ? rows.sublist(0, limit) : rows;
      if (pageRows.isEmpty) {
        return const Result<ProductSearchPage>.ok(ProductSearchPage.empty);
      }

      // Only rows that will be shown need a price, so the currency is read
      // after the empty-page answer above rather than before it.
      final Result<Currency> currency = await _shopCurrency();
      final Currency? resolved = currency.valueOrNull;
      if (resolved == null) {
        return Result<ProductSearchPage>.err(currency.failureOrNull!);
      }

      final List<String> ids = <String>[
        for (final QueryRow row in pageRows) row.read<String>('id'),
      ];
      // The first query resolved *which* rows belong to the page; this typed
      // one fetches them again through drift's mapper, so price and type are
      // decoded once, by the same code the rest of the catalogue uses.
      final List<ProductRow> productRows =
          await (database.select(database.products)
                ..where(($ProductsTable table) => table.id.isIn(ids))
                ..orderBy(<OrderingTerm Function($ProductsTable)>[
                  ($ProductsTable table) => OrderingTerm.asc(table.name),
                  ($ProductsTable table) => OrderingTerm.asc(table.id),
                ]))
              .get();
      final Map<String, Product> productsById = <String, Product>{
        for (final ProductRow row in productRows)
          row.id: DriftProductRepository.productFromRow(row, resolved),
      };

      final List<ProductSearchHit> hits = <ProductSearchHit>[];
      for (final QueryRow row in pageRows) {
        final String id = row.read<String>('id');
        final Product? product = productsById[id];
        // A product disabled or deleted between the two reads is simply not
        // shown; the page must stay consistent with itself rather than crash.
        if (product == null) {
          continue;
        }
        hits.add(
          ProductSearchHit(
            product: product,
            barcode: row.readNullable<String>('matched_barcode'),
          ),
        );
      }

      // The cursor is taken from the raw page, not from the mapped hits, so it
      // still points past the last row this page asked for.
      final ProductSearchCursor? next = hasMore && hits.isNotEmpty
          ? ProductSearchCursor(
              name: pageRows.last.read<String>('name'),
              id: pageRows.last.read<String>('id'),
            )
          : null;
      return Result<ProductSearchPage>.ok(
        ProductSearchPage(hits: hits, next: next),
      );
    } on Object catch (error, stackTrace) {
      AppLogger.instance.error(
        'Failed to search the products',
        name: _logName,
        error: error,
        stackTrace: stackTrace,
      );
      return Result<ProductSearchPage>.err(
        StorageFailure(
          message: _searchFailedMessage,
          cause: error,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  @override
  Future<Result<void>> rebuild() async {
    try {
      final Failure? failure = await unitOfWork.run<Failure?>(() async {
        // `IF NOT EXISTS` is what makes this a repair as well as a rebuild: an
        // index that was dropped is recreated before it is filled.
        await database.customStatement(AppDatabase.productSearchDdl);
        await database.customStatement('DELETE FROM product_search');
        await database.customStatement(
          'INSERT INTO product_search(rowid, name) '
          'SELECT rowid, name FROM products',
        );
        return null;
      });
      if (failure != null) {
        return Result<void>.err(failure);
      }
      return const Result<void>.ok(null);
    } on Object catch (error, stackTrace) {
      AppLogger.instance.error(
        'Failed to rebuild the search index',
        name: _logName,
        error: error,
        stackTrace: stackTrace,
      );
      return Result<void>.err(
        StorageFailure(
          message: _rebuildFailedMessage,
          cause: error,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  /// Reads the shop currency, or the failure that stopped the settings read.
  ///
  /// The currency is read on every search for the same reason the product
  /// repository reads it on every read: changing it in the settings screen must
  /// change the prices this search reports, with no cache to invalidate.
  Future<Result<Currency>> _shopCurrency() async {
    final Result<BusinessProfile> profile = await loadBusinessProfile();
    return profile.map(DriftProductRepository.currencyFor);
  }

  /// Builds the FTS5 `MATCH` expression for [term], or `null` when [term]
  /// carries nothing a tokenizer could match.
  ///
  /// Each word becomes its own quoted phrase with a trailing `*`, so the search
  /// matches a **prefix of every word** (`mil` finds «Milk», `whole mi` finds
  /// «Whole Milk»). Quoting keeps the term out of FTS5's grammar — a name or a
  /// barcode may contain `"`, `-`, `:` or `(`, and those are data, not syntax —
  /// and the space between two phrases is FTS5's implicit `AND`, which is what
  /// makes a multi-word term narrow the results instead of widening them.
  static String? _ftsMatch(String term) {
    final List<String> words = term
        .split(RegExp(r'\s+'))
        .map((String word) => word.replaceAll('"', '').trim())
        .where(
          (String word) => word.isNotEmpty && _tokenCharacter.hasMatch(word),
        )
        .toList(growable: false);
    if (words.isEmpty) {
      return null;
    }
    return words.map((String word) => '"$word"*').join(' ');
  }

  /// The positional variables both page queries share, in order of appearance.
  ///
  /// The two queries differ only in their name predicate, so they share one
  /// binding list: [namePredicate] is either the FTS `MATCH` expression or the
  /// escaped `LIKE` pattern, whichever query is running. The four cursor
  /// variables bind SQL `NULL` when there is no cursor, which makes
  /// `? IS NULL` select the first page without a second query.
  static List<Variable<Object>> _searchVariables({
    required String term,
    required String namePredicate,
    required int pageSize,
    required ProductSearchCursor? after,
  }) {
    final String ceiling = term + _prefixCeiling;
    // A missing cursor is bound as SQL NULL, which is what lets one query serve
    // the first page and every later one: `? IS NULL` is true for the first.
    final Variable<Object> afterName = after == null
        ? const Variable<String>(null)
        : Variable<String>(after.name);
    final Variable<Object> afterId = after == null
        ? const Variable<String>(null)
        : Variable<String>(after.id);
    return <Variable<Object>>[
      Variable<String>(term),
      Variable<String>(ceiling),
      Variable<String>(namePredicate),
      Variable<String>(term),
      Variable<String>(ceiling),
      afterName,
      afterName,
      afterName,
      afterId,
      Variable<int>(pageSize + 1),
    ];
  }

  /// Escapes the three characters SQLite's `LIKE` treats as syntax so the term
  /// is matched literally.
  ///
  /// The backslash is escaped first: the escape character itself has to stop
  /// being an escape character before anything after it is rewritten.
  static String _escapeLike(String value) => value
      .replaceAll('\\', '\\\\')
      .replaceAll('%', '\\%')
      .replaceAll('_', '\\_');
}
