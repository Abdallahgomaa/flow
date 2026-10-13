import 'package:drift/native.dart';
import 'package:flow/core/database/database.dart';
import 'package:flow/core/result/result.dart';
import 'package:flow/core/utils/clock.dart';
import 'package:flow/features/settings/data/drift_settings_repository.dart';
import 'package:flow/features/settings/domain/setting_keys.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase database;
  late AuditService audit;
  late FixedClock clock;
  late DriftSettingsRepository repository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory(setup: DatabasePragmas.apply));
    clock = FixedClock(DateTime.utc(2026, 5, 1));
    audit = AuditService(database: database, clock: clock);
    repository = DriftSettingsRepository(
      database: database,
      unitOfWork: DriftUnitOfWork(database),
      auditService: audit,
      clock: clock,
    );
  });

  tearDown(() => database.close());

  test('an untouched store reads back empty', () async {
    final Result<Map<String, String>> result = await repository.readAll();

    expect(result.valueOrNull, isEmpty);
  });

  test(
    'save persists every row, audits once and keeps the chain intact',
    () async {
      final Result<void> saved = await repository.save(
        values: <String, String>{
          SettingKeys.businessName: 'Flow Market',
          SettingKeys.taxRate: '14',
        },
        action: 'settings.business_profile.saved',
        payload: <String, Object?>{'name': 'Flow Market'},
      );

      expect(saved, isA<Ok<void>>());

      final Result<Map<String, String>> read = await repository.readAll();
      expect(read.valueOrNull, <String, String>{
        SettingKeys.businessName: 'Flow Market',
        SettingKeys.taxRate: '14',
      });

      final List<AuditLogData> entries = await database
          .select(database.auditLog)
          .get();
      expect(entries, hasLength(1));
      expect(entries.single.action, 'settings.business_profile.saved');
      expect(entries.single.entity, DriftSettingsRepository.auditEntity);

      final AuditChainStatus status = await audit.verifyChain();
      expect(status.isIntact, isTrue);
      expect(status.checkedEntries, 1);
    },
  );

  test(
    'saving the same key again updates the row instead of adding one',
    () async {
      await repository.save(
        values: <String, String>{SettingKeys.businessName: 'Old'},
        action: 'first',
      );
      clock.advance(const Duration(minutes: 1));
      await repository.save(
        values: <String, String>{SettingKeys.businessName: 'New'},
        action: 'second',
      );

      final List<AppSetting> rows = await database
          .select(database.appSettings)
          .get();
      expect(rows, hasLength(1));
      expect(rows.single.value, 'New');
      expect(rows.single.updatedAt.toUtc(), DateTime.utc(2026, 5, 1, 0, 1));

      // Both writes were audited, so history survives the overwrite.
      expect(await database.select(database.auditLog).get(), hasLength(2));
    },
  );
}
