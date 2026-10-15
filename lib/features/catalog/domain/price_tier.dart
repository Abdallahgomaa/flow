import 'package:flow/core/money/money_core.dart';

/// The tiers a product can be sold on (`P2-04`).
///
/// A shop charges one price to a walk-in customer and a lower one to the merchant
/// who takes a whole carton. Those are tiers, and each is stored as its stable
/// slug, never as an `index`, so reordering the list below cannot silently move
/// every stored band to another tier.
///
/// The PRD that names the tiers is not part of this repository, so the three
/// below are a deliberate derivation and stay provisional until they can be
/// checked against it (the project rule is never to guess silently). A fourth
/// tier is a schema-safe change: only this enum and its codes are involved.
enum PriceTier {
  /// The ordinary counter price (تجزئة).
  retail('retail'),

  /// The lower price for a customer buying in bulk (جملة).
  wholesale('wholesale'),

  /// A negotiated price for one customer or contract (مخصص).
  custom('custom');

  const PriceTier(this.code);

  /// The slug stored in the database.
  final String code;

  /// Resolves a stored [code] back to its tier, or `null` when it is unknown.
  ///
  /// A `null` means the row came from elsewhere (a hand-edited database, or a
  /// downgrade from a version that knew more tiers); the repository decides what
  /// to do about it at its own boundary rather than this enum guessing.
  static PriceTier? fromCode(String code) {
    for (final PriceTier tier in values) {
      if (tier.code == code) {
        return tier;
      }
    }
    return null;
  }
}

/// One price band of one product (`P2-04`).
///
/// A band says «from [minQuantity] units up, this product costs [price] when sold
/// on [tier]». A product may carry several bands of the same tier — a dozen is
/// cheaper than one, a gross cheaper still — and [PriceSelector] picks the
/// tightest one the sale quantity reaches.
///
/// [price] is [Money] and [minQuantity] is a [Quantity], never a `double` (AGENTS
/// rule 1). [price] carries the shop currency, but the currency is **not** stored
/// with the band: it is a single business setting, and duplicating it per row is
/// how the two would eventually disagree. The repository stamps the current shop
/// currency onto the stored minor units when it reads a band back.
final class TierPrice {
  /// Creates a price band.
  const TierPrice({
    required this.id,
    required this.productId,
    required this.tier,
    required this.price,
    required this.minQuantity,
    required this.createdAt,
    this.disabledAt,
    this.updatedAt,
  });

  /// What the ordinary, single-unit band starts at: one whole unit.
  ///
  /// It lives here so «a band from the first unit» has one definition instead of
  /// a literal `1000` scattered across the callers.
  static const Quantity firstBandQuantity = Quantity.thousandths(1000);

  /// Stable identifier (UUID v7), assigned by the creating use case.
  final String id;

  /// The product the band prices.
  final String productId;

  /// The tier the band belongs to.
  final PriceTier tier;

  /// The price per stock unit that applies from [minQuantity] up.
  final Money price;

  /// The quantity, in stock units, at which the band starts to apply.
  final Quantity minQuantity;

  /// When the band was retired (UTC), or `null` while it is offered.
  final DateTime? disabledAt;

  /// When the band was created (UTC).
  final DateTime createdAt;

  /// When the band was last modified (UTC), or `null` if never.
  final DateTime? updatedAt;

  /// Whether the band has been retired.
  bool get isDisabled => disabledAt != null;

  /// The fields worth recording in the audit trail.
  ///
  /// Quantities travel in their integer form because that is the number the row
  /// stores; a formatted decimal would be a second, lossier spelling of it.
  Map<String, Object?> toAuditPayload() => <String, Object?>{
    'id': id,
    'productId': productId,
    'tier': tier.code,
    'minQuantityThousandths': minQuantity.thousandths,
  };

  /// The price fields worth recording when a band is created or edited.
  ///
  /// On creation the price and the band edge are recorded outright. On an edit
  /// only the values that actually moved are recorded, as a before/after pair, so
  /// the trail reads as a price change instead of echoing the whole row.
  Map<String, Object?> priceAuditPayload({TierPrice? previous}) {
    if (previous == null) {
      return <String, Object?>{
        'priceMinorUnits': price.minorUnits,
        'minQuantityThousandths': minQuantity.thousandths,
      };
    }
    return <String, Object?>{
      if (previous.price != price) ...<String, Object?>{
        'priceMinorUnitsBefore': previous.price.minorUnits,
        'priceMinorUnitsAfter': price.minorUnits,
      },
      if (previous.minQuantity != minQuantity) ...<String, Object?>{
        'minQuantityThousandthsBefore': previous.minQuantity.thousandths,
        'minQuantityThousandthsAfter': minQuantity.thousandths,
      },
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TierPrice &&
          other.id == id &&
          other.productId == productId &&
          other.tier == tier &&
          other.price == price &&
          other.minQuantity == minQuantity &&
          other.disabledAt == disabledAt &&
          other.createdAt == createdAt &&
          other.updatedAt == updatedAt;

  @override
  int get hashCode => Object.hash(
    id,
    productId,
    tier,
    price,
    minQuantity,
    disabledAt,
    createdAt,
    updatedAt,
  );

  @override
  String toString() =>
      'TierPrice(id: $id, productId: $productId, tier: ${tier.code}, '
      'priceMinorUnits: ${price.minorUnits}, '
      'minQuantityThousandths: ${minQuantity.thousandths}, '
      'isDisabled: $isDisabled)';
}
