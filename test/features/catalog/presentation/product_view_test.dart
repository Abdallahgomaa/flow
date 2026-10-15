import 'package:flow/core/money/money_core.dart';
import 'package:flow/features/catalog/domain/price_tier.dart';
import 'package:flow/features/catalog/domain/product.dart';
import 'package:flow/features/catalog/domain/product_type.dart';
import 'package:flow/features/catalog/presentation/product_view.dart';
import 'package:flutter_test/flutter_test.dart';

/// The «بدون أسعار» rule, tested where it lives (`P2-05`).
///
/// The screens never check a permission to decide whether to draw a price:
/// [ProductView.from] and [TierPriceView.from] decide, once, by leaving the
/// money out of the object. These tests pin that decision, because every screen
/// test below depends on it and a single missed `showPrices` would leak a price
/// with no visible symptom in the widget tree.
void main() {
  final DateTime createdAt = DateTime.utc(2026, 5, 1);
  const Money price = Money.fromMinor(1850, Currency.usd);
  const Money cost = Money.fromMinor(1200, Currency.usd);
  final Quantity reorderLevel = Quantity.units(6);
  final Quantity bulkStart = Quantity.units(12);

  Product product() => Product(
    id: 'p1',
    name: 'Milk',
    type: ProductType.simple,
    stockUnitCode: 'piece',
    salePrice: price,
    createdAt: createdAt,
    categoryId: 'c1',
    costPrice: cost,
    reorderLevel: reorderLevel,
  );

  TierPrice band({DateTime? disabledAt}) => TierPrice(
    id: 'b1',
    productId: 'p1',
    tier: PriceTier.wholesale,
    price: price,
    minQuantity: bulkStart,
    createdAt: createdAt,
    disabledAt: disabledAt,
  );

  group('ProductView', () {
    test('carries the money when the role may see prices', () {
      final ProductView view = ProductView.from(
        product(),
        showPrices: true,
        categoryName: 'Drinks',
        stockUnitName: 'Piece',
      );

      expect(view.salePrice, price);
      expect(view.costPrice, cost);
      expect(view.showsPrices, isTrue);
      expect(view.id, 'p1');
      expect(view.name, 'Milk');
      expect(view.type, ProductType.simple);
      expect(view.categoryId, 'c1');
      expect(view.categoryName, 'Drinks');
      expect(view.stockUnitCode, 'piece');
      expect(view.stockUnitName, 'Piece');
      expect(view.isDisabled, isFalse);
    });

    test('drops the money entirely when the role may not see prices', () {
      final ProductView view = ProductView.from(product(), showPrices: false);

      expect(view.salePrice, isNull);
      expect(view.costPrice, isNull);
      expect(view.showsPrices, isFalse);
    });

    test('keeps what is not money, including the re-order level', () {
      final ProductView view = ProductView.from(product(), showPrices: false);

      expect(view.reorderLevel, reorderLevel);
      expect(view.name, 'Milk');
      expect(view.stockUnitCode, 'piece');
      expect(view.categoryId, 'c1');
    });
  });

  group('TierPriceView', () {
    test('carries the price when the role may see prices', () {
      final TierPriceView view = TierPriceView.from(band(), showPrices: true);

      expect(view.id, 'b1');
      expect(view.tier, PriceTier.wholesale);
      expect(view.minQuantity, bulkStart);
      expect(view.price, price);
      expect(view.isDisabled, isFalse);
    });

    test('drops the price when the role may not see prices', () {
      final TierPriceView view = TierPriceView.from(band(), showPrices: false);

      expect(view.price, isNull);
      expect(view.tier, PriceTier.wholesale);
      expect(view.minQuantity, bulkStart);
    });

    test('reports a retired band instead of hiding it', () {
      final TierPriceView view = TierPriceView.from(
        band(disabledAt: createdAt),
        showPrices: true,
      );

      expect(view.isDisabled, isTrue);
      expect(view.price, price);
    });
  });
}
