import 'package:flow/core/result/failure.dart';
import 'package:flow/core/result/result.dart';

import '../product_repository.dart';
import '../product_validation.dart';

/// Retires a product (`P2-02`).
///
/// The row stays in the database, because sale lines and stock movements point at
/// it and history must keep resolving; it is stamped `disabled_at` and
/// disappears from the selling screens (AGENTS rule 4).
final class DisableProduct {
  /// Creates the use case.
  const DisableProduct(this._repository);

  final ProductRepository _repository;

  /// The audit action recorded for a retired product.
  static const String auditAction = 'product.disabled';

  /// Executes the use case.
  Future<Result<void>> call(String id) async {
    final Failure? invalid = ProductValidation.validateId(id);
    if (invalid != null) {
      return Result<void>.err(invalid);
    }
    return _repository.disable(id: id.trim(), action: auditAction);
  }
}
