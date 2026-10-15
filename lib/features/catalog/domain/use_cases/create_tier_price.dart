import 'package:flow/core/money/money_core.dart';
import 'package:flow/core/result/failure.dart';
import 'package:flow/core/result/result.dart';
import 'package:flow/core/utils/clock.dart';
import 'package:flow/core/utils/uuid_v7.dart';

import '../price_tier.dart';
import '../price_tier_validation.dart';
import '../tier_price_repository.dart';

/// Adds a price band to a product (`P2-04`).
///
/// Identity (`id`, `created_at`) is decided here rather than in the database
/// layer, so the same [Clock] that stamps the row also seeds the UUID v7 that
/// orders it (the rule the other catalogue use cases follow).
///
/// The use case takes raw fields, not a ready-made [TierPrice], because the caller
/// does not know the id or the creation time.
final class CreateTierPrice {
  /// Creates the use case.
  const CreateTierPrice(this._repository, this._idGenerator, this._clock);

  final TierPriceRepository _repository;
  final UuidV7Generator _idGenerator;
  final Clock _clock;

  /// The audit action recorded for a new band.
  static const String auditAction = 'tierPrice.created';

  /// Executes the use case.
  ///
  /// [minQuantity] defaults to the first whole unit, which is what an ordinary
  /// retail band starts at; a bulk band passes the quantity it begins at.
  Future<Result<TierPrice>> call({
    required String productId,
    required PriceTier tier,
    required Money price,
    Quantity minQuantity = TierPrice.firstBandQuantity,
  }) async {
    final Failure? invalid = TierPriceValidation.validate(
      productId: productId,
      minQuantity: minQuantity,
      price: price,
    );
    if (invalid != null) {
      return Result<TierPrice>.err(invalid);
    }

    final TierPrice tierPrice = TierPrice(
      id: _idGenerator.next(),
      productId: productId.trim(),
      tier: tier,
      price: price,
      minQuantity: minQuantity,
      createdAt: _clock.nowUtc(),
    );

    return _repository.create(
      tierPrice: tierPrice,
      action: auditAction,
      payload: <String, Object?>{
        ...tierPrice.toAuditPayload(),
        ...tierPrice.priceAuditPayload(),
      },
    );
  }
}
