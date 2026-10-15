import 'package:flow/core/result/result.dart';

import 'product_search.dart';

/// The door to the catalogue's search index (interface first, rule 9).
///
/// Search never writes business data, so nothing here is audited: the index is
/// derived from `products`, and a rebuild recreates a view of rows that already
/// exist rather than changing one of them.
abstract interface class ProductSearchRepository {
  /// Finds products whose name or barcode matches [term].
  ///
  /// Returns at most [limit] products, continuing after [after] when it is
  /// given, together with the cursor of the following page — or `null` in
  /// [ProductSearchPage.next] when this was the last page.
  Future<Result<ProductSearchPage>> search({
    required String term,
    required int limit,
    ProductSearchCursor? after,
  });

  /// Rebuilds the index from `products` from scratch.
  ///
  /// An index is derived state, so it has to be repairable: this is the way back
  /// from a database whose index was damaged, or restored from a backup that
  /// carried only the product rows, and it is also what makes a fallback
  /// implementation (a plain scan) a choice the caller can leave behind instead
  /// of a permanent fork.
  Future<Result<void>> rebuild();
}
