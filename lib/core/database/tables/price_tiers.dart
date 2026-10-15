/// The `price_tiers` table: the banded prices one product can be sold at
/// (`P2-04`).
///
/// A product has one ordinary sale price, but a shop sells the same tin cheaper
/// by the dozen and cheaper still by the hundred. Each of those is a row here:
/// a tier (retail, wholesale, custom), the quantity at which the band starts,
/// and the price that applies from there on.
///
/// Prices are integers in the shop's minor unit and start quantities are
/// integers in thousandths, so neither ever touches a `double` (AGENTS rule 1).
/// The currency is deliberately not a column for the same reason it is not one
/// on `products`: it is a single business setting, and duplicating it per row is
/// how the two would eventually disagree.
///
/// Rows are never hard-deleted: a receipt that applied a wholesale band last year
/// must keep resolving, so a band that is no longer offered is retired with
/// [disabledAt] (AGENTS rule 4).
///
/// `@DataClassName` keeps the generated row class named `PriceTierRow`, because
/// Drift would otherwise generate `PriceTier`, which collides with the
/// `PriceTier` enum in `features/catalog/domain`.
library;

import 'package:drift/drift.dart';

import 'products.dart';

@DataClassName('PriceTierRow')
class PriceTiers extends Table {
  /// Primary key: a UUID v7 produced by the app's id generator.
  TextColumn get id => text()();

  /// The product the band prices.
  TextColumn get productId => text().references(Products, #id)();

  /// Which tier the band belongs to, stored as its stable slug.
  ///
  /// The slug is what is written, never an enum index, so reordering the
  /// `PriceTier` enum cannot silently move a stored band to another tier.
  TextColumn get tier => text()();

  /// The quantity, in thousandths, at which the band starts to apply.
  ///
  /// A band starting at a single unit is `1000`; «wholesale from a dozen» is
  /// `12000`. Keeping it in thousandths means a weighted product can start a
  /// band at `2500` (two and a half kilos) without a float.
  IntColumn get minQuantityThousandths =>
      integer().withDefault(const Constant<int>(1000))();

  /// The price per stock unit that applies from [minQuantityThousandths] up,
  /// in the shop's minor unit.
  IntColumn get priceMinorUnits => integer()();

  /// When the band was retired (UTC), or `null` while it is offered.
  DateTimeColumn get disabledAt => dateTime().nullable()();

  /// When the band was created (UTC).
  DateTimeColumn get createdAt => dateTime()();

  /// When the band was last modified (UTC), or `null` if never.
  DateTimeColumn get updatedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};

  /// One band per tier per start quantity.
  ///
  /// Two bands of the same tier beginning at the same quantity would leave the
  /// price decided by whichever row the database happened to return first, which
  /// is exactly the kind of ambiguity a till must not have. The engine enforces
  /// the rule; the repository still checks it inside the transaction so the
  /// caller gets a `ConflictFailure` it can explain rather than an exception.
  @override
  List<Set<Column<Object>>> get uniqueKeys => <Set<Column<Object>>>[
    <Column<Object>>{productId, tier, minQuantityThousandths},
  ];
}
