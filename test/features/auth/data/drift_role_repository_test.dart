import 'package:drift/native.dart';
import 'package:flow/core/database/database.dart';
import 'package:flow/core/result/failure.dart';
import 'package:flow/core/result/result.dart';
import 'package:flow/core/utils/clock.dart';
import 'package:flow/features/auth/data/drift_role_repository.dart';
import 'package:flow/features/auth/domain/role.dart';
import 'package:flow/features/auth/domain/role_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase database;
  late AuditService audit;
  late FixedClock clock;
  late DriftRoleRepository repository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory(setup: DatabasePragmas.apply));
    clock = FixedClock(DateTime.utc(2026, 5, 1));
    audit = AuditService(database: database, clock: clock);
    repository = DriftRoleRepository(
      database: database,
      unitOfWork: DriftUnitOfWork(database),
      auditService: audit,
      clock: clock,
    );
  });

  tearDown(() => database.close());

  Role draft(String code, {String name = 'Role', bool isBuiltIn = false}) =>
      Role(
        code: code,
        name: name,
        createdAt: clock.nowUtc(),
        isBuiltIn: isBuiltIn,
      );

  test('an untouched store reads back empty', () async {
    final Result<List<Role>> result = await repository.readAll();

    expect(result.valueOrNull, isEmpty);
  });

  test(
    'create persists the role, audits once and keeps the chain intact',
    () async {
      final Result<Role> created = await repository.create(
        role: draft('manager', name: 'Manager'),
        action: 'role.created',
        payload: <String, Object?>{'code': 'manager'},
      );

      expect(created, isA<Ok<Role>>());

      final Result<List<Role>> read = await repository.readAll();
      expect(read.valueOrNull, hasLength(1));
      expect(read.valueOrNull!.single.name, 'Manager');
      expect(read.valueOrNull!.single.isDisabled, isFalse);

      final List<AuditLogData> entries = await database
          .select(database.auditLog)
          .get();
      expect(entries, hasLength(1));
      expect(entries.single.action, 'role.created');
      expect(entries.single.entity, DriftRoleRepository.auditEntity);
      expect(entries.single.entityId, 'manager');

      final AuditChainStatus status = await audit.verifyChain();
      expect(status.isIntact, isTrue);
      expect(status.checkedEntries, 1);
    },
  );

  test('readByCode returns the stored role', () async {
    await repository.create(role: draft('manager'), action: 'role.created');

    final Result<Role> found = await repository.readByCode('manager');

    expect(found.valueOrNull?.code, 'manager');
  });

  test('readByCode reports not-found for an unknown code', () async {
    final Result<Role> found = await repository.readByCode('ghost');

    expect(found.failureOrNull?.code, RoleRepository.notFoundCode);
  });

  test('a duplicate code is refused and writes nothing', () async {
    await repository.create(role: draft('manager'), action: 'role.created');

    final Result<Role> duplicate = await repository.create(
      role: draft('manager'),
      action: 'role.created',
    );

    expect(duplicate.failureOrNull, isA<ConflictFailure>());
    expect(duplicate.failureOrNull?.code, RoleRepository.codeTakenCode);
    // The refusal rolled back atomically: one row, one audit entry.
    expect(await database.select(database.roles).get(), hasLength(1));
    expect(await database.select(database.auditLog).get(), hasLength(1));
  });

  test(
    'disable marks the role disabled, audits once and keeps the row',
    () async {
      await repository.create(role: draft('manager'), action: 'role.created');
      clock.advance(const Duration(minutes: 5));

      final Result<void> disabled = await repository.disable(
        code: 'manager',
        action: 'role.disabled',
      );

      expect(disabled, isA<Ok<void>>());

      // Logically disabled, never deleted (P1-02 acceptance).
      final List<RoleRow> rows = await database.select(database.roles).get();
      expect(rows, hasLength(1));
      expect(rows.single.disabledAt?.toUtc(), DateTime.utc(2026, 5, 1, 0, 5));

      final List<AuditLogData> entries = await database
          .select(database.auditLog)
          .get();
      expect(entries, hasLength(2));
      expect(entries.last.action, 'role.disabled');
      expect(entries.last.entityId, 'manager');
      expect((await audit.verifyChain()).isIntact, isTrue);
    },
  );

  test('disabling an already disabled role changes nothing', () async {
    await repository.create(role: draft('manager'), action: 'role.created');
    await repository.disable(code: 'manager', action: 'role.disabled');

    final Result<void> again = await repository.disable(
      code: 'manager',
      action: 'role.disabled',
    );

    expect(again, isA<Ok<void>>());
    // Nothing changed, so no second audit entry was appended.
    expect(await database.select(database.auditLog).get(), hasLength(2));
  });

  test('a built-in role cannot be disabled', () async {
    await repository.create(
      role: draft('owner', isBuiltIn: true),
      action: 'role.created',
    );

    final Result<void> disabled = await repository.disable(
      code: 'owner',
      action: 'role.disabled',
    );

    expect(disabled.failureOrNull, isA<ConflictFailure>());
    expect(disabled.failureOrNull?.code, RoleRepository.builtInCode);
    final List<RoleRow> rows = await database.select(database.roles).get();
    expect(rows.single.disabledAt, isNull);
  });

  test('disabling an unknown role reports not-found', () async {
    final Result<void> disabled = await repository.disable(
      code: 'ghost',
      action: 'role.disabled',
    );

    expect(disabled.failureOrNull?.code, RoleRepository.notFoundCode);
  });
}
