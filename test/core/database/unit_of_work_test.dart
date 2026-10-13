import 'dart:io';

import 'package:drift/native.dart';
import 'package:flow/core/database/database.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

void main() {
  late Directory directory;
  late AppDatabase database;
  late UnitOfWork unitOfWork;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('flow_uow_test');
    final File file = File(p.join(directory.path, 'flow.sqlite'));
    database = AppDatabase(NativeDatabase(file, setup: DatabasePragmas.apply));
    unitOfWork = DriftUnitOfWork(database);
  });

  tearDown(() async {
    await database.close();
    await directory.delete(recursive: true);
  });

  Future<void> insertSetting(String key) => database
      .into(database.appSettings)
      .insert(
        AppSettingsCompanion.insert(
          key: key,
          value: 'v-$key',
          updatedAt: DateTime.utc(2026, 1, 1),
        ),
      );

  test('commits every write when the action succeeds', () async {
    await unitOfWork.run(() async {
      await insertSetting('a');
      await insertSetting('b');
    });

    final List<AppSetting> rows = await database
        .select(database.appSettings)
        .get();
    expect(rows.map((AppSetting r) => r.key), containsAll(<String>['a', 'b']));
  });

  test('rolls back every write when the action throws', () async {
    await expectLater(
      unitOfWork.run(() async {
        await insertSetting('a');
        await insertSetting('b');
        throw StateError('boom');
      }),
      throwsA(isA<StateError>()),
    );

    final List<AppSetting> rows = await database
        .select(database.appSettings)
        .get();
    expect(rows, isEmpty, reason: 'the whole unit must roll back');
  });
}
