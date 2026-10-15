import 'package:drift/drift.dart' show QueryExecutor;
import 'package:drift/native.dart';
import 'package:flow/app/router/router.dart';
import 'package:flow/core/database/database.dart';
import 'package:flow/core/database/database_providers.dart';
import 'package:flow/core/result/result.dart';
import 'package:flow/features/auth/data/argon2_password_hasher.dart';
import 'package:flow/features/auth/data/auth_providers.dart';
import 'package:flow/features/auth/domain/user.dart';
import 'package:flow/features/auth/presentation/login_screen.dart';
import 'package:flow/features/auth/presentation/owner_setup_screen.dart';
import 'package:flow/shared/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

/// An in-memory stand-in for the SQLCipher connector.
final class _MemoryConnector implements DatabaseConnector {
  @override
  QueryExecutor open() => NativeDatabase.memory(setup: DatabasePragmas.apply);
}

/// Proves the provisional first-run gate: a brand-new installation is sent to
/// the owner setup instead of the sign-in screen, and stops being sent there as
/// soon as an account exists.
///
/// The gate is deliberately coarse. Permission checks and the real redirect
/// rules arrive with `P1-09`; what is pinned down here is the one behaviour an
/// empty installation must not get wrong.
void main() {
  late ProviderContainer container;
  late GoRouter router;

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

  Future<void> pumpApp(WidgetTester tester) async {
    // The gate reads the account list, so resolve that read before the router is
    // created: the first frame then sees a settled answer, exactly as the widget
    // layer does once the initial load finishes.
    await container.read(allUsersProvider.future);
    router = container.read(appRouterProvider);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: kSupportedLocales,
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('an empty installation is sent to the owner setup', (
    WidgetTester tester,
  ) async {
    await pumpApp(tester);

    expect(container.read(ownerSetupRequiredProvider), isTrue);
    expect(find.byType(OwnerSetupScreen), findsOneWidget);
    expect(find.byType(LoginScreen), findsNothing);
  });

  testWidgets('every location is gated while no account exists', (
    WidgetTester tester,
  ) async {
    await pumpApp(tester);

    router.go(AppRoutes.dev);
    await tester.pumpAndSettle();

    expect(find.byType(OwnerSetupScreen), findsOneWidget);
  });

  testWidgets('an installation with an owner opens on the sign-in screen', (
    WidgetTester tester,
  ) async {
    await container.read(seedBuiltInRolesProvider)();
    final Result<User> created = await container.read(initializeOwnerProvider)(
      username: 'owner.one',
      secret: 'correct-horse',
    );
    expect(created.isOk, isTrue);

    await pumpApp(tester);

    expect(container.read(ownerSetupRequiredProvider), isFalse);
    expect(find.byType(OwnerSetupScreen), findsNothing);
    expect(find.byType(LoginScreen), findsOneWidget);
  });
}
