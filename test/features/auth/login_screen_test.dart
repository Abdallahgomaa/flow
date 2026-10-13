import 'package:drift/drift.dart' show QueryExecutor;
import 'package:drift/native.dart';
import 'package:flow/core/database/database.dart';
import 'package:flow/core/database/database_providers.dart';
import 'package:flow/core/result/result.dart';
import 'package:flow/core/utils/clock.dart';
import 'package:flow/features/auth/data/argon2_password_hasher.dart';
import 'package:flow/features/auth/data/auth_providers.dart';
import 'package:flow/features/auth/data/drift_role_repository.dart';
import 'package:flow/features/auth/data/drift_user_repository.dart';
import 'package:flow/features/auth/data/session_notifier.dart';
import 'package:flow/features/auth/domain/password_hasher.dart';
import 'package:flow/features/auth/domain/role.dart';
import 'package:flow/features/auth/domain/user.dart';
import 'package:flow/features/auth/presentation/login_screen.dart';
import 'package:flow/shared/l10n/l10n.dart';
import 'package:flow/shared/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Opens an in-memory database so the screen can be pumped without a device.
final class _MemoryConnector implements DatabaseConnector {
  @override
  QueryExecutor open() => NativeDatabase.memory(setup: DatabasePragmas.apply);
}

void main() {
  const String roleCode = 'owner';
  const String username = 'owner.one';
  const String password = 'correct-horse';

  late ProviderContainer container;
  late AppDatabase database;
  late FixedClock clock;
  late DriftUserRepository users;
  late DriftRoleRepository roles;
  late PasswordHasher hasher;

  setUp(() {
    final PasswordHasher cheapHasher = Argon2PasswordHasher(
      memoryKiB: 256,
      iterations: 1,
      parallelism: 1,
    );
    hasher = cheapHasher;

    container = ProviderContainer(
      overrides: [
        databaseConnectorProvider.overrideWith((Ref ref) => _MemoryConnector()),
        // The calibrated cost measured in `P1-03` would only slow the widget
        // test down; the screen's behaviour does not depend on it.
        passwordHasherProvider.overrideWith((Ref ref) => cheapHasher),
      ],
    );
    addTearDown(container.dispose);

    database = container.read(appDatabaseProvider);
    clock = FixedClock(DateTime.utc(2026, 5, 1));

    final AuditService audit = AuditService(database: database, clock: clock);
    final DriftUnitOfWork unitOfWork = DriftUnitOfWork(database);

    users = DriftUserRepository(
      database: database,
      unitOfWork: unitOfWork,
      auditService: audit,
      clock: clock,
    );
    roles = DriftRoleRepository(
      database: database,
      unitOfWork: unitOfWork,
      auditService: audit,
      clock: clock,
    );
  });

  /// Stores a role and an account that carries a real Argon2id hash.
  ///
  /// Disabling is its own audited operation, so a disabled owner is created and
  /// then disabled.
  Future<void> seedOwner({bool disabled = false}) async {
    await roles.create(
      role: Role(code: roleCode, name: 'Owner', createdAt: clock.nowUtc()),
      action: 'role.created',
    );

    final Result<String> encoded = await hasher.hash(password);
    await users.create(
      user: User(
        id: 'user-1',
        username: username,
        displayName: 'Owner One',
        roleCode: roleCode,
        createdAt: clock.nowUtc(),
        passwordHash: encoded.valueOrNull,
      ),
      action: 'user.created',
    );
    if (disabled) {
      await users.disable(id: 'user-1', action: 'user.disabled');
    }
  }

  Future<void> pumpLogin(
    WidgetTester tester, {
    VoidCallback? onSignedIn,
  }) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: kSupportedLocales,
          home: LoginScreen(onSignedIn: onSignedIn),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// The text field that carries the given [label] in its decoration.
  Finder fieldWithLabel(String label) => find.descendant(
    of: find.ancestor(
      of: find.text(label),
      matching: find.byType(CustomTextField),
    ),
    matching: find.byType(TextFormField),
  );

  Future<void> submit(
    WidgetTester tester, {
    required String login,
    required String secret,
  }) async {
    final AppLocalizations l10n = AppLocalizations.of(
      tester.element(find.byType(LoginScreen)),
    );
    await tester.enterText(fieldWithLabel(l10n.loginUsernameLabel), login);
    await tester.enterText(fieldWithLabel(l10n.loginSecretLabel), secret);
    await tester.tap(find.byType(CustomButton));
    await tester.pumpAndSettle();
  }

  testWidgets(
    'starts the session and reports it back when the secret matches',
    (WidgetTester tester) async {
      await seedOwner();
      bool left = false;

      await pumpLogin(tester, onSignedIn: () => left = true);
      await submit(tester, login: username, secret: password);

      expect(left, isTrue);
      expect(container.read(sessionProvider).isSignedIn, isTrue);
      expect(container.read(sessionProvider).user?.username, username);
    },
  );

  testWidgets('keeps the session closed and explains a wrong secret', (
    WidgetTester tester,
  ) async {
    await seedOwner();
    bool left = false;

    await pumpLogin(tester, onSignedIn: () => left = true);
    await submit(tester, login: username, secret: 'not-the-password');

    final AppLocalizations l10n = AppLocalizations.of(
      tester.element(find.byType(LoginScreen)),
    );

    expect(left, isFalse);
    expect(container.read(sessionProvider).isSignedIn, isFalse);
    expect(find.text(l10n.loginInvalidCredentials), findsOneWidget);
  });

  testWidgets('explains a disabled account only after the right secret', (
    WidgetTester tester,
  ) async {
    await seedOwner(disabled: true);

    await pumpLogin(tester);
    await submit(tester, login: username, secret: password);

    final AppLocalizations l10n = AppLocalizations.of(
      tester.element(find.byType(LoginScreen)),
    );

    expect(container.read(sessionProvider).isSignedIn, isFalse);
    expect(find.text(l10n.loginAccountDisabled), findsOneWidget);
  });

  testWidgets('asks for both fields before touching the database', (
    WidgetTester tester,
  ) async {
    await pumpLogin(tester);

    await tester.tap(find.byType(CustomButton));
    await tester.pumpAndSettle();

    final AppLocalizations l10n = AppLocalizations.of(
      tester.element(find.byType(LoginScreen)),
    );

    expect(find.text(l10n.loginUsernameRequired), findsOneWidget);
  });
}
