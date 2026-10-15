import 'package:flow/core/result/result.dart';

import '../barcode.dart';
import '../barcode_repository.dart';
import '../barcode_validation.dart';

/// Resolves a scanned code to its label (`P2-03`).
///
/// This is the scan path, and it is also what turns a duplicate rejection into
/// an answer: when `CreateBarcode` fails with
/// [BarcodeRepository.alreadyLinkedCode], the caller runs this use case with the
/// same code and reaches the product that already owns it (FR-INV-011).
///
/// A read-only use case: it changes nothing, so it records no audit entry.
final class FindBarcodeByCode {
  /// Creates the use case.
  const FindBarcodeByCode(this._repository);

  final BarcodeRepository _repository;

  /// Executes the use case.
  Future<Result<Barcode>> call(String code) =>
      _repository.readByCode(BarcodeValidation.normaliseCode(code));
}
