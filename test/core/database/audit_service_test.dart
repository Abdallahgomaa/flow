import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flow/core/database/database.dart';
import 'package:flow/core/utils/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

void main() {
  late Directory directory;
  late AppDatabase database;
  late AuditService audit;
  late FixedClock clock;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('flow_audit_test');
    final File file = File(p.join(directory.path, 'flow.sqlite'));
    database = AppDatabase(NativeDatabase(file, setup: DatabasePragmas.apply));
    clock = FixedClock(DateTime.utc(2026, 1, 1));
    audit = AuditService(database: database, clock: clock);
  });

  tearDown(() async {
    await database.close();
    await directory.delete(recursive: true);
  });

  Future<List<AuditLogData>> entries() =>
      (database.select(database.auditLog)
            ..orderBy(<OrderingTerm Function($AuditLogTable)>[
              ($AuditLogTable t) => OrderingTerm.asc(t.seq),
            ]))
          .get();

  test('seeds the genesis hash and chains every entry', () async {
    clock.set(DateTime.utc(2026, 1, 1));
    await audit.append(action: 'setting.write', entity: 'app_settings');
    clock.set(DateTime.utc(2026, 1, 2));
    await audit.append(
      action: 'setting.write',
      entity: 'app_settings',
      entityId: 'theme_mode',
      payload: <String, Object?>{'value': 'dark'},
    );
    clock.set(DateTime.utc(2026, 1, 3));
    await audit.append(action: 'user.login', entity: 'users', actor: 'owner');

    final List<AuditLogData> rows = await entries();
    expect(rows, hasLength(3));
    expect(rows.first.prevHash, AuditService.genesisHash);
    expect(rows[1].prevHash, rows.first.hash);
    expect(rows[2].prevHash, rows[1].hash);
    for (final AuditLogData row in rows) {
      expect(row.hash, hasLength(64));
    }
    expect(rows.map((AuditLogData r) => r.hash).toSet(), hasLength(3));
  });

  test('hashEntry is reproducible and changes with the payload', () async {
    final DateTime at = DateTime.utc(2026, 1, 1);
    Future<String> hashOf(Map<String, Object?> payload) =>
        AuditService.hashEntry(
          prevHash: AuditService.genesisHash,
          occurredAt: at,
          actor: null,
          action: 'setting.write',
          entity: 'app_settings',
          entityId: 'theme_mode',
          payloadJson: AuditService.canonicalJson(payload),
        );

    final String a = await hashOf(<String, Object?>{'value': 'dark'});
    final String b = await hashOf(<String, Object?>{'value': 'dark'});
    final String c = await hashOf(<String, Object?>{'value': 'light'});
    expect(a, b);
    expect(a, isNot(c));
  });

  test('commits audit rows written inside a UnitOfWork', () async {
    await DriftUnitOfWork(database).run(() async {
      await audit.append(action: 'setting.write', entity: 'app_settings');
      await audit.append(action: 'setting.write', entity: 'app_settings');
    });

    expect(await entries(), hasLength(2));
  });

  test('rolls audit rows back with the transaction', () async {
    await expectLater(
      DriftUnitOfWork(database).run(() async {
        await audit.append(action: 'setting.write', entity: 'app_settings');
        throw StateError('boom');
      }),
      throwsA(isA<StateError>()),
    );

    expect(await entries(), isEmpty);
  });

  test('rejects UPDATE and DELETE (append-only triggers)', () async {
    await audit.append(action: 'setting.write', entity: 'app_settings');

    await expectLater(
      database.customStatement("UPDATE audit_log SET action = 'tampered'"),
      throwsA(isA<Exception>()),
    );
    await expectLater(
      database.customStatement('DELETE FROM audit_log'),
      throwsA(isA<Exception>()),
    );

    final List<AuditLogData> rows = await entries();
    expect(rows, hasLength(1));
    expect(rows.single.action, 'setting.write');
  });
}
