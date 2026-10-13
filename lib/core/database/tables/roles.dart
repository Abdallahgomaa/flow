import 'package:drift/drift.dart';

/// The roles a user account can be assigned (`P1-02`).
///
/// A role is a named bundle of permissions (see `RoleMatrix`, `P1-01`). The
/// built-in rows mirror the `UserRole` enum; custom roles arrive with `P1-14`.
/// Rows are never hard-deleted: a role that is no longer offered is disabled by
/// setting [disabledAt], so users — and the audit trail — keep resolving the
/// reference.
/// Drift would name the generated row class `Role`, which collides with the
/// domain entity `Role` in `features/auth/domain`, so it is renamed here.
@DataClassName('RoleRow')
class Roles extends Table {
  /// Stable role identifier: a `UserRole.code` for the built-ins
  /// (`owner`, `cashier`, `inventory`, `accountant`) or a slug for a custom
  /// role. Never the enum index.
  TextColumn get code => text()();

  /// Human-readable name shown in the UI.
  TextColumn get name => text()();

  /// Optional explanation of what the role is for.
  TextColumn get description => text().nullable()();

  /// Whether this is one of the roles Flow ships with. Built-in roles can never
  /// be disabled or deleted.
  BoolColumn get isBuiltIn => boolean().withDefault(const Constant(false))();

  /// Set when the role is logically disabled. Null means active.
  DateTimeColumn get disabledAt => dateTime().nullable()();

  /// When the role row was created (UTC).
  DateTimeColumn get createdAt => dateTime()();

  /// When the role was last changed (UTC); null until the first change.
  DateTimeColumn get updatedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{code};
}
