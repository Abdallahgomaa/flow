import 'package:drift/native.dart';
import 'package:flow/core/database/database.dart';
import 'package:flow/core/result/result.dart';
import 'package:flow/core/utils/clock.dart';
import 'package:flow/features/auth/data/argon2_password_hasher.dart';
import 'package:flow/features/auth/data/drift_role_repository.dart';
import 'package:flow/features/auth/data/drift_user_repository.dart';
import 'package:flow/features/auth/domain/password_hasher.dart';
import 'package:flow/features/auth/domain/role.dart';
import 'package:flow/features/auth/domain/use_cases/sign_in.dart';
import 'package:flow/features/auth/domain/user.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const String roleCode = 'owner';
  const String username = 'owner.one';
  const String password = 'correct-horse';
  const String pin = '4821';

  late AppDatabase database;
  late FixedClock clock;
  late DriftUserRepository users;
  late PasswordHasher hasher;
  late SignIn signIn;

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory(setup: DatabasePragmas.apply));
    clock = FixedClock(DateTime.utc(2026, 5, 1));

    final AuditService audit = AuditService(database: database, clock: clock);
    final DriftUnitOfWork unitOfWork = DriftUnitOfWork(database);

    users = DriftUserRepository(
      database: database,
      unitOfWork: unitOfWork,
      auditService: audit,
      clock: clock,
    );
    // Cheap Argon2id parameters: these tests assert the sign-in contract, not
    // the calibrated cost measured in `P1-03`, so a light cost keeps them fast.
    hasher = Argon2PasswordHasher(
      memoryKiB: 256,
      iterations: 1,
      parallelism: 1,
    );
    signIn = SignIn(users, hasher);

    // A role must exist before an account can reference it. The account rows are
    // written straight through the repository because no use case can store a
    // credential yet — that arrives with `P1-11`.
    await DriftRoleRepository(
      database: database,
      unitOfWork: unitOfWork,
      auditService: audit,
      clock: clock,
    ).create(
      role: Role(code: roleCode, name: 'Owner', createdAt: clock.nowUtc()),
      action: 'role.created',
    );
  });

  tearDown(() => database.close());

  /// Encodes [secret] the way the app stores it.
  Future<String> hashOf(String secret) async {
    final Result<String> encoded = await hasher.hash(secret);
    return switch (encoded) {
      Ok<String>(:final String value) => value,
      Err<String>() => fail('Hashing a test secret failed.'),
    };
  }

  /// Stores an account whose credentials are real Argon2id hashes.
  ///
  /// A disabled account is created and then disabled, because disabling is its
  /// own audited operation rather than a field of creation.
  Future<User> seedAccount({
    bool withPassword = false,
    bool withPin = false,
    bool disabled = false,
  }) async {
    final User account = User(
      id: 'user-1',
      username: username,
      displayName: 'Owner One',
      roleCode: roleCode,
      createdAt: clock.nowUtc(),
      passwordHash: withPassword ? await hashOf(password) : null,
      pinHash: withPin ? await hashOf(pin) : null,
    );

    final Result<User> stored = await users.create(
      user: account,
      action: 'user.created',
    );
    if (disabled) {
      await users.disable(id: account.id, action: 'user.disabled');
    }
    return stored.valueOrNull ?? account;
  }

  test('signs in with the stored password', () async {
    await seedAccount(withPassword: true);

    final Result<User> result = await signIn(
      username: username,
      secret: password,
    );

    expect(result.valueOrNull?.username, username);
  });

  test('signs in with the stored PIN', () async {
    await seedAccount(withPin: true);

    final Result<User> result = await signIn(username: username, secret: pin);

    expect(result.valueOrNull?.username, username);
  });

  test('accepts either credential when the account holds both', () async {
    await seedAccount(withPassword: true, withPin: true);

    final Result<User> byPassword = await signIn(
      username: username,
      secret: password,
    );
    final Result<User> byPin = await signIn(username: username, secret: pin);

    expect(byPassword.valueOrNull?.username, username);
    expect(byPin.valueOrNull?.username, username);
  });

  test('ignores surrounding whitespace in the login name', () async {
    await seedAccount(withPassword: true);

    final Result<User> result = await signIn(
      username: '  $username  ',
      secret: password,
    );

    expect(result.valueOrNull?.username, username);
  });

  test('refuses a wrong secret', () async {
    await seedAccount(withPassword: true);

    final Result<User> result = await signIn(
      username: username,
      secret: 'not-the-password',
    );

    expect(result.failureOrNull?.code, SignIn.invalidCredentialsCode);
  });

  test('answers an unknown account exactly like a wrong secret', () async {
    await seedAccount(withPassword: true);

    final Result<User> unknown = await signIn(
      username: 'nobody.here',
      secret: password,
    );

    // Same code as a wrong secret: the screen must never reveal which login
    // names exist.
    expect(unknown.failureOrNull?.code, SignIn.invalidCredentialsCode);
  });

  test('refuses an account that holds no credential yet', () async {
    await seedAccount();

    final Result<User> result = await signIn(username: username, secret: pin);

    expect(result.failureOrNull?.code, SignIn.invalidCredentialsCode);
  });

  test('reports a disabled account only after a correct secret', () async {
    await seedAccount(withPassword: true, disabled: true);

    final Result<User> wrongSecret = await signIn(
      username: username,
      secret: 'not-the-password',
    );
    final Result<User> correctSecret = await signIn(
      username: username,
      secret: password,
    );

    expect(wrongSecret.failureOrNull?.code, SignIn.invalidCredentialsCode);
    expect(correctSecret.failureOrNull?.code, SignIn.accountDisabledCode);
  });

  test('requires a login name', () async {
    await seedAccount(withPassword: true);

    final Result<User> result = await signIn(username: '   ', secret: password);

    expect(result.failureOrNull?.code, SignIn.usernameRequiredCode);
  });

  test('requires a secret', () async {
    await seedAccount(withPassword: true);

    final Result<User> result = await signIn(username: username, secret: '');

    expect(result.failureOrNull?.code, SignIn.secretRequiredCode);
  });
}
