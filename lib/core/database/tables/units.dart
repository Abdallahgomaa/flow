/// The `units` table: units of measure and how they relate (`P2-01`).
///
/// A row is either a **base unit** ([baseUnitCode] is `null`) or is expressed in
/// terms of another unit: [factorThousandths] thousandths of [baseUnitCode]. So
/// `carton` with `baseUnitCode: 'piece'` and `factorThousandths: 12000` means one
/// carton is twelve pieces. Because the factor is stored as integer thousandths,
/// the same fixed-point discipline as `Quantity` applies and no conversion ever
/// touches a `double` (AGENTS rule 2).
///
/// [factorThousandths] is `null` exactly when [baseUnitCode] is `null`: a base
/// unit is its own reference point and is worth exactly `1.000`.
///
/// Rows are never hard-deleted: [disabledAt] retires a unit, so products and the
/// historical documents that mention it keep resolving their unit code.
///
/// `@DataClassName` keeps the generated row class named `UnitRow`, because the
/// name Drift would pick (`Unit`) collides with the domain entity in
/// `features/catalog/domain`.
library;

import 'package:drift/drift.dart';

@DataClassName('UnitRow')
class Units extends Table {
  /// Primary key: a short slug such as `piece`, `carton` or `kg`.
  TextColumn get code => text()();

  /// Display name shown in pickers and on receipts.
  TextColumn get name => text()();

  /// The unit this one is measured in, or `null` when this is a base unit.
  ///
  /// The self-referencing foreign key keeps the chain well-formed at the database
  /// level; the catalog repository rejects cycles that the schema cannot see.
  TextColumn get baseUnitCode => text().nullable().references(Units, #code)();

  /// How many thousandths of [baseUnitCode] one of this unit is worth.
  ///
  /// `null` exactly when [baseUnitCode] is `null`, because a base unit is worth
  /// exactly `1.000` of itself.
  IntColumn get factorThousandths => integer().nullable()();

  /// When the unit was retired (UTC), or `null` while it is active.
  DateTimeColumn get disabledAt => dateTime().nullable()();

  /// When the unit was created (UTC).
  DateTimeColumn get createdAt => dateTime()();

  /// When the unit was last modified (UTC), or `null` if never.
  DateTimeColumn get updatedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{code};
}
