import 'package:flow/core/money/money_core.dart';
import 'package:flow/features/catalog/domain/price_selector.dart';
import 'package:flow/features/catalog/domain/price_tier.dart';
import 'package:flutter_test/flutter_test.dart';

/// Price selection is pure arithmetic, so these tests need no database: the bands
/// are just a list of [TierPrice] values (`P2-04`).
void main() {
  const Money fallback = Money.fromMinor(1850, Currency.egp);
  const Money retailBulk = Money.fromMinor(1700, Currency.egp);
  const Money wholesaleOne = Money.fromMinor(1500, Currency.egp);
  const Money wholesaleBulk = Money.fromMinor(1350, Currency.egp);
  final DateTime createdAt = DateTime.utc(2026, 5, 1);

  TierPrice band({
    required String id,
    required PriceTier tier,
    required int startUnits,
    required Money price,
    DateTime? disabledAt,
  }) => TierPrice(
    id: id,
    productId: 'p1',
    tier: tier,
    price: price,
    minQuantity: Quantity.units(startUnits),
    createdAt: createdAt,
    disabledAt: disabledAt,
  );

  /// The shop the acceptance criterion describes: retail from one and from a
  /// hundred, wholesale from a dozen and from a hundred.
  final List<TierPrice> shop = <TierPrice>[
    band(id: 'r1', tier: PriceTier.retail, startUnits: 1, price: fallback),
    band(id: 'r2', tier: PriceTier.retail, startUnits: 100, price: retailBulk),
    band(
      id: 'w1',
      tier: PriceTier.wholesale,
      startUnits: 12,
      price: wholesaleOne,
    ),
    band(
      id: 'w2',
      tier: PriceTier.wholesale,
      startUnits: 100,
      price: wholesaleBulk,
    ),
  ];

  Money select(PriceTier tier, int units, {List<TierPrice>? tiers}) =>
      PriceSelector.select(
        tiers: tiers ?? shop,
        tier: tier,
        quantity: Quantity.units(units),
        fallback: fallback,
      );

  test('the acceptance case: a single piece sells at the retail price', () {
    expect(select(PriceTier.retail, 1), fallback);
  });

  test('the tightest band the quantity reaches wins', () {
    // A hundred pieces reach both retail bands; the tighter one prices them.
    expect(select(PriceTier.retail, 100), retailBulk);
  });

  test('a quantity between two bands keeps the looser one', () {
    // Fifty pieces do not reach the hundred band, so the first one still applies.
    expect(select(PriceTier.retail, 50), fallback);
  });

  test('the wholesale band applies from the dozen it starts at', () {
    expect(select(PriceTier.wholesale, 12), wholesaleOne);
    expect(select(PriceTier.wholesale, 99), wholesaleOne);
    expect(select(PriceTier.wholesale, 100), wholesaleBulk);
  });

  test('a quantity below the smallest band falls back to the product price', () {
    // Three pieces when wholesale starts at twelve: the retail price, not free.
    expect(select(PriceTier.wholesale, 3), fallback);
  });

  test('another tier never prices the sale', () {
    final List<TierPrice> onlyWholesale = <TierPrice>[shop[2]];

    expect(select(PriceTier.retail, 5, tiers: onlyWholesale), fallback);
  });

  test('a retired band never prices anything new', () {
    final List<TierPrice> retired = <TierPrice>[
      band(
        id: 'w1',
        tier: PriceTier.wholesale,
        startUnits: 12,
        price: wholesaleOne,
        disabledAt: DateTime.utc(2026, 6, 1),
      ),
    ];

    expect(select(PriceTier.wholesale, 50, tiers: retired), fallback);
  });

  test('an empty catalogue falls back to the product price', () {
    expect(select(PriceTier.retail, 5, tiers: <TierPrice>[]), fallback);
  });

  test('the answer does not depend on the order the bands arrive in', () {
    final List<TierPrice> reversed = shop.reversed.toList();

    expect(select(PriceTier.wholesale, 100, tiers: reversed), wholesaleBulk);
    expect(select(PriceTier.retail, 50, tiers: reversed), fallback);
  });

  test('a weighted product can start a band between whole units', () {
    final List<TierPrice> weighted = <TierPrice>[
      band(id: 'w1', tier: PriceTier.wholesale, startUnits: 1, price: fallback),
      TierPrice(
        id: 'w2',
        productId: 'p1',
        tier: PriceTier.wholesale,
        price: wholesaleBulk,
        minQuantity: const Quantity.thousandths(2500),
        createdAt: createdAt,
      ),
    ];

    expect(select(PriceTier.wholesale, 2, tiers: weighted), fallback);
    expect(
      PriceSelector.select(
        tiers: weighted,
        tier: PriceTier.wholesale,
        quantity: const Quantity.thousandths(2500),
        fallback: fallback,
      ),
      wholesaleBulk,
    );
  });
}
