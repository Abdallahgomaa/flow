import 'package:flow/core/result/result.dart';

import '../barcode.dart';
import '../barcode_repository.dart';

/// Reads every label of one product (`P2-03`).
///
/// A read-only use case: it changes nothing, so it records no audit entry.
final class LoadBarcodesForProduct {
  /// Creates the use case.
  const LoadBarcodesForProduct(this._repository);

  final BarcodeRepository _repository;

  /// Executes the use case.
  Future<Result<List<Barcode>>> call(String productId) =>
      _repository.readForProduct(productId.trim());
}
