import 'package:flow/core/money/money_core.dart';
import 'package:flow/features/catalog/domain/product.dart';
import 'package:flow/features/catalog/domain/product_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final DateTime createdAt = DateTime.utc(2026, 5, 1);

  Product product({
    Money? salePrice,
    Money? costPrice,
    String? categoryId,
    String? purchaseUnitCode,
    DateTime? disabledAt,
  }) => Product(
    id: 'p1',
    name: 'Milk',
    type: ProductType.weighted,
    stockUnitCode: 'piece',
    salePrice: salePrice ?? const Money.fromMinor(1850, Currency.egp),
    createdAt: createdAt,
    categoryId: categoryId,
    purchaseUnitCode: purchaseUnitCode,
    costPrice: costPrice,
    disabledAt: disabledAt,
  );

  group('Product.toAuditPayload', () {
    test('carries the identity and the classification, not the prices', () {
      final Product value = product(categoryId: 'dairy');

      expect(value.toAuditPayload(), <String, Object?>{
        'id': 'p1',
        'type': 'weighted',
        'stockUnitCode': 'piece',
        'categoryId': 'dairy',
      });
    });

    test('omits the optional references when they are unset', () {
      expect(product().toAuditPayload(), <String, Object?>{
        'id': 'p1',
        'type': 'weighted',
        'stockUnitCode': 'piece',
      });
    });
  });

  group('Product.priceAuditPayload', () {
    test('a brand new product records both prices it was created with', () {
      final Product value = product(
        costPrice: const Money.fromMinor(1200, Currency.egp),
      );

      expect(value.priceAuditPayload(), <String, Object?>{
        'salePriceMinorUnits': 1850,
        'costPriceMinorUnits': 1200,
      });
    });

    test('a created product without a cost records only the sale price', () {
      expect(product().priceAuditPayload(), <String, Object?>{
        'salePriceMinorUnits': 1850,
      });
    });

    test('an edit that moves neither price records nothing', () {
      final Product before = product(
        costPrice: const Money.fromMinor(1200, Currency.egp),
      );
      final Product after = product(
        costPrice: const Money.fromMinor(1200, Currency.egp),
      );

      expect(after.priceAuditPayload(previous: before), isEmpty);
    });

    test('an edit records the sale price before and after', () {
      final Product before = product();
      final Product after = product(
        salePrice: const Money.fromMinor(2000, Currency.egp),
      );

      expect(after.priceAuditPayload(previous: before), <String, Object?>{
        'salePriceMinorUnitsBefore': 1850,
        'salePriceMinorUnitsAfter': 2000,
      });
    });

    test('an edit records a cost that was added', () {
      final Product before = product();
      final Product after = product(
        costPrice: const Money.fromMinor(900, Currency.egp),
      );

      expect(after.priceAuditPayload(previous: before), <String, Object?>{
        'costPriceMinorUnitsBefore': null,
        'costPriceMinorUnitsAfter': 900,
      });
    });

    test('an edit records a cost that was cleared', () {
      final Product before = product(
        costPrice: const Money.fromMinor(900, Currency.egp),
      );
      final Product after = product();

      expect(after.priceAuditPayload(previous: before), <String, Object?>{
        'costPriceMinorUnitsBefore': 900,
        'costPriceMinorUnitsAfter': null,
      });
    });

    test('an edit that moves both records both pairs', () {
      final Product before = product(
        costPrice: const Money.fromMinor(900, Currency.egp),
      );
      final Product after = product(
        salePrice: const Money.fromMinor(2000, Currency.egp),
        costPrice: const Money.fromMinor(950, Currency.egp),
      );

      expect(after.priceAuditPayload(previous: before), <String, Object?>{
        'salePriceMinorUnitsBefore': 1850,
        'salePriceMinorUnitsAfter': 2000,
        'costPriceMinorUnitsBefore': 900,
        'costPriceMinorUnitsAfter': 950,
      });
    });
  });

  group('Product', () {
    test('reports whether it has been retired', () {
      expect(product().isDisabled, isFalse);
      expect(product(disabledAt: DateTime.utc(2026, 5, 2)).isDisabled, isTrue);
    });

    test('two products are equal when every field matches', () {
      expect(product(), product());
    });

    test('two products that differ in price are not equal', () {
      expect(
        product(salePrice: const Money.fromMinor(2000, Currency.egp)),
        isNot(product()),
      );
    });
  });
}
