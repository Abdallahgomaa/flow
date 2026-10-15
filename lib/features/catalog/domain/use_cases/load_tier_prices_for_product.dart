import 'package:flow/core/result/result.dart';

import '../price_tier.dart';
import '../tier_price_repository.dart';

/// Reads every price band of one product (`P2-04`).
///
/// A read-only use case: it changes nothing, so it records no audit entry.
final class LoadTierPricesForProduct {
  /// Creates the use case.
  const LoadTierPricesForProduct(this._repository);

  final TierPriceRepository _repository;

  /// Executes the use case.
  Future<Result<List<TierPrice>>> call(String productId) =>
      _repository.readForProduct(productId.trim());
}
