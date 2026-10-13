import 'package:drift/native.dart';
import 'package:flow/core/database/database.dart';
import 'package:flow/core/result/failure.dart';
import 'package:flow/core/result/result.dart';
import 'package:flow/core/utils/clock.dart';
import 'package:flow/core/utils/uuid_v7.dart';
import 'package:flow/features/auth/data/drift_role_repository.dart';
import 'package:flow/features/auth/data/drift_user_repository.dart';
import 'package:flow/features/auth/domain/role.dart';
import 'package:flow/features/auth/domain/role_repository.dart';
import 'package:flow/features/auth/domain/use_cases/create_role.dart';
import 'package:flow/features/auth/domain/use_cases/create_user.dart';
import 'package:flow/features/auth/domain/use_cases/disable_role.dart';
import 'package:flow/features/auth/domain/use_cases/disable_user.dart';
import 'package:flow/features/auth/domain/use_cases/load_roles.dart';
import 'package:flow/features/auth/domain/use_cases/load_users.dart';
import 'package:flow/features/auth/domain/user.dart';
import 'package:flow/features/auth/domain/user_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase database;
  late FixedClock clock;
  late DriftRoleRepository roleRepository;
  late DriftUserRepository userRepository;
  late CreateRole createRole;
  late DisableRole disableRole;
  late LoadRoles loadRoles;
  late CreateUser createUser;
  late DisableUser disableUser;
  late LoadUsers loadUsers;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory(setup: DatabasePragmas.apply));
    clock = FixedClock(DateTime.utc(2026, 5, 1));
    final AuditService audit = AuditService(database: database, clock: clock);
    final DriftUnitOfWork unitOfWork = DriftUnitOfWork(database);
    roleRepository = DriftRoleRepository(
      database: database,
      unitOfWork: unitOfWork,
      auditService: audit,
      clock: clock,
    );
    userRepository = DriftUserRepository(
      database: database,
      unitOfWork: unitOfWork,
      auditService: audit,
      clock: clock,
    );
    createRole = CreateRole(roleRepository);
    disableRole = DisableRole(roleRepository);
    loadRoles = LoadRoles(roleRepository);
    createUser = CreateUser(
      userRepository,
      UuidV7Generator(clock: clock),
      clock,
    );
    disableUser = DisableUser(userRepository);
    loadUsers = LoadUsers(userRepository);
  });

  tearDown(() => database.close());

  Role draft(String code, {String name = 'Manager'}) =>
      Role(code: code, name: name, createdAt: clock.nowUtc());

  group('CreateRole', () {
    test('normalises and persists a valid role', () async {
      final Result<Role> created = await createRole(
        draft('  Manager.Ops  ', name: '  Ops Manager  '),
      );

      expect(created.valueOrNull?.code, 'manager.ops');
      expect(created.valueOrNull?.name, 'Ops Manager');
      expect((await loadRoles()).valueOrNull, hasLength(1));
    });

    test('rejects a blank code', () async {
      final Result<Role> created = await createRole(draft('   '));

      expect(created.failureOrNull, isA<ValidationFailure>());
      expect(created.failureOrNull?.code, CreateRole.codeRequiredCode);
    });

    test('rejects a malformed code', () async {
      final Result<Role> created = await createRole(draft('Manager Ops!'));

      expect(created.failureOrNull?.code, CreateRole.codeInvalidCode);
    });

    test('rejects a blank name', () async {
      final Result<Role> created = await createRole(
        draft('manager', name: ' '),
      );

      expect(created.failureOrNull?.code, CreateRole.nameRequiredCode);
    });

    test('rejects a code that is already taken', () async {
      await createRole(draft('manager'));

      final Result<Role> duplicate = await createRole(draft('manager'));

      expect(duplicate.failureOrNull?.code, RoleRepository.codeTakenCode);
    });
  });

  group('DisableRole', () {
    test('disables an existing role', () async {
      await createRole(draft('manager'));

      final Result<void> disabled = await disableRole('manager');

      expect(disabled, isA<Ok<void>>());
      expect((await loadRoles()).valueOrNull?.single.isDisabled, isTrue);
    });

    test('rejects a blank code', () async {
      final Result<void> disabled = await disableRole('  ');

      expect(disabled.failureOrNull?.code, DisableRole.codeRequiredCode);
    });
  });

  group('CreateUser', () {
    setUp(() async {
      await createRole(draft('cashier', name: 'Cashier'));
    });

    test('generates a UUID v7 identity and persists the account', () async {
      final Result<User> created = await createUser(
        username: 'Cashier1',
        displayName: 'Cashier One',
        roleCode: 'cashier',
      );

      final User? user = created.valueOrNull;
      expect(user, isNotNull);
      // The id is a real UUID v7: its creation timestamp round-trips.
      expect(UuidV7Generator.timestampOf(user!.id), isNotNull);
      expect(user.username, 'Cashier1');
      expect(user.displayName, 'Cashier One');
      expect(user.roleCode, 'cashier');
      expect(user.createdAt, DateTime.utc(2026, 5, 1));
      expect((await loadUsers()).valueOrNull, hasLength(1));
    });

    test('gives every account a distinct id', () async {
      final Result<User> first = await createUser(
        username: 'one',
        displayName: 'One',
        roleCode: 'cashier',
      );
      final Result<User> second = await createUser(
        username: 'two',
        displayName: 'Two',
        roleCode: 'cashier',
      );

      expect(first.valueOrNull?.id, isNot(second.valueOrNull?.id));
    });

    test('rejects a blank username', () async {
      final Result<User> created = await createUser(
        username: '  ',
        displayName: 'Cashier',
        roleCode: 'cashier',
      );

      expect(created.failureOrNull?.code, CreateUser.usernameRequiredCode);
    });

    test('rejects a username that is too short', () async {
      final Result<User> created = await createUser(
        username: 'ab',
        displayName: 'Cashier',
        roleCode: 'cashier',
      );

      expect(created.failureOrNull?.code, CreateUser.usernameInvalidCode);
    });

    test('rejects a blank display name', () async {
      final Result<User> created = await createUser(
        username: 'cashier1',
        displayName: '   ',
        roleCode: 'cashier',
      );

      expect(created.failureOrNull?.code, CreateUser.nameRequiredCode);
    });

    test('rejects a blank role', () async {
      final Result<User> created = await createUser(
        username: 'cashier1',
        displayName: 'Cashier',
        roleCode: '  ',
      );

      expect(created.failureOrNull?.code, CreateUser.roleRequiredCode);
    });

    test('rejects a role that does not exist', () async {
      final Result<User> created = await createUser(
        username: 'cashier1',
        displayName: 'Cashier',
        roleCode: 'ghost',
      );

      expect(created.failureOrNull?.code, UserRepository.roleUnknownCode);
    });

    test('rejects a username that is already taken', () async {
      await createUser(
        username: 'cashier1',
        displayName: 'Cashier',
        roleCode: 'cashier',
      );

      final Result<User> duplicate = await createUser(
        username: 'cashier1',
        displayName: 'Other',
        roleCode: 'cashier',
      );

      expect(duplicate.failureOrNull?.code, UserRepository.usernameTakenCode);
    });
  });

  group('DisableUser', () {
    test('disables an existing account', () async {
      await createRole(draft('cashier', name: 'Cashier'));
      final Result<User> created = await createUser(
        username: 'cashier1',
        displayName: 'Cashier',
        roleCode: 'cashier',
      );

      final Result<void> disabled = await disableUser(created.valueOrNull!.id);

      expect(disabled, isA<Ok<void>>());
      expect((await loadUsers()).valueOrNull?.single.isDisabled, isTrue);
    });

    test('rejects a blank id', () async {
      final Result<void> disabled = await disableUser('  ');

      expect(disabled.failureOrNull?.code, DisableUser.idRequiredCode);
    });
  });
}
