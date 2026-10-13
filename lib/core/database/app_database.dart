import 'package:drift/drift.dart';

import 'tables/app_settings.dart';
import 'tables/audit_checkpoints.dart';
import 'tables/audit_log.dart';
import 'tables/roles.dart';
import 'tables/users.dart';

part 'app_database.g.dart';

/// The application's Drift database.
///
/// Owns the schema, the migrations and the connection PRAGMAs. The physical
/// connection is supplied as a [QueryExecutor] (see `DatabaseConnector`) so the
/// engine can differ between the app (SQLCipher) and tests (plain SQLite).
@DriftDatabase(
  tables: <Type>[AppSettings, AuditLog, AuditCheckpoints, Roles, Users],
)
class AppDatabase extends _$AppDatabase {
  /// Creates a database over the injected executor [e].
  AppDatabase(super.e);

  /// v2 added `audit_log` (P0-15); v3 added `audit_checkpoints` (P0-16);
  /// v4 adds `roles` and `users` (P1-02).
  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
      await _ensureAppendOnlyGuards();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 2) {
        await m.createTable(auditLog);
      }
      if (from < 3) {
        await m.createTable(auditCheckpoints);
      }
      if (from < 4) {
        // Roles before users: `users.role_code` references `roles.code`.
        await m.createTable(roles);
        await m.createTable(users);
      }
      await _ensureAppendOnlyGuards();
    },
    beforeOpen: (OpeningDetails details) async {
      // `foreign_keys` is a per-connection setting; re-assert it here so the
      // invariant holds even if an executor forgets it. Journal mode and
      // `secure_delete` are applied at the connection level (DatabasePragmas).
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  /// Audit tables are append-only (AGENTS rule 4). SQLite has no deny
  /// privilege, so the guarantee is enforced with `BEFORE UPDATE/DELETE`
  /// triggers that abort the offending statement.
  Future<void> _ensureAppendOnlyGuards() async {
    for (final String table in <String>['audit_log', 'audit_checkpoints']) {
      await customStatement(
        'CREATE TRIGGER IF NOT EXISTS ${table}_no_update '
        'BEFORE UPDATE ON $table BEGIN '
        "SELECT RAISE(ABORT, '$table is append-only'); END;",
      );
      await customStatement(
        'CREATE TRIGGER IF NOT EXISTS ${table}_no_delete '
        'BEFORE DELETE ON $table BEGIN '
        "SELECT RAISE(ABORT, '$table is append-only'); END;",
      );
    }
  }
}
