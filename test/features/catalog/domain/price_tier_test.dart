import 'package:flow/core/money/money_core.dart';
import 'package:flow/features/catalog/domain/price_tier.dart';
import 'package:flutter_test/flutter_test.dart';

/// Covers `P2-04`: the tier enum, the band entity, and the shape of the audit
/// entry a price change has to leave behind.
void main() {
  const Money price = Money.fromMinor(1850, Currency.egp);
  final DateTime createdAt = DateTime.utc(2026, 5, 1);

  TierPrice band({
    String id = 't1',
    String productId = 'p1',
    PriceTier tier = PriceTier.retail,
    Money? priceOverride,
    Quantity minQuantity = TierPrice.firstBandQuantity,
    DateTime? disabledAt,
  }) => TierPrice(
    id: id,
    productId: productId,
    tier: tier,
    price: priceOverride ?? price,
    minQuantity: minQuantity,
    createdAt: createdAt,
    disabledAt: disabledAt,
  );

  group('PriceTier', () {
    test('every tier carries a stable slug', () {
      expect(PriceTier.retail.code, 'retail');
      expect(PriceTier.wholesale.code, 'wholesale');
      expect(PriceTier.custom.code, 'custom');
    });

    test('resolves a stored slug back to its tier', () {
      expect(PriceTier.fromCode('wholesale'), PriceTier.wholesale);
      expect(PriceTier.fromCode('retail'), PriceTier.retail);
    });

    test('an unknown slug resolves to null instead of throwing', () {
      expect(PriceTier.fromCode('mystery'), isNull);
    });
  });

  group('TierPrice', () {
    test('the first band starts at one whole unit', () {
      expect(TierPrice.firstBandQuantity, const Quantity.thousandths(1000));
    });

    test('carries its identity and edge, not its price, in the payload', () {
      final TierPrice bulk = band(
        minQuantity: const Quantity.thousandths(12000),
      );

      expect(bulk.toAuditPayload(), <String, Object?>{
        'id': 't1',
        'productId': 'p1',
        'tier': 'retail',
        'minQuantityThousandths': 12000,
      });
    });

    test('a newly created band records its price outright', () {
      expect(band().priceAuditPayload(), <String, Object?>{
        'priceMinorUnits': 1850,
        'minQuantityThousandths': 1000,
      });
    });

    test('an edit records only the price that moved, before and after', () {
      final TierPrice after = band(
        priceOverride: const Money.fromMinor(2000, Currency.egp),
      );

      expect(after.priceAuditPayload(previous: band()), <String, Object?>{
        'priceMinorUnitsBefore': 1850,
        'priceMinorUnitsAfter': 2000,
      });
    });

    test('an edit records a moved band edge, before and after', () {
      final TierPrice after = band(
        minQuantity: const Quantity.thousandths(12000),
      );

      expect(after.priceAuditPayload(previous: band()), <String, Object?>{
        'minQuantityThousandthsBefore': 1000,
        'minQuantityThousandthsAfter': 12000,
      });
    });

    test('an edit that changed nothing leaves an empty payload', () {
      expect(band().priceAuditPayload(previous: band()), isEmpty);
    });

    test('reports whether it has been retired', () {
      expect(band().isDisabled, isFalse);
      expect(band(disabledAt: DateTime.utc(2026, 5, 2)).isDisabled, isTrue);
    });

    test('two bands are equal when every field matches', () {
      expect(band(), band());
    });

    test('bands that differ in price, tier or edge are not equal', () {
      expect(
        band(priceOverride: const Money.fromMinor(1, Currency.egp)),
        isNot(band()),
      );
      expect(band(tier: PriceTier.wholesale), isNot(band()));
      expect(
        band(minQuantity: const Quantity.thousandths(12000)),
        isNot(band()),
      );
    });
  });
}
