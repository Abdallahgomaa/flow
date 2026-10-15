import 'package:drift/drift.dart' show QueryExecutor;
import 'package:drift/native.dart';
import 'package:flow/core/database/database.dart';
import 'package:flow/core/database/database_providers.dart';
import 'package:flow/core/result/result.dart';
import 'package:flow/features/auth/data/argon2_password_hasher.dart';
import 'package:flow/features/auth/data/auth_providers.dart';
import 'package:flow/features/auth/data/session_notifier.dart';
import 'package:flow/features/auth/domain/user.dart';
import 'package:flow/features/auth/domain/user_role.dart';
import 'package:flow/features/auth/presentation/owner_setup_screen.dart';
import 'package:flow/shared/l10n/l10n.dart';
import 'package:flow/shared/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// An in-memory stand-in for the SQLCipher connector, so a widget test can drive
/// the real providers and the real database without touching the file system.
final class _MemoryConnector implements DatabaseConnector {
  @override
  QueryExecutor open() => NativeDatabase.memory(setup: DatabasePragmas.apply);
}

/// Drives the owner setup screen end to end: form in, encrypted account out,
/// session started, navigation reported.
void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer(
      overrides: [
        databaseConnectorProvider.overrideWith((Ref ref) => _MemoryConnector()),
        passwordHasherProvider.overrideWith(
          (Ref ref) => Argon2PasswordHasher(
            memoryKiB: 256,
            iterations: 1,
            parallelism: 1,
          ),
        ),
      ],
    );
    addTearDown(container.dispose);
  });

  Finder fieldWithLabel(String label) => find.descendant(
    of: find.ancestor(
      of: find.text(label),
      matching: find.byType(CustomTextField),
    ),
    matching: find.byType(TextFormField),
  );

  Future<void> pumpSetup(
    WidgetTester tester, {
    VoidCallback? onInitialised,
  }) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: kSupportedLocales,
          home: OwnerSetupScreen(onInitialised: onInitialised),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> submit(
    WidgetTester tester, {
    required String login,
    required String secret,
    required String confirm,
  }) async {
    final AppLocalizations l10n = AppLocalizations.of(
      tester.element(find.byType(OwnerSetupScreen)),
    );

    await tester.enterText(fieldWithLabel(l10n.ownerSetupUsernameLabel), login);
    await tester.enterText(fieldWithLabel(l10n.ownerSetupSecretLabel), secret);
    await tester.enterText(
      fieldWithLabel(l10n.ownerSetupConfirmLabel),
      confirm,
    );
    await tester.tap(find.byType(CustomButton));
    await tester.pumpAndSettle();
  }

  testWidgets('asks for an owner on an empty installation', (
    WidgetTester tester,
  ) async {
    await pumpSetup(tester);

    final AppLocalizations l10n = AppLocalizations.of(
      tester.element(find.byType(OwnerSetupScreen)),
    );

    expect(find.text(l10n.ownerSetupTitle), findsOneWidget);
    expect(find.byType(CustomTextField), findsNWidgets(3));
  });

  testWidgets('creates the owner, signs the session in and reports it', (
    WidgetTester tester,
  ) async {
    bool initialised = false;
    await pumpSetup(tester, onInitialised: () => initialised = true);

    await submit(
      tester,
      login: 'owner.one',
      secret: 'correct-horse',
      confirm: 'correct-horse',
    );

    expect(initialised, isTrue);
    expect(container.read(sessionProvider).isSignedIn, isTrue);
    expect(container.read(sessionProvider).user?.username, 'owner.one');

    final Result<List<User>> accounts = await container.read(
      allUsersProvider.future,
    );
    expect(accounts.valueOrNull, hasLength(1));
    expect(accounts.valueOrNull?.single.roleCode, UserRole.owner.code);
    // The stored credential is a hash, never the typed secret.
    expect(accounts.valueOrNull?.single.passwordHash, isNot('correct-horse'));
  });

  testWidgets('refuses mismatching secrets without creating an account', (
    WidgetTester tester,
  ) async {
    await pumpSetup(tester);

    await submit(
      tester,
      login: 'owner.one',
      secret: 'correct-horse',
      confirm: 'correct-horseX',
    );

    final AppLocalizations l10n = AppLocalizations.of(
      tester.element(find.byType(OwnerSetupScreen)),
    );

    expect(find.text(l10n.ownerSetupSecretMismatch), findsOneWidget);
    expect(container.read(sessionProvider).isSignedIn, isFalse);

    final Result<List<User>> accounts = await container.read(
      allUsersProvider.future,
    );
    expect(accounts.valueOrNull, isEmpty);
  });

  testWidgets('explains a secret that is too short', (
    WidgetTester tester,
  ) async {
    await pumpSetup(tester);

    await submit(tester, login: 'owner.one', secret: 'short', confirm: 'short');

    final AppLocalizations l10n = AppLocalizations.of(
      tester.element(find.byType(OwnerSetupScreen)),
    );

    expect(find.text(l10n.ownerSetupSecretTooShort), findsOneWidget);
    expect(container.read(sessionProvider).isSignedIn, isFalse);
  });
}
