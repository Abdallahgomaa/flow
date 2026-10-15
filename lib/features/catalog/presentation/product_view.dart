/// The catalogue's view models (`P2-05`).
///
/// This is where the «بدون أسعار» rule lives. A screen never receives a raw
/// `Product`; it receives a [ProductView], built once per read. When the
/// signed-in role may not see prices the money fields of that view are genuinely
/// `null` — the number is not merely left unrendered, it is not in the object at
/// all. That keeps the condition out of every widget, where a single forgotten
/// `if` would leak a price onto a screen a stock specialist is looking at
/// (AGENTS rule 5: permissions are enforced where the data is read, not only in
/// the UI).
///
/// The view is pure Dart — no Flutter, no database, no providers — so the rule
/// can be unit-tested directly instead of only through a widget test.
library;

import 'package:flow/core/money/money_core.dart';

import '../domain/category.dart';
import '../domain/price_tier.dart';
import '../domain/product.dart';
import '../domain/product_type.dart';
import '../domain/unit.dart';

/// A product as one of the catalogue screens is allowed to see it.
final class ProductView {
  const ProductView._({
    required this.id,
    required this.name,
    required this.type,
    required this.stockUnitCode,
    required this.salePrice,
    required this.costPrice,
    required this.reorderLevel,
    required this.isDisabled,
    this.categoryId,
    this.purchaseUnitCode,
    this.categoryName,
    this.stockUnitName,
    this.purchaseUnitName,
  });

  /// Builds the view for [product].
  ///
  /// [showPrices] is the whole point of the type: when it is `false` the money
  /// fields come out `null`, so the caller has nothing left to hide. The three
  /// optional names are labels resolved from the catalogue elsewhere; leaving
  /// them out costs a nicer label, never correctness.
  factory ProductView.from(
    Product product, {
    required bool showPrices,
    String? categoryName,
    String? stockUnitName,
    String? purchaseUnitName,
  }) => ProductView._(
    id: product.id,
    name: product.name,
    type: product.type,
    stockUnitCode: product.stockUnitCode,
    salePrice: showPrices ? product.salePrice : null,
    costPrice: showPrices ? product.costPrice : null,
    reorderLevel: product.reorderLevel,
    isDisabled: product.isDisabled,
    categoryId: product.categoryId,
    purchaseUnitCode: product.purchaseUnitCode,
    categoryName: categoryName,
    stockUnitName: stockUnitName,
    purchaseUnitName: purchaseUnitName,
  );

  /// The product's id, used to open it.
  final String id;

  /// The product's name.
  final String name;

  /// Which kind of product it is.
  final ProductType type;

  /// The category the product sits in, or `null` while it is uncategorised.
  final String? categoryId;

  /// The unit the stock is counted in.
  final String stockUnitCode;

  /// The unit the product is bought in, when it differs from the stock unit.
  final String? purchaseUnitCode;

  /// The category's display name, when it could be resolved.
  final String? categoryName;

  /// The stock unit's display name, when it could be resolved.
  final String? stockUnitName;

  /// The purchase unit's display name, when it could be resolved.
  final String? purchaseUnitName;

  /// The sale price, or `null` when the role may not see prices.
  final Money? salePrice;

  /// The cost price, or `null` when the role may not see prices.
  final Money? costPrice;

  /// The re-order level. It is a quantity, not money, so it is always present.
  final Quantity? reorderLevel;

  /// Whether the product has been retired. Retired products are shown, greyed
  /// out, rather than hidden: a receipt may still name one.
  final bool isDisabled;

  /// Whether this view carries prices at all.
  bool get showsPrices => salePrice != null;
}

/// A price band as the details screen may show it (`P2-04` data, `P2-05` view).
///
/// It exists for the same reason as [ProductView]: the band's price is dropped
/// when the role may not see prices, so the rule is applied once here instead of
/// once per widget.
final class TierPriceView {
  const TierPriceView._({
    required this.id,
    required this.tier,
    required this.minQuantity,
    required this.price,
    required this.isDisabled,
  });

  /// Builds the view for [tierPrice], dropping its price unless [showPrices].
  factory TierPriceView.from(TierPrice tierPrice, {required bool showPrices}) =>
      TierPriceView._(
        id: tierPrice.id,
        tier: tierPrice.tier,
        minQuantity: tierPrice.minQuantity,
        price: showPrices ? tierPrice.price : null,
        isDisabled: tierPrice.isDisabled,
      );

  /// The band's id.
  final String id;

  /// Which tier the band belongs to.
  final PriceTier tier;

  /// The quantity the band starts to apply at.
  final Quantity minQuantity;

  /// The price from that quantity on, or `null` when the role may not see it.
  final Money? price;

  /// Whether the band has been retired.
  final bool isDisabled;
}

/// Everything a product form needs before it can render (`P2-05`).
///
/// The form is asynchronous three times over: the shop's currency, the option
/// lists, and — when editing — the product itself. Bundling them behind one read
/// means the screen renders one loading state instead of three nested ones.
///
/// [categories] and [units] are the raw entities, not gated views: a category
/// name and a unit name are not sensitive, and the form needs the ids to send
/// back. Only money is ever gated, and that happens in [ProductView].
final class ProductFormData {
  /// Creates the form's inputs.
  const ProductFormData({
    required this.currency,
    required this.categories,
    required this.units,
    this.product,
  });

  /// The shop's currency, needed to turn typed text into money.
  final Currency currency;

  /// The categories a product may be filed under.
  final List<Category> categories;

  /// The units a product may be counted in, or bought in.
  final List<Unit> units;

  /// The product being edited, or `null` when the form creates a new one.
  final ProductView? product;
}
