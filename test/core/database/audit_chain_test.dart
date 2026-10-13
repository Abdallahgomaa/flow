import 'dart:io';

import 'package:drift/drift.dart' show OrderingTerm;
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
    directory = await Directory.systemTemp.createTemp('flow_chain_test');
    final File file = File(p.join(directory.path, 'flow.sqlite'));
    database = AppDatabase(NativeDatabase(file, setup: DatabasePragmas.apply));
    clock = FixedClock(DateTime.utc(2026, 1, 1));
    audit = AuditService(database: database, clock: clock);
  });

  tearDown(() async {
    await database.close();
    await directory.delete(recursive: true);
  });

  Future<void> seed(int count) async {
    for (int i = 0; i < count; i++) {
      clock.advance(const Duration(minutes: 1));
      await audit.append(
        action: 'setting.write',
        entity: 'app_settings',
        entityId: 'key_$i',
        payload: <String, Object?>{'value': 'v$i'},
      );
    }
  }

  test('an empty chain verifies as intact', () async {
    final AuditChainStatus status = await audit.verifyChain();
    expect(status.isIntact, isTrue);
    expect(status.checkedEntries, 0);
    expect(status.firstBrokenSeq, isNull);
  });

  test('a clean chain verifies and checkpoints stay valid', () async {
    await seed(5);
    await audit.checkpoint();
    await seed(2);

    final AuditChainStatus status = await audit.verifyChain();
    expect(status.isIntact, isTrue);
    expect(status.checkedEntries, 7);
  });

  test('detects a tampered row and reports the first broken link', () async {
    await seed(4);
    await audit.checkpoint();

    // Simulate a manual tamper: bypass the append-only trigger, rewrite a row.
    await database.customStatement('DROP TRIGGER audit_log_no_update');
    await database.customStatement(
      "UPDATE audit_log SET payload = '{\"value\":\"forged\"}' WHERE seq = 2",
    );

    final AuditChainStatus status = await audit.verifyChain();
    expect(status.isIntact, isFalse);
    expect(status.firstBrokenSeq, 2);
    expect(status.reason, contains('hash'));
  });

  test('detects a rewritten tail through its checkpoint', () async {
    await seed(3);
    await audit.checkpoint();

    // Rewrite the last row including its hash, so the chain alone still links…
    await database.customStatement('DROP TRIGGER audit_log_no_update');
    final AuditLogData tail =
        await (database.select(database.auditLog)
              ..orderBy(<OrderingTerm Function($AuditLogTable)>[
                ($AuditLogTable t) => OrderingTerm.desc(t.seq),
              ])
              ..limit(1))
            .getSingle();
    final String forgedHash = List<String>.filled(64, 'f').join();
    await database.customStatement(
      "UPDATE audit_log SET hash = '$forgedHash' WHERE seq = ${tail.seq}",
    );

    // …but the checkpoint anchors the original tail hash.
    final AuditChainStatus status = await audit.verifyChain();
    expect(status.isIntact, isFalse);
    expect(status.firstBrokenSeq, tail.seq);
  });

  test('sub-second timestamps still verify after a database round-trip', () async {
    // Drift stores `DateTime` with second precision, so a timestamp carrying
    // milliseconds (what `SystemClock` produces in production) must not change
    // the hash once it has been persisted and read back.
    clock.advance(
      const Duration(seconds: 7, milliseconds: 1, microseconds: 500),
    );
    await audit.append(action: 'setting.write', entity: 'app_settings');

    final AuditLogData stored = await database
        .select(database.auditLog)
        .getSingle();
    expect(stored.occurredAt.toUtc(), DateTime.utc(2026, 1, 1, 0, 0, 7));
    expect(stored.occurredAt.millisecond, 0);
    expect(stored.occurredAt.microsecond, 0);

    final AuditChainStatus status = await audit.verifyChain();
    expect(status.isIntact, isTrue);
    expect(status.checkedEntries, 1);
  });
}
