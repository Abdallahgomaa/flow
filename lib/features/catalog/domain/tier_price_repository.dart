import 'package:flow/core/result/result.dart';

import 'price_tier.dart';

/// The storage contract for price bands (`P2-04`).
///
/// The interface is pure Dart so use cases depend on the behaviour, never on
/// Drift; the Drift implementation lives in `data/`.
abstract interface class TierPriceRepository {
  /// Failure code: no band has that id.
  static const String notFoundCode = 'tierPrice.notFound';

  /// Failure code: the product a write names does not exist.
  static const String productNotFoundCode = 'tierPrice.productNotFound';

  /// Failure code: the product already prices that tier from that quantity.
  ///
  /// A second band at the same start quantity would leave the price decided by
  /// whichever row the database happened to return first, so it is refused. The
  /// caller can offer to edit the existing band instead, which it reaches through
  /// [readForProduct].
  static const String duplicateBandCode = 'tierPrice.duplicateBand';

  /// Every band of one product, retired ones included.
  ///
  /// Retired bands come back on purpose: the product screen greys them out and a
  /// historical sale must keep explaining the price it charged, so the caller —
  /// not the query — decides what still applies.
  Future<Result<List<TierPrice>>> readForProduct(String productId);

  /// One band by its identity, retired ones included.
  Future<Result<TierPrice>> readById(String id);

  /// Stores a new band.
  ///
  /// Every write here is one atomic, audited unit of work: the row change and its
  /// audit entry commit together, or not at all (AGENTS rule 3). Refuses with
  /// [duplicateBandCode] when the product already prices that tier from the same
  /// quantity — checked inside the transaction, with the table's `UNIQUE`
  /// constraint as the last line of defence.
  Future<Result<TierPrice>> create({
    required TierPrice tierPrice,
    required String action,
    Map<String, Object?> payload = const <String, Object?>{},
  });

  /// Overwrites an existing band.
  ///
  /// Returns [notFoundCode] when the row is gone, so two sessions editing the same
  /// band cannot silently resurrect a deleted one.
  Future<Result<TierPrice>> update({
    required TierPrice tierPrice,
    required String action,
    Map<String, Object?> payload = const <String, Object?>{},
  });

  /// Retires a band by stamping `disabled_at`.
  ///
  /// The row is kept, because the sales it priced must keep resolving; disabling
  /// an already retired band is a no-op that is not audited.
  Future<Result<void>> disable({
    required String id,
    required String action,
    Map<String, Object?> payload = const <String, Object?>{},
  });
}
