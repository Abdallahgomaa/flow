import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flow/core/database/database.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

void main() {
  late Directory directory;
  late AppDatabase database;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('flow_db_test');
    final File file = File(p.join(directory.path, 'flow.sqlite'));
    // Host tests use plain SQLite (no SQLCipher); the same pragmas are applied.
    database = AppDatabase(NativeDatabase(file, setup: DatabasePragmas.apply));
  });

  tearDown(() async {
    await database.close();
    await directory.delete(recursive: true);
  });

  Future<QueryRow> readPragma(String name) =>
      database.customSelect('PRAGMA $name;').getSingle();

  test('enables WAL, foreign keys and secure_delete', () async {
    expect((await readPragma('foreign_keys')).read<int>('foreign_keys'), 1);
    expect((await readPragma('secure_delete')).read<int>('secure_delete'), 1);
    expect(
      (await readPragma('journal_mode'))
          .read<String>('journal_mode')
          .toLowerCase(),
      'wal',
    );
  });

  test('round-trips a setting', () async {
    await database
        .into(database.appSettings)
        .insert(
          AppSettingsCompanion.insert(
            key: 'theme_mode',
            value: 'dark',
            updatedAt: DateTime.utc(2026, 1, 1),
          ),
        );

    final AppSetting row = await (database.select(
      database.appSettings,
    )..where(($AppSettingsTable t) => t.key.equals('theme_mode'))).getSingle();

    expect(row.value, 'dark');
    // Drift stores DateTimes as Unix seconds and reads them back in local
    // time; compare the instant, not the representation.
    expect(row.updatedAt.toUtc(), DateTime.utc(2026, 1, 1));
  });
}
