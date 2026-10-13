import 'package:drift/drift.dart' show QueryExecutor, QueryRow;
import 'package:drift/native.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flow/core/database/database.dart';
import 'package:flutter_test/flutter_test.dart';

import 'generated_migrations/schema.dart';

/// Proves that schema changes ship with a working migration, a snapshot and a
/// test (project rule: every schema change ships with migration + snapshot +
/// migration test).
///
/// The historic snapshots live in `drift_schemas/` and the helpers drift
/// generated from them live in `generated_migrations/`. To add a version:
///  1. bump `AppDatabase.schemaVersion` and add the `onUpgrade` branch,
///  2. `flutter pub run drift_dev schema dump lib/core/database/app_database.dart drift_schemas/`,
///  3. `flutter pub run drift_dev schema generate drift_schemas/ test/core/database/generated_migrations/`.
void main() {
  late SchemaVerifier verifier;

  setUpAll(() {
    verifier = SchemaVerifier(GeneratedHelper());
  });

  test('a v3 database upgrades to v4 and matches the v4 schema', () async {
    // `startAt` opens a real database created from the historic v3 snapshot and
    // stamped with `user_version = 3`, exactly like an installed v3 app.
    final QueryExecutor connection = await verifier.startAt(3);
    final AppDatabase database = AppDatabase(connection);
    addTearDown(database.close);

    await verifier.migrateAndValidate(database, 4);
  });

  test('a freshly created database matches the v4 schema', () async {
    final AppDatabase database = AppDatabase(
      NativeDatabase.memory(setup: DatabasePragmas.apply),
    );
    addTearDown(database.close);

    await verifier.migrateAndValidate(database, 4);
  });

  test('the upgrade adds users and roles and keeps the audit guards', () async {
    final QueryExecutor connection = await verifier.startAt(3);
    final AppDatabase database = AppDatabase(connection);
    addTearDown(database.close);

    await verifier.migrateAndValidate(database, 4);

    // The two new tables exist and start empty...
    expect(await database.select(database.roles).get(), isEmpty);
    expect(await database.select(database.users).get(), isEmpty);
    // ...the pre-existing audit trail is untouched...
    expect(await database.select(database.auditLog).get(), isEmpty);
    // ...and the append-only triggers were re-asserted by the upgrade.
    final Set<String> triggers =
        (await database
                .customSelect(
                  "SELECT name FROM sqlite_master WHERE type = 'trigger'",
                )
                .get())
            .map((QueryRow row) => row.read<String>('name'))
            .toSet();
    expect(
      triggers,
      containsAll(<String>[
        'audit_log_no_update',
        'audit_log_no_delete',
        'audit_checkpoints_no_update',
        'audit_checkpoints_no_delete',
      ]),
    );
  });
}
