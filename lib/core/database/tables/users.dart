import 'package:drift/drift.dart';

import 'roles.dart';

/// The user accounts that can sign in to Flow (`P1-02`).
///
/// Credentials arrive with `P1-03`: [passwordHash] and [pinHash] hold Argon2id
/// PHC strings, which embed their own salt and cost parameters, so no separate
/// salt columns are needed. Accounts are never hard-deleted — disable them by
/// setting [disabledAt] so sales history and the audit trail keep resolving.
/// Drift would name the generated row class `User`, which collides with the
/// domain entity `User` in `features/auth/domain`, so it is renamed here.
@DataClassName('UserRow')
class Users extends Table {
  /// Primary key: a UUID v7 produced by the app's `idGenerator`.
  TextColumn get id => text()();

  /// Unique login name.
  TextColumn get username => text().unique()();

  /// Name shown in the UI and on receipts.
  TextColumn get displayName => text()();

  /// The role this user holds; references [Roles.code] (enforced because
  /// `PRAGMA foreign_keys = ON` is re-asserted in `AppDatabase.beforeOpen`).
  TextColumn get roleCode => text().references(Roles, #code)();

  /// Argon2id hash of the login password (`P1-03`); null until one is set.
  TextColumn get passwordHash => text().nullable()();

  /// Argon2id hash of the quick-unlock PIN (`P1-03`); null until one is set.
  TextColumn get pinHash => text().nullable()();

  /// Set when the account is logically disabled. Null means active.
  DateTimeColumn get disabledAt => dateTime().nullable()();

  /// When the account row was created (UTC).
  DateTimeColumn get createdAt => dateTime()();

  /// When the account was last changed (UTC); null until the first change.
  DateTimeColumn get updatedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}
