import 'package:drift/native.dart';
import 'package:flow/core/database/database.dart';
import 'package:flow/core/result/result.dart';
import 'package:flow/core/utils/clock.dart';
import 'package:flow/core/utils/uuid_v7.dart';
import 'package:flow/features/auth/data/argon2_password_hasher.dart';
import 'package:flow/features/auth/data/drift_role_repository.dart';
import 'package:flow/features/auth/data/drift_user_repository.dart';
import 'package:flow/features/auth/domain/password_hasher.dart';
import 'package:flow/features/auth/domain/role.dart';
import 'package:flow/features/auth/domain/use_cases/initialize_owner.dart';
import 'package:flow/features/auth/domain/use_cases/seed_built_in_roles.dart';
import 'package:flow/features/auth/domain/user.dart';
import 'package:flow/features/auth/domain/user_role.dart';
import 'package:flutter_test/flutter_test.dart';

/// Covers the two setup use cases the owner screen drives: seeding the built-in
/// roles, then creating the very first account.
///
/// Both run against a real in-memory database and a real hasher, so the test
/// proves what production does, not what a fake would allow. The Argon2id cost
/// is dialled down: the contract under test is the setup flow, while the
/// calibrated parameters belong to `P1-03`.
void main() {
  late AppDatabase database;
  late FixedClock clock;
  late DriftRoleRepository roles;
  late PasswordHasher hasher;
  late SeedBuiltInRoles seedRoles;
  late InitializeOwner initializeOwner;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory(setup: DatabasePragmas.apply));
    clock = FixedClock(DateTime.utc(2026, 5, 1));
    final AuditService audit = AuditService(database: database, clock: clock);
    final DriftUnitOfWork unitOfWork = DriftUnitOfWork(database);
    roles = DriftRoleRepository(
      database: database,
      unitOfWork: unitOfWork,
      auditService: audit,
      clock: clock,
    );
    final DriftUserRepository users = DriftUserRepository(
      database: database,
      unitOfWork: unitOfWork,
      auditService: audit,
      clock: clock,
    );
    hasher = Argon2PasswordHasher(
      memoryKiB: 256,
      iterations: 1,
      parallelism: 1,
    );
    seedRoles = SeedBuiltInRoles(roles, clock);
    initializeOwner = InitializeOwner(
      users,
      hasher,
      UuidV7Generator(clock: clock),
      clock,
    );
  });

  tearDown(() => database.close());

  group('SeedBuiltInRoles', () {
    test('creates every built-in role once', () async {
      final Result<void> seeded = await seedRoles();

      expect(seeded.isOk, isTrue);

      final Result<List<Role>> stored = await roles.readAll();
      expect(
        stored.valueOrNull?.map((Role role) => role.code).toSet(),
        UserRole.values.map((UserRole role) => role.code).toSet(),
      );
      // Built-in roles must be flagged, so P1-02's guard can refuse to disable
      // them later.
      expect(stored.valueOrNull?.every((Role role) => role.isBuiltIn), isTrue);
    });

    test('is idempotent, so re-running setup writes nothing new', () async {
      await seedRoles();

      final Result<void> second = await seedRoles();

      expect(second.isOk, isTrue);
      final Result<List<Role>> stored = await roles.readAll();
      expect(stored.valueOrNull, hasLength(UserRole.values.length));
    });
  });

  group('InitializeOwner', () {
    setUp(() async {
      // The owner cannot be written before its role exists; the setup screen
      // runs the seeder first, and so does every test below.
      await seedRoles();
    });

    test('creates the owner with the owner role and a hashed secret', () async {
      final Result<User> created = await initializeOwner(
        username: 'owner.one',
        secret: 'correct-horse',
      );

      final User? owner = created.valueOrNull;
      expect(owner, isNotNull);
      expect(owner?.username, 'owner.one');
      expect(owner?.roleCode, UserRole.owner.code);
      expect(owner?.isDisabled, isFalse);

      // The secret itself must never reach the row.
      expect(owner?.passwordHash, isNotNull);
      expect(owner?.passwordHash, isNot('correct-horse'));
      expect(owner?.pinHash, isNull);

      final Result<bool> verified = await hasher.verify(
        secret: 'correct-horse',
        encodedHash: owner!.passwordHash!,
      );
      expect(verified.valueOrNull, isTrue);
    });

    test('trims the login name and reuses it as the display name', () async {
      final Result<User> created = await initializeOwner(
        username: '  owner.one  ',
        secret: 'correct-horse',
      );

      expect(created.valueOrNull?.username, 'owner.one');
      expect(created.valueOrNull?.displayName, 'owner.one');
    });

    test('accepts a secret exactly at the minimum length', () async {
      final Result<User> created = await initializeOwner(
        username: 'owner.one',
        secret: '12345678',
      );

      expect(created.isOk, isTrue);
    });

    test('refuses an empty login name', () async {
      final Result<User> created = await initializeOwner(
        username: '   ',
        secret: 'correct-horse',
      );

      expect(created.failureOrNull?.code, InitializeOwner.usernameRequiredCode);
    });

    test('refuses a malformed login name', () async {
      final Result<User> created = await initializeOwner(
        username: 'a b',
        secret: 'correct-horse',
      );

      expect(created.failureOrNull?.code, InitializeOwner.usernameInvalidCode);
    });

    test('refuses an empty secret', () async {
      final Result<User> created = await initializeOwner(
        username: 'owner.one',
        secret: '',
      );

      expect(created.failureOrNull?.code, InitializeOwner.secretRequiredCode);
    });

    test('refuses a secret shorter than the minimum', () async {
      final Result<User> created = await initializeOwner(
        username: 'owner.one',
        secret: 'short',
      );

      expect(created.failureOrNull?.code, InitializeOwner.secretTooShortCode);
    });

    test('refuses to create a second owner once an account exists', () async {
      await initializeOwner(username: 'owner.one', secret: 'correct-horse');

      final Result<User> second = await initializeOwner(
        username: 'owner.two',
        secret: 'correct-horse',
      );

      expect(
        second.failureOrNull?.code,
        InitializeOwner.alreadyInitialisedCode,
      );
    });
  });
}
