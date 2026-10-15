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
///  3. `flutter pub run drift_dev schema generate drift_schemas/ test/core/database/generated_migrations/`,
///  4. add the new version to the tests below.
void main() {
  late SchemaVerifier verifier;

  setUpAll(() {
    verifier = SchemaVerifier(GeneratedHelper());
  });

  test('a v3 database upgrades to v8 and matches the v8 schema', () async {
    // `startAt` opens a real database created from the historic v3 snapshot and
    // stamped with `user_version = 3`, exactly like an installed v3 app.
    final QueryExecutor connection = await verifier.startAt(3);
    final AppDatabase database = AppDatabase(connection);
    addTearDown(database.close);

    await verifier.migrateAndValidate(database, 8);
  });

  test('a v4 database upgrades to v8 and matches the v8 schema', () async {
    // Every shipped version must keep upgrading, not just the one immediately
    // before, so each historic snapshot is exercised as its own starting point.
    final QueryExecutor connection = await verifier.startAt(4);
    final AppDatabase database = AppDatabase(connection);
    addTearDown(database.close);

    await verifier.migrateAndValidate(database, 8);
  });

  test('a v5 database upgrades to v8 and matches the v8 schema', () async {
    final QueryExecutor connection = await verifier.startAt(5);
    final AppDatabase database = AppDatabase(connection);
    addTearDown(database.close);

    await verifier.migrateAndValidate(database, 8);
  });

  test('a v6 database upgrades to v8 and matches the v8 schema', () async {
    final QueryExecutor connection = await verifier.startAt(6);
    final AppDatabase database = AppDatabase(connection);
    addTearDown(database.close);

    await verifier.migrateAndValidate(database, 8);
  });

  test('a v7 database upgrades to v8 and matches the v8 schema', () async {
    // The version immediately before this one is the one users are most likely
    // to be running, so it gets its own case rather than being implied.
    final QueryExecutor connection = await verifier.startAt(7);
    final AppDatabase database = AppDatabase(connection);
    addTearDown(database.close);

    await verifier.migrateAndValidate(database, 8);
  });

  test('a freshly created database matches the v8 schema', () async {
    final AppDatabase database = AppDatabase(
      NativeDatabase.memory(setup: DatabasePragmas.apply),
    );
    addTearDown(database.close);

    await verifier.migrateAndValidate(database, 8);
  });

  test('the upgrade adds users and roles and keeps the audit guards', () async {
    final QueryExecutor connection = await verifier.startAt(3);
    final AppDatabase database = AppDatabase(connection);
    addTearDown(database.close);

    await verifier.migrateAndValidate(database, 8);

    // The two new tables exist and start empty...
    expect(await database.select(database.roles).get(), isEmpty);
    expect(await database.select(database.users).get(), isEmpty);
    // ...the pre-existing audit trail is untouched...
    expect(await database.select(database.auditLog).get(), isEmpty);
    // ...and the append-only triggers were re-asserted by the upgrade.
    expect(await _triggers(database), containsAll(_appendOnlyTriggers));
  });

  test('the upgrade adds categories and units', () async {
    final QueryExecutor connection = await verifier.startAt(4);
    final AppDatabase database = AppDatabase(connection);
    addTearDown(database.close);

    await verifier.migrateAndValidate(database, 8);

    // The two new tables exist and start empty...
    expect(await database.select(database.categories).get(), isEmpty);
    expect(await database.select(database.units).get(), isEmpty);
    // ...the accounts created before the upgrade survive it...
    expect(await database.select(database.users).get(), isEmpty);
    // ...and the append-only triggers were re-asserted by the upgrade.
    expect(await _triggers(database), containsAll(_appendOnlyTriggers));
  });

  test('the upgrade adds products on top of the catalogue', () async {
    final QueryExecutor connection = await verifier.startAt(5);
    final AppDatabase database = AppDatabase(connection);
    addTearDown(database.close);

    await verifier.migrateAndValidate(database, 8);

    // The product table exists and starts empty...
    expect(await database.select(database.products).get(), isEmpty);
    // ...the catalogue tables it references survive the upgrade...
    expect(await database.select(database.categories).get(), isEmpty);
    expect(await database.select(database.units).get(), isEmpty);
    // ...and the append-only triggers were re-asserted by the upgrade.
    expect(await _triggers(database), containsAll(_appendOnlyTriggers));
  });

  test('the upgrade adds barcodes on top of the products', () async {
    final QueryExecutor connection = await verifier.startAt(6);
    final AppDatabase database = AppDatabase(connection);
    addTearDown(database.close);

    await verifier.migrateAndValidate(database, 8);

    // The label table exists and starts empty...
    expect(await database.select(database.barcodes).get(), isEmpty);
    // ...the product table it references survives the upgrade...
    expect(await database.select(database.products).get(), isEmpty);
    expect(await database.select(database.categories).get(), isEmpty);
    expect(await database.select(database.units).get(), isEmpty);
    // ...and the append-only triggers were re-asserted by the upgrade.
    expect(await _triggers(database), containsAll(_appendOnlyTriggers));
  });

  test('the upgrade adds price tiers on top of the products', () async {
    final QueryExecutor connection = await verifier.startAt(7);
    final AppDatabase database = AppDatabase(connection);
    addTearDown(database.close);

    await verifier.migrateAndValidate(database, 8);

    // The band table exists and starts empty...
    expect(await database.select(database.priceTiers).get(), isEmpty);
    // ...the product table it references survives the upgrade...
    expect(await database.select(database.products).get(), isEmpty);
    expect(await database.select(database.barcodes).get(), isEmpty);
    expect(await database.select(database.categories).get(), isEmpty);
    expect(await database.select(database.units).get(), isEmpty);
    // ...and the append-only triggers were re-asserted by the upgrade.
    expect(await _triggers(database), containsAll(_appendOnlyTriggers));
  });
}

/// The guards that keep the audit trail append-only (P0-15, P0-16).
const List<String> _appendOnlyTriggers = <String>[
  'audit_log_no_update',
  'audit_log_no_delete',
  'audit_checkpoints_no_update',
  'audit_checkpoints_no_delete',
];

/// Reads the trigger names SQLite currently holds, for the append-only proof.
Future<Set<String>> _triggers(AppDatabase database) async {
  final List<QueryRow> rows = await database
      .customSelect("SELECT name FROM sqlite_master WHERE type = 'trigger'")
      .get();
  return rows.map((QueryRow row) => row.read<String>('name')).toSet();
}
