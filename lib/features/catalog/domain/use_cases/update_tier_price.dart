import 'package:flow/core/money/money_core.dart';
import 'package:flow/core/result/failure.dart';
import 'package:flow/core/result/result.dart';
import 'package:flow/core/utils/clock.dart';

import '../price_tier.dart';
import '../price_tier_validation.dart';
import '../tier_price_repository.dart';

/// Edits an existing price band (`P2-04`).
///
/// Identity is deliberately not taken from the caller: [id] selects the row and
/// `created_at` is carried over from the stored band, so an edit can never rewrite
/// when the band came into existence. `updated_at` is stamped here by the same
/// [Clock] that stamps every other write.
///
/// A band's product and tier are fixed after creation: moving a band to another
/// tier or another product is a different band, not an edit of this one, and
/// rewriting it in place would silently re-price history.
///
/// The stored row is also what makes the audit entry meaningful: the price fields
/// of the payload are built by comparing the new price with the previous one, so
/// the trail records a price change as a before/after pair.
final class UpdateTierPrice {
  /// Creates the use case.
  const UpdateTierPrice(this._repository, this._clock);

  final TierPriceRepository _repository;
  final Clock _clock;

  /// The audit action recorded for an edited band.
  static const String auditAction = 'tierPrice.updated';

  /// Executes the use case.
  ///
  /// [minQuantity] defaults to the band's current start quantity, so an edit that
  /// only touches the price leaves the edge where it was.
  Future<Result<TierPrice>> call({
    required String id,
    required Money price,
    Quantity? minQuantity,
  }) async {
    final Failure? invalidId = TierPriceValidation.validateId(id);
    if (invalidId != null) {
      return Result<TierPrice>.err(invalidId);
    }

    final Result<TierPrice> stored = await _repository.readById(id.trim());
    final TierPrice? previous = stored.valueOrNull;
    if (previous == null) {
      return Result<TierPrice>.err(stored.failureOrNull!);
    }

    final Quantity resolvedMinQuantity = minQuantity ?? previous.minQuantity;
    final Failure? invalid = TierPriceValidation.validate(
      productId: previous.productId,
      minQuantity: resolvedMinQuantity,
      price: price,
    );
    if (invalid != null) {
      return Result<TierPrice>.err(invalid);
    }

    final TierPrice tierPrice = TierPrice(
      id: previous.id,
      productId: previous.productId,
      tier: previous.tier,
      price: price,
      minQuantity: resolvedMinQuantity,
      createdAt: previous.createdAt,
      // Editing a band never re-enables it; only an explicit restore would, and
      // there is no such step yet.
      disabledAt: previous.disabledAt,
      updatedAt: _clock.nowUtc(),
    );

    return _repository.update(
      tierPrice: tierPrice,
      action: auditAction,
      payload: <String, Object?>{
        ...tierPrice.toAuditPayload(),
        ...tierPrice.priceAuditPayload(previous: previous),
      },
    );
  }
}
