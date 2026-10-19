import 'package:flow/core/result/result.dart';

import '../product_search.dart';
import '../product_search_repository.dart';

/// Finds products by name or by barcode (`P2-06`).
///
/// The term is trimmed once, here, for the same reason `BarcodeValidation`
/// trims a scanned code: a scanner's newline must not be the difference between
/// finding a product and not finding it.
///
/// Searching for nothing is answered without touching the database at all — an
/// empty catalogue query is a round trip whose answer is already known — and the
/// page size is bounded so a caller cannot accidentally ask for the whole
/// catalogue in one page.
///
/// A read-only use case: it changes nothing, so it records no audit entry.
final class SearchProducts {
  /// Creates the use case.
  const SearchProducts(this._repository);

  final ProductSearchRepository _repository;

  /// How many products a page holds unless the caller asks for another size.
  static const int defaultLimit = 20;

  /// The largest page a caller may ask for.
  ///
  /// The index answers in well under a frame either way; the bound exists so one
  /// scroll cannot pull an unbounded number of rows into memory.
  static const int maxLimit = 50;

  /// Executes the use case.
  Future<Result<ProductSearchPage>> call({
    required String term,
    int limit = defaultLimit,
    ProductSearchCursor? after,
  }) async {
    final String trimmed = term.trim();
    if (trimmed.isEmpty) {
      return const Result<ProductSearchPage>.ok(ProductSearchPage.empty);
    }

    final int size = limit < 1 ? 1 : (limit > maxLimit ? maxLimit : limit);

    return _repository.search(term: trimmed, limit: size, after: after);
  }
}
