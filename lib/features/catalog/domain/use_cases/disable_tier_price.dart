import 'package:flow/core/result/failure.dart';
import 'package:flow/core/result/result.dart';

import '../price_tier_validation.dart';
import '../tier_price_repository.dart';

/// Retires a price band (`P2-04`).
///
/// The row stays in the database, because the sales it priced must keep
/// resolving; it is stamped `disabled_at` and stops pricing anything new
/// (binding rule 4).
final class DisableTierPrice {
  /// Creates the use case.
  const DisableTierPrice(this._repository);

  final TierPriceRepository _repository;

  /// The audit action recorded for a retired band.
  static const String auditAction = 'tierPrice.disabled';

  /// Executes the use case.
  Future<Result<void>> call(String id) async {
    final Failure? invalid = TierPriceValidation.validateId(id);
    if (invalid != null) {
      return Result<void>.err(invalid);
    }
    return _repository.disable(id: id.trim(), action: auditAction);
  }
}
