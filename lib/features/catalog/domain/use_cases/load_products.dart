import 'package:flow/core/result/result.dart';

import '../product.dart';
import '../product_repository.dart';

/// Reads every product (`P2-02`).
///
/// A read-only use case: it changes nothing, so it records no audit entry.
final class LoadProducts {
  /// Creates the use case.
  const LoadProducts(this._repository);

  final ProductRepository _repository;

  /// Executes the use case.
  Future<Result<List<Product>>> call() => _repository.readAll();
}
