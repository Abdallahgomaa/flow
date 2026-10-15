import 'package:flow/core/result/result.dart';

import '../product_search_repository.dart';

/// Rebuilds the catalogue's search index (`P2-06`).
///
/// An index is derived state: it exists to answer quickly, and everything in it
/// can be recomputed from `products`. This use case is therefore the repair
/// path — for an index damaged by an interrupted write, and for a database
/// restored from a backup that carried the products but not the index.
///
/// It writes no business data, so it records no audit entry: the audit log
/// answers «who changed what», and this changes nothing that anybody owns.
final class RebuildProductSearchIndex {
  /// Creates the use case.
  const RebuildProductSearchIndex(this._repository);

  final ProductSearchRepository _repository;

  /// Executes the use case.
  Future<Result<void>> call() => _repository.rebuild();
}
