import 'package:flow/core/result/failure.dart';
import 'package:flow/core/result/result.dart';

import '../barcode_repository.dart';
import '../barcode_validation.dart';

/// Retires a scannable label (`P2-03`).
///
/// The row stays in the database, because documents already issued against it
/// must keep resolving; it is stamped `disabled_at` and stops resolving new
/// scans (binding rule 4).
final class DisableBarcode {
  /// Creates the use case.
  const DisableBarcode(this._repository);

  final BarcodeRepository _repository;

  /// The audit action recorded for a retired label.
  static const String auditAction = 'barcode.disabled';

  /// Executes the use case.
  Future<Result<void>> call(String id) async {
    final Failure? invalid = BarcodeValidation.validateId(id);
    if (invalid != null) {
      return Result<void>.err(invalid);
    }
    return _repository.disable(id: id.trim(), action: auditAction);
  }
}
