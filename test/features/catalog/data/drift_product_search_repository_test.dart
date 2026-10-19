// `isNull` is exported by both drift (an SQL expression) and flutter_test (a
// matcher); the tests mean the matcher, so drift's is hidden here.
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flow/core/database/database.dart';
import 'package:flow/core/result/result.dart';
import 'package:flow/core/utils/clock.dart';
import 'package:flow/core/utils/logger.dart';
import 'package:flow/features/catalog/data/drift_product_search_repository.dart';
import 'package:flow/features/catalog/domain/product_search.dart';
import 'package:flow/features/catalog/domain/use_cases/search_products.dart';
import 'package:flow/features/settings/data/drift_settings_repository.dart';
import 'package:flow/features/settings/domain/setting_keys.dart';
import 'package:flow/features/settings/domain/use_cases/load_business_profile.dart';
import 'package:flutter_test/flutter_test.dart';

/// Covers `P2-06`: the quick search, its keyset pages, the degraded path that
/// keeps search working without FTS5, and the latency the step is accepted on.
void main() {
  final DateTime createdAt = DateTime.utc(2026, 5, 1);

  late AppDatabase database;
  late DriftProductSearchRepository repository;
  late MemoryLogSink logSink;

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory(setup: DatabasePragmas.apply));
    final FixedClock clock = FixedClock(createdAt);
    final AuditService audit = AuditService(database: database, clock: clock);
    final DriftSettingsRepository settings = DriftSettingsRepository(
      database: database,
      unitOfWork: DriftUnitOfWork(database),
      auditService: audit,
      clock: clock,
    );
    repository = DriftProductSearchRepository(
      database: database,
      unitOfWork: DriftUnitOfWork(database),
      loadBusinessProfile: LoadBusinessProfile(settings),
    );
    // Prices are read in the shop's currency, so the profile has to exist
    // before a single hit is built.
    await settings.save(
      values: <String, String>{SettingKeys.currency: 'EGP'},
      action: 'settings.updated',
    );
    await database
        .into(database.units)
        .insert(
          UnitsCompanion.insert(
            code: 'piece',
            name: 'Piece',
            createdAt: createdAt,
          ),
        );
    // Capturing the log is what lets a test prove the indexed path was taken
    // and the silent fallback to a scan was not.
    logSink = MemoryLogSink();
    AppLogger.configure(level: LogLevel.debug, sinks: <LogSink>[logSink]);
  });

  tearDown(() async {
    AppLogger.reset();
    await database.close();
  });

  Future<void> addProduct({
    required String id,
    required String name,
    DateTime? disabledAt,
  }) => database
      .into(database.products)
      .insert(
        ProductsCompanion.insert(
          id: id,
          name: name,
          type: 'simple',
          stockUnitCode: 'piece',
          salePriceMinorUnits: 1850,
          createdAt: createdAt,
          disabledAt: Value<DateTime?>(disabledAt),
        ),
      );

  Future<void> addBarcode({
    required String id,
    required String productId,
    required String code,
    DateTime? disabledAt,
  }) => database
      .into(database.barcodes)
      .insert(
        BarcodesCompanion.insert(
          id: id,
          productId: productId,
          code: code,
          createdAt: createdAt,
          disabledAt: Value<DateTime?>(disabledAt),
        ),
      );

  Future<Result<ProductSearchPage>> search(
    String term, {
    int limit = SearchProducts.defaultLimit,
    ProductSearchCursor? after,
  }) => repository.search(term: term, limit: limit, after: after);

  /// Every record at or above a warning — the only ones a search should ever
  /// add while the index is healthy.
  List<LogRecord> warnings() => logSink.records
      .where(
        (LogRecord record) =>
            record.level.developerLevel >= LogLevel.warning.developerLevel,
      )
      .toList(growable: false);

  List<String> namesOf(ProductSearchPage page) => <String>[
    for (final ProductSearchHit hit in page.hits) hit.product.name,
  ];

  List<String> idsOf(ProductSearchPage page) => <String>[
    for (final ProductSearchHit hit in page.hits) hit.product.id,
  ];

  group('name search', () {
    test('finds every product whose name carries the term', () async {
      await addProduct(id: 'p1', name: 'Milk');
      await addProduct(id: 'p2', name: 'Bread');
      await addProduct(id: 'p3', name: 'Whole Milk');

      final Result<ProductSearchPage> result = await search('milk');

      expect(result.isOk, isTrue);
      // Ordered by (name, id): the order every page of the walk depends on.
      expect(namesOf(result.valueOrNull!), <String>['Milk', 'Whole Milk']);
      expect(result.valueOrNull!.next, isNull);
    });

    test('matches a prefix of every word, not only of the last', () async {
      await addProduct(id: 'p1', name: 'Whole Milk');
      await addProduct(id: 'p2', name: 'Milk Powder');

      final Result<ProductSearchPage> whole = await search('whole mi');
      final Result<ProductSearchPage> split = await search('whol mil');

      expect(namesOf(whole.valueOrNull!), <String>['Whole Milk']);
      expect(namesOf(split.valueOrNull!), <String>['Whole Milk']);
    });

    test('matches an Arabic name', () async {
      await addProduct(id: 'p1', name: 'حليب كامل الدسم');
      await addProduct(id: 'p2', name: 'خبز أسمر');

      final Result<ProductSearchPage> result = await search('حليب');

      expect(result.isOk, isTrue);
      expect(idsOf(result.valueOrNull!), <String>['p1']);
    });

    test('keeps punctuation out of the tokenizer grammar', () async {
      await addProduct(id: 'p1', name: 'Milk (500 ml)');
      await addProduct(id: 'p2', name: 'Cola - 1 L');

      final Result<ProductSearchPage> quoted = await search('milk (500');
      final Result<ProductSearchPage> dash = await search('cola -');
      final Result<ProductSearchPage> nothing = await search('---');

      expect(idsOf(quoted.valueOrNull!), <String>['p1']);
      expect(dash.isOk, isTrue);
      // A term holding no word at all cannot reach the FTS grammar: it is
      // answered by the scan instead of becoming a syntax error.
      expect(nothing.valueOrNull!.isEmpty, isTrue);
      expect(warnings(), isEmpty);
    });

    test('still returns a product that was retired', () async {
      await addProduct(id: 'p1', name: 'Retired Milk', disabledAt: createdAt);

      final Result<ProductSearchPage> result = await search('retired');

      expect(idsOf(result.valueOrNull!), <String>['p1']);
    });
  });

  group('barcode search', () {
    test('finds a product by a scanned code', () async {
      await addProduct(id: 'p1', name: 'Chocolate');
      await addBarcode(id: 'b1', productId: 'p1', code: '6221000000001');

      final Result<ProductSearchPage> result = await search('6221000000001');

      expect(idsOf(result.valueOrNull!), <String>['p1']);
      expect(result.valueOrNull!.hits.single.barcode, '6221000000001');
    });

    test('finds a product by a prefix of a code', () async {
      await addProduct(id: 'p1', name: 'Chocolate');
      await addBarcode(id: 'b1', productId: 'p1', code: '6221000000001');

      final Result<ProductSearchPage> result = await search('62210');

      expect(idsOf(result.valueOrNull!), <String>['p1']);
      expect(result.valueOrNull!.hits.single.barcode, '6221000000001');
    });

    test('reports one label for a product carrying several', () async {
      await addProduct(id: 'p1', name: 'Chocolate');
      await addBarcode(id: 'b1', productId: 'p1', code: '11112');
      await addBarcode(id: 'b2', productId: 'p1', code: '11111');

      final Result<ProductSearchPage> result = await search('1111');

      // One row per product whatever its label count: the reported barcode is
      // the first one in range, never a row per match.
      expect(idsOf(result.valueOrNull!), <String>['p1']);
      expect(result.valueOrNull!.hits.single.barcode, '11111');
    });

    test('ignores a retired label', () async {
      await addProduct(id: 'p1', name: 'Chocolate');
      await addBarcode(
        id: 'b1',
        productId: 'p1',
        code: '6221000000001',
        disabledAt: createdAt,
      );

      final Result<ProductSearchPage> result = await search('6221000000001');

      // The barcode branch only answers for live labels, so a barcode search
      // and a scanner always agree.
      expect(result.valueOrNull!.isEmpty, isTrue);
    });
  });

  group('keyset paging', () {
    /// Twelve numbered rows plus two sharing a name, so the cursor's id
    /// tie-break is exercised rather than assumed.
    const int total = 14;
    const String term = 'item';

    Future<void> seedCatalogue() async {
      for (int index = 1; index <= 12; index++) {
        final String number = index.toString().padLeft(2, '0');
        await addProduct(id: 'item-$number', name: 'Item $number');
      }
      await addProduct(id: 'twin-a', name: 'Item Twin');
      await addProduct(id: 'twin-b', name: 'Item Twin');
    }

    Future<List<String>> walk(int pageSize) async {
      final List<String> seen = <String>[];
      ProductSearchCursor? after;
      int pages = 0;
      do {
        final Result<ProductSearchPage> result = await search(
          term,
          limit: pageSize,
          after: after,
        );
        expect(result.isOk, isTrue);
        final ProductSearchPage value = result.valueOrNull!;
        seen.addAll(idsOf(value));
        after = value.next;
        pages++;
      } while (after != null && pages < 20);
      expect(after, isNull, reason: 'the walk never reached its last page');
      return seen;
    }

    test('returns every row exactly once, in a total order', () async {
      await seedCatalogue();

      final List<String> seen = await walk(5);

      expect(seen, hasLength(total));
      expect(seen.toSet(), hasLength(total), reason: 'a row was repeated');
      expect(seen, <String>[
        for (int index = 1; index <= 12; index++)
          'item-${index.toString().padLeft(2, '0')}',
        'twin-a',
        'twin-b',
      ]);
    });

    test('is not shifted by a product inserted before the cursor', () async {
      await seedCatalogue();

      final Result<ProductSearchPage> first = await search(term, limit: 5);
      expect(first.isOk, isTrue);
      expect(idsOf(first.valueOrNull!), <String>[
        'item-01',
        'item-02',
        'item-03',
        'item-04',
        'item-05',
      ]);

      // A product sorting ahead of the cursor: an offset would push every
      // later row down by one and drop the last off the end of the walk. A
      // keyset continuation never sees it.
      await addProduct(id: 'item-00', name: 'Item 00');

      final List<String> seen = <String>[...idsOf(first.valueOrNull!)];
      ProductSearchCursor? after = first.valueOrNull!.next;
      int pages = 0;
      while (after != null && pages < 20) {
        final Result<ProductSearchPage> result = await search(
          term,
          limit: 5,
          after: after,
        );
        expect(result.isOk, isTrue);
        final ProductSearchPage value = result.valueOrNull!;
        seen.addAll(idsOf(value));
        after = value.next;
        pages++;
      }

      expect(after, isNull, reason: 'the walk never reached its last page');
      expect(seen, hasLength(total));
      expect(seen.toSet(), hasLength(total), reason: 'a row was dropped');
      expect(seen, isNot(contains('item-00')));
    });

    test('bounds the page and reports where the next one starts', () async {
      await seedCatalogue();

      final Result<ProductSearchPage> first = await search(term, limit: 3);

      expect(first.isOk, isTrue);
      expect(first.valueOrNull!.hits, hasLength(3));
      expect(
        first.valueOrNull!.next,
        const ProductSearchCursor(name: 'Item 03', id: 'item-03'),
      );
    });

    test('answers a term nobody typed without touching the database', () async {
      await addProduct(id: 'p1', name: 'Milk');

      final Result<ProductSearchPage> blank = await search('   ');
      final Result<ProductSearchPage> none = await search('milk', limit: 0);

      expect(blank.valueOrNull, ProductSearchPage.empty);
      expect(none.valueOrNull, ProductSearchPage.empty);
      expect(warnings(), isEmpty);
    });
  });

  group('degraded index', () {
    test('falls back to a name scan when the index is missing', () async {
      await addProduct(id: 'p1', name: 'Milk');
      await addProduct(id: 'p2', name: 'Whole Milk');
      await addProduct(id: 'p3', name: 'Bread');
      await database.customStatement('DROP TABLE product_search');

      final Result<ProductSearchPage> byName = await search('milk');
      final Result<ProductSearchPage> paged = await search('milk', limit: 1);

      // Same results, same order, same cursor — only the path differs.
      expect(byName.isOk, isTrue);
      expect(namesOf(byName.valueOrNull!), <String>['Milk', 'Whole Milk']);
      expect(paged.valueOrNull!.hits, hasLength(1));
      // The cursor points at the last row the page returned, not at the extra
      // row the page read to discover that another one follows.
      expect(
        paged.valueOrNull!.next,
        const ProductSearchCursor(name: 'Milk', id: 'p1'),
      );
      expect(warnings(), isNotEmpty, reason: 'the degradation was not logged');
    });

    test('rebuild repairs a dropped index', () async {
      await addProduct(id: 'p1', name: 'Milk');
      await addProduct(id: 'p2', name: 'Whole Milk');
      await database.customStatement('DROP TABLE product_search');
      logSink.clear();

      final Result<void> rebuilt = await repository.rebuild();
      final int indexed = await database
          .customSelect('SELECT count(*) AS c FROM product_search')
          .getSingle()
          .then((QueryRow row) => row.read<int>('c'));
      final Result<ProductSearchPage> result = await search('milk');

      expect(rebuilt.isOk, isTrue);
      expect(indexed, 2, reason: 'every product must be back in the index');
      expect(namesOf(result.valueOrNull!), <String>['Milk', 'Whole Milk']);
      expect(
        warnings(),
        isEmpty,
        reason: 'a rebuilt index must put search back on its fast path',
      );
    });
  });

  group('index grammar', () {
    test('never falls back while the index is healthy', () async {
      await addProduct(id: 'p1', name: 'Whole Milk');
      await addProduct(id: 'p2', name: 'حليب كامل الدسم');
      await addBarcode(id: 'b1', productId: 'p1', code: '6221000000001');

      await search('milk');
      await search('whole mi');
      await search('حليب');
      await search('milk (500 ml)');
      await search('6221000000001');
      await search('---');

      expect(
        warnings(),
        isEmpty,
        reason:
            'a syntax problem in the MATCH expression shows itself only '
            'as the silent fallback this asserts against',
      );
    });
  });

  group('latency', () {
    test('answers in under 100 ms over 50 000 products', () async {
      const int productCount = 50000;

      // One batch, one transaction: seeding is a means to the measurement,
      // and 50 000 separate statements would dominate the clock. The
      // products carry their labels so the barcode branch is measured over
      // a populated unique index rather than an empty one.
      await database.batch((Batch batch) {
        batch.insertAll(database.products, <ProductsCompanion>[
          for (int index = 0; index < productCount; index++)
            ProductsCompanion.insert(
              id: 'p${index.toString().padLeft(6, '0')}',
              name: index % 1000 == 0 ? 'Milk Batch $index' : 'Product $index',
              type: 'simple',
              stockUnitCode: 'piece',
              salePriceMinorUnits: 1000 + index,
              createdAt: createdAt,
            ),
        ]);
        batch.insertAll(database.barcodes, <BarcodesCompanion>[
          for (int index = 0; index < productCount; index++)
            BarcodesCompanion.insert(
              id: 'b${index.toString().padLeft(6, '0')}',
              productId: 'p${index.toString().padLeft(6, '0')}',
              code: '2${index.toString().padLeft(12, '0')}',
              createdAt: createdAt,
            ),
        ]);
      });

      final SearchProducts searchProducts = SearchProducts(repository);
      // Warms the statement and the index so what is measured is the search
      // a user runs, not the first compilation of its SQL.
      await searchProducts(term: 'Milk Batch 0');

      final Map<String, int> measured = <String, int>{};
      // The barcode term is the code the seeding above gave product 42, built
      // the same way, so the scan is measured against a label that exists.
      final List<MapEntry<String, String>> queries = <MapEntry<String, String>>[
        const MapEntry<String, String>('broad name', 'prod'),
        const MapEntry<String, String>('specific name', 'Milk Batch 42000'),
        MapEntry<String, String>(
          'barcode scan',
          '2${42.toString().padLeft(12, '0')}',
        ),
      ];
      for (final MapEntry<String, String> query in queries) {
        final Stopwatch watch = Stopwatch()..start();
        final Result<ProductSearchPage> result = await searchProducts(
          term: query.value,
        );
        watch.stop();

        expect(result.isOk, isTrue, reason: query.key);
        expect(
          watch.elapsedMilliseconds,
          lessThan(100),
          reason: '${query.key} took ${watch.elapsedMilliseconds} ms',
        );
        measured[query.key] = watch.elapsedMilliseconds;
      }

      // The acceptance is a number, so the number is written to the log
      // instead of being left implicit in a passing assertion.
      final String report = measured.entries
          .map(
            (MapEntry<String, int> entry) => '${entry.key}=${entry.value} ms',
          )
          .join(', ');
      AppLogger.instance.info(
        'search latency over $productCount products: $report',
        name: 'test.p2_06',
      );
      expect(
        logSink.records.any(
          (LogRecord record) => record.message.contains('ms'),
        ),
        isTrue,
      );
    }, timeout: const Timeout(Duration(minutes: 3)));
  });
}
