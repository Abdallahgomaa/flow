import 'package:flow/core/money/money_core.dart';

import 'product_type.dart';

/// An immutable product record (`P2-02`).
///
/// Money and quantity fields are value objects, never `double`s: [salePrice] and
/// [costPrice] are [Money] and [reorderLevel] is a [Quantity], so a price stays
/// exact to the last minor unit and a re-order level to the last thousandth
/// (AGENTS rule 1).
///
/// [salePrice] carries the shop currency, but the currency is **not** stored with
/// the product: it is a single business setting, and duplicating it per row is
/// how the two would eventually disagree. The repository stamps the current shop
/// currency onto the stored minor units when it reads a row back.
final class Product {
  /// Creates a product record.
  const Product({
    required this.id,
    required this.name,
    required this.type,
    required this.stockUnitCode,
    required this.salePrice,
    required this.createdAt,
    this.categoryId,
    this.purchaseUnitCode,
    this.costPrice,
    this.reorderLevel,
    this.disabledAt,
    this.updatedAt,
  });

  /// Primary key: a UUID v7 produced by the app's id generator.
  final String id;

  /// Name shown in the POS grid, pickers and on receipts.
  final String name;

  /// What kind of product this is.
  final ProductType type;

  /// The category the product belongs to, or `null` while uncategorised.
  final String? categoryId;

  /// The unit the product's stock is counted in.
  final String stockUnitCode;

  /// The unit the product is usually bought in, when that differs.
  final String? purchaseUnitCode;

  /// Sale price in the shop currency.
  final Money salePrice;

  /// What one unit cost the shop, or `null` when unknown.
  final Money? costPrice;

  /// Stock level that should trigger a re-order, or `null` when untracked.
  final Quantity? reorderLevel;

  /// When the product was retired (UTC), or `null` while it is active.
  final DateTime? disabledAt;

  /// When the product was created (UTC).
  final DateTime createdAt;

  /// When the product was last modified (UTC), or `null` if never.
  final DateTime? updatedAt;

  /// Whether the product has been retired.
  bool get isDisabled => disabledAt != null;

  /// The stable context recorded with every write.
  ///
  /// Identifiers and slugs only: a product name is user content, and the trail
  /// stores what changed as machine-readable values so a later report can replay
  /// it (the same shape `BusinessProfile.toAuditPayload` uses).
  Map<String, Object?> toAuditPayload() => <String, Object?>{
    'id': id,
    'type': type.code,
    'stockUnitCode': stockUnitCode,
    if (categoryId != null) 'categoryId': categoryId,
    if (purchaseUnitCode != null) 'purchaseUnitCode': purchaseUnitCode,
  };

  /// The money fields of a write, describing the prices.
  ///
  /// On a create, where [previous] is `null`, it records the prices as written.
  /// On an update it records **only the prices that actually moved**, as a
  /// before/after pair, so the trail answers «who changed this price, and from
  /// what to what» without storing every unrelated edit as if it were a price
  /// change. Two identical prices produce an empty map, which is how a caller can
  /// tell that the price audit payload has nothing to say.
  Map<String, Object?> priceAuditPayload({Product? previous}) {
    final Map<String, Object?> payload = <String, Object?>{};
    if (previous == null) {
      payload['salePriceMinorUnits'] = salePrice.minorUnits;
      final Money? cost = costPrice;
      if (cost != null) {
        payload['costPriceMinorUnits'] = cost.minorUnits;
      }
      return payload;
    }

    if (previous.salePrice.minorUnits != salePrice.minorUnits) {
      payload['salePriceMinorUnitsBefore'] = previous.salePrice.minorUnits;
      payload['salePriceMinorUnitsAfter'] = salePrice.minorUnits;
    }
    final int? costBefore = previous.costPrice?.minorUnits;
    final int? costAfter = costPrice?.minorUnits;
    if (costBefore != costAfter) {
      payload['costPriceMinorUnitsBefore'] = costBefore;
      payload['costPriceMinorUnitsAfter'] = costAfter;
    }
    return payload;
  }

  @override
  bool operator ==(Object other) =>
      other is Product &&
      other.id == id &&
      other.name == name &&
      other.type == type &&
      other.categoryId == categoryId &&
      other.stockUnitCode == stockUnitCode &&
      other.purchaseUnitCode == purchaseUnitCode &&
      other.salePrice == salePrice &&
      other.costPrice == costPrice &&
      other.reorderLevel == reorderLevel &&
      other.disabledAt == disabledAt &&
      other.createdAt == createdAt &&
      other.updatedAt == updatedAt;

  @override
  int get hashCode => Object.hash(
    id,
    name,
    type,
    categoryId,
    stockUnitCode,
    purchaseUnitCode,
    salePrice,
    costPrice,
    reorderLevel,
    disabledAt,
    createdAt,
    updatedAt,
  );

  @override
  String toString() =>
      'Product(id: $id, name: $name, type: ${type.code}, '
      'salePrice: ${salePrice.minorUnits}, isDisabled: $isDisabled)';
}
