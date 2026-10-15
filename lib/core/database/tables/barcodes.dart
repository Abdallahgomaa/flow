/// The `barcodes` table: the scannable labels that resolve to a product
/// (`P2-03`).
///
/// A label is a row of its own rather than a column on `products` because one
/// product legitimately carries many: the manufacturer's code, the shop's own
/// shelf label, and the code printed on the outer carton. Keeping them apart is
/// also what lets a carton label mean "twelve units" instead of "one product".
///
/// A label is never hard-deleted: a receipt or a stock movement from last year
/// still has to resolve the code that was scanned (AGENTS rule 4). Retiring is a
/// logical disable through [disabledAt].
///
/// `@DataClassName` keeps the generated row class named `BarcodeRow`, because
/// Drift would otherwise generate `Barcode`, which collides with the domain
/// entity of the same name in `features/catalog/domain`.
library;

import 'package:drift/drift.dart';

import 'products.dart';

@DataClassName('BarcodeRow')
class Barcodes extends Table {
  /// Primary key: a UUID v7 produced by the app's id generator.
  TextColumn get id => text()();

  /// The scannable code, unique across the whole shop.
  ///
  /// Uniqueness is a database constraint, not a check in the presentation: two
  /// rows carrying the same code would make a scan ambiguous, and only the
  /// engine can promise that no writer slips between the check and the insert.
  ///
  /// The constraint spans retired rows too, so a code stays reserved to the
  /// product it once identified — that reservation is what makes a historical
  /// scan unambiguous (the alternative, re-registering a retired code under a
  /// different product, would silently change the meaning of old documents).
  TextColumn get code => text().unique()();

  /// The product a scan of this code resolves to.
  TextColumn get productId => text().references(Products, #id)();

  /// How many stock units one scan of this code represents, in thousandths.
  ///
  /// A label on a single unit is `1000`; a label printed on a carton of twelve
  /// is `12000`. Integer thousandths, never a `double` (AGENTS rule 1).
  IntColumn get multiplierThousandths =>
      integer().withDefault(const Constant<int>(1000))();

  /// When the label was retired (UTC), or `null` while it is active.
  DateTimeColumn get disabledAt => dateTime().nullable()();

  /// When the label was created (UTC).
  DateTimeColumn get createdAt => dateTime()();

  /// When the label was last modified (UTC), or `null` if never.
  DateTimeColumn get updatedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}
