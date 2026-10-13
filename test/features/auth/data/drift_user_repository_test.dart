import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flow/core/database/database.dart';
import 'package:flow/core/result/failure.dart';
import 'package:flow/core/result/result.dart';
import 'package:flow/core/utils/clock.dart';
import 'package:flow/features/auth/data/drift_user_repository.dart';
import 'package:flow/features/auth/domain/user.dart';
import 'package:flow/features/auth/domain/user_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase database;
  late AuditService audit;
  late FixedClock clock;
  late DriftUserRepository repository;

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory(setup: DatabasePragmas.apply));
    clock = FixedClock(DateTime.utc(2026, 5, 1));
    audit = AuditService(database: database, clock: clock);
    repository = DriftUserRepository(
      database: database,
      unitOfWork: DriftUnitOfWork(database),
      auditService: audit,
      clock: clock,
    );
    // `users.role_code` references a role, so the fixture needs one.
    await database
        .into(database.roles)
        .insert(
          RolesCompanion.insert(
            code: 'cashier',
            name: 'Cashier',
            createdAt: clock.nowUtc(),
          ),
        );
  });

  tearDown(() => database.close());

  User draft({
    String id = 'user-1',
    String username = 'cashier1',
    String roleCode = 'cashier',
    String? passwordHash,
  }) => User(
    id: id,
    username: username,
    displayName: 'Cashier One',
    roleCode: roleCode,
    createdAt: clock.nowUtc(),
    passwordHash: passwordHash,
  );

  test('an untouched store reads back empty', () async {
    final Result<List<User>> result = await repository.readAll();

    expect(result.valueOrNull, isEmpty);
  });

  test(
    'create persists the user, audits once and keeps the chain intact',
    () async {
      final Result<User> created = await repository.create(
        user: draft(),
        action: 'user.created',
        payload: <String, Object?>{'id': 'user-1', 'roleCode': 'cashier'},
      );

      expect(created, isA<Ok<User>>());

      final Result<User> read = await repository.readByUsername('cashier1');
      expect(read.valueOrNull?.displayName, 'Cashier One');
      expect(read.valueOrNull?.roleCode, 'cashier');

      final List<AuditLogData> entries = await database
          .select(database.auditLog)
          .get();
      expect(entries, hasLength(1));
      expect(entries.single.action, 'user.created');
      expect(entries.single.entity, DriftUserRepository.auditEntity);
      expect(entries.single.entityId, 'user-1');

      final AuditChainStatus status = await audit.verifyChain();
      expect(status.isIntact, isTrue);
      expect(status.checkedEntries, 1);
    },
  );

  test('a newly created account has no credential until P1-03', () async {
    await repository.create(user: draft(), action: 'user.created');

    final Result<User> read = await repository.readById('user-1');

    expect(read.valueOrNull?.hasPassword, isFalse);
    expect(read.valueOrNull?.hasPin, isFalse);
  });

  test('the audit payload never carries PII or a credential hash', () async {
    await repository.create(
      user: draft(passwordHash: 'argon2id\$secret'),
      action: 'user.created',
      payload: <String, Object?>{'id': 'user-1', 'roleCode': 'cashier'},
    );

    final AuditLogData entry =
        (await database.select(database.auditLog).get()).single;
    expect(entry.payload, contains('user-1'));
    expect(entry.payload, contains('cashier'));
    expect(entry.payload, isNot(contains('cashier1')));
    expect(entry.payload, isNot(contains('argon2id')));
  });

  test('a duplicate username is refused and writes nothing', () async {
    await repository.create(user: draft(), action: 'user.created');

    final Result<User> duplicate = await repository.create(
      user: draft(id: 'user-2'),
      action: 'user.created',
    );

    expect(duplicate.failureOrNull, isA<ConflictFailure>());
    expect(duplicate.failureOrNull?.code, UserRepository.usernameTakenCode);
    expect(await database.select(database.users).get(), hasLength(1));
    expect(await database.select(database.auditLog).get(), hasLength(1));
  });

  test('an unknown role is refused with a validation failure', () async {
    final Result<User> created = await repository.create(
      user: draft(roleCode: 'ghost'),
      action: 'user.created',
    );

    expect(created.failureOrNull, isA<ValidationFailure>());
    expect(created.failureOrNull?.code, UserRepository.roleUnknownCode);
    expect(await database.select(database.users).get(), isEmpty);
    expect(await database.select(database.auditLog).get(), isEmpty);
  });

  test('readById reports not-found for an unknown id', () async {
    final Result<User> read = await repository.readById('ghost');

    expect(read.failureOrNull?.code, UserRepository.notFoundCode);
  });

  test(
    'disable marks the account disabled, audits once and keeps the row',
    () async {
      await repository.create(user: draft(), action: 'user.created');
      clock.advance(const Duration(minutes: 5));

      final Result<void> disabled = await repository.disable(
        id: 'user-1',
        action: 'user.disabled',
      );

      expect(disabled, isA<Ok<void>>());

      // Logically disabled, never deleted (P1-02 acceptance).
      final List<UserRow> rows = await database.select(database.users).get();
      expect(rows, hasLength(1));
      expect(rows.single.disabledAt?.toUtc(), DateTime.utc(2026, 5, 1, 0, 5));

      final List<AuditLogData> entries = await database
          .select(database.auditLog)
          .get();
      expect(entries, hasLength(2));
      expect(entries.last.action, 'user.disabled');
      expect(entries.last.entityId, 'user-1');
      expect((await audit.verifyChain()).isIntact, isTrue);
    },
  );

  test('disabling an already disabled account changes nothing', () async {
    await repository.create(user: draft(), action: 'user.created');
    await repository.disable(id: 'user-1', action: 'user.disabled');

    final Result<void> again = await repository.disable(
      id: 'user-1',
      action: 'user.disabled',
    );

    expect(again, isA<Ok<void>>());
    expect(await database.select(database.auditLog).get(), hasLength(2));
  });

  test('disabling an unknown account reports not-found', () async {
    final Result<void> disabled = await repository.disable(
      id: 'ghost',
      action: 'user.disabled',
    );

    expect(disabled.failureOrNull?.code, UserRepository.notFoundCode);
  });

  test('roles referenced by a user cannot be deleted out from under it', () async {
    await repository.create(user: draft(), action: 'user.created');

    // `PRAGMA foreign_keys = ON` (asserted in `AppDatabase.beforeOpen`) is what
    // makes the role reference safe, which is why `roles` is never hard-deleted.
    await expectLater(
      database
          .into(database.roles)
          .insert(
            RolesCompanion.insert(
              code: 'cashier',
              name: 'Duplicate',
              createdAt: clock.nowUtc(),
              isBuiltIn: const Value<bool>(false),
            ),
          ),
      throwsA(isA<Object>()),
    );
  });
}
