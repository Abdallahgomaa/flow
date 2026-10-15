/// The `products` table: everything the shop sells (`P2-02`).
///
/// A product never stores a number for money or for a quantity: both are kept as
/// integers — minor units for prices, thousandths for quantities — matching the
/// project rule that money and quantity maths never touches a `double`
/// (AGENTS rule 1). The currency itself is not a column: prices are always in the
/// shop's currency, which is a single business setting, so storing it per row
/// would only create a way for the two to disagree.
///
/// Rows are never hard-deleted. A product that is no longer sold is retired with
/// [disabledAt], because sale lines, stock movements and the audit trail all
/// reference it and history must keep resolving (AGENTS rule 4).
///
/// `@DataClassName` keeps the generated row class named `ProductRow`, because
/// Drift would otherwise generate `Product`, which collides with the domain
/// entity of the same name in `features/catalog/domain`.
library;

import 'package:drift/drift.dart';

import 'categories.dart';
import 'units.dart';

@DataClassName('ProductRow')
class Products extends Table {
  /// Primary key: a UUID v7 produced by the app's id generator.
  TextColumn get id => text()();

  /// Name shown in the POS grid, pickers and on receipts.
  TextColumn get name => text()();

  /// The product type slug (see `ProductType.code` in the catalog domain).
  ///
  /// The slug is stored, never the enum index, so reordering the enum cannot
  /// silently reclassify every stored product.
  TextColumn get type => text()();

  /// The category the product belongs to, or `null` while it is uncategorised.
  TextColumn get categoryId => text().nullable().references(Categories, #id)();

  /// The unit the product's stock is counted in (the base stock unit).
  ///
  /// The reverse reference gets an explicit name because two columns of this
  /// table point at `units.code`; without it Drift would call both of them
  /// `productsRefs` and silently skip generating one of the filters.
  @ReferenceName('productsByStockUnit')
  TextColumn get stockUnitCode => text().references(Units, #code)();

  /// The unit the product is usually bought in, when that differs from the
  /// stock unit (for example stock in pieces, purchase by the carton).
  @ReferenceName('productsByPurchaseUnit')
  TextColumn get purchaseUnitCode =>
      text().nullable().references(Units, #code)();

  /// Sale price in the shop currency, as an integer number of minor units.
  IntColumn get salePriceMinorUnits => integer()();

  /// What one unit cost the shop, in minor units, or `null` when unknown.
  IntColumn get costPriceMinorUnits => integer().nullable()();

  /// Stock level that should trigger a re-order, in thousandths of
  /// [stockUnitCode], or `null` when the product is not tracked that way.
  IntColumn get reorderLevelThousandths => integer().nullable()();

  /// When the product was retired (UTC), or `null` while it is active.
  DateTimeColumn get disabledAt => dateTime().nullable()();

  /// When the product was created (UTC).
  DateTimeColumn get createdAt => dateTime()();

  /// When the product was last modified (UTC), or `null` if never.
  DateTimeColumn get updatedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}
