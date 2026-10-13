import 'package:flow/core/result/result.dart';
import 'package:flow/features/auth/data/session_notifier.dart';
import 'package:flow/features/auth/domain/permission.dart';
import 'package:flow/features/auth/domain/role_matrix.dart';
import 'package:flow/features/auth/domain/session_state.dart';
import 'package:flow/features/auth/domain/user.dart';
import 'package:flow/features/auth/domain/user_role.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // A minimal account fixture: the session only reads the identifier, the role
  // code and the disabled flag.
  User account(String roleCode, {String id = 'u1', DateTime? disabledAt}) =>
      User(
        id: id,
        username: 'sara',
        displayName: 'Sara',
        roleCode: roleCode,
        createdAt: DateTime.utc(2026, 1, 1),
        disabledAt: disabledAt,
      );

  ProviderContainer buildContainer({RoleMatrix? matrix}) {
    final ProviderContainer container = ProviderContainer(
      overrides: [
        // Always overridden, so a test never depends on the shipped matrix.
        roleMatrixProvider.overrideWith(
          (Ref ref) => matrix ?? const DefaultRoleMatrix(),
        ),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('Session', () {
    test('starts signed out with no authorisation', () {
      final ProviderContainer container = buildContainer();

      final SessionState session = container.read(sessionProvider);

      expect(session.isSignedIn, isFalse);
      expect(session.isLocked, isFalse);
      expect(session.user, isNull);
      expect(session.role, isNull);
      expect(session.activeShiftId, isNull);
      expect(session.hasOpenShift, isFalse);
      expect(container.read(sessionPermissionsProvider), isEmpty);
    });

    test('signing in resolves the role and grants that role permissions', () {
      final ProviderContainer container = buildContainer();

      final Result<void> signedIn = container
          .read(sessionProvider.notifier)
          .signIn(account(UserRole.owner.code));

      expect(signedIn.isOk, isTrue);
      final SessionState session = container.read(sessionProvider);
      expect(session.isSignedIn, isTrue);
      expect(session.role, UserRole.owner);
      expect(
        container.read(sessionPermissionsProvider),
        contains(Permission.userManage),
      );
    });

    test('the permissions come from the live matrix, not a stored copy', () {
      // The matrix is the single source of truth: swapping it must change what
      // the session is allowed to do, so a stale grant is impossible.
      final ProviderContainer container = buildContainer(
        matrix: const _StubRoleMatrix(<Permission>{Permission.auditView}),
      );

      container
          .read(sessionProvider.notifier)
          .signIn(account(UserRole.owner.code));

      expect(container.read(sessionPermissionsProvider), const <Permission>{
        Permission.auditView,
      });
    });

    test('a disabled account is refused and nothing changes', () {
      final ProviderContainer container = buildContainer();

      final Result<void> signedIn = container
          .read(sessionProvider.notifier)
          .signIn(
            account(UserRole.owner.code, disabledAt: DateTime.utc(2026, 2, 1)),
          );

      expect(signedIn.failureOrNull?.code, Session.disabledAccountCode);
      expect(container.read(sessionProvider).isSignedIn, isFalse);
      expect(container.read(sessionPermissionsProvider), isEmpty);
    });

    test('a role code that is not built in signs in without permissions', () {
      // A custom role (P1-14) the build does not know yet must fail closed
      // rather than throw or inherit somebody else's rights.
      final ProviderContainer container = buildContainer();

      container.read(sessionProvider.notifier).signIn(account('shift_lead'));

      final SessionState session = container.read(sessionProvider);
      expect(session.isSignedIn, isTrue);
      expect(session.role, isNull);
      expect(container.read(sessionPermissionsProvider), isEmpty);
    });

    test('signing out clears the account and every permission', () {
      final ProviderContainer container = buildContainer();
      final Session notifier = container.read(sessionProvider.notifier);
      notifier.signIn(account(UserRole.owner.code), activeShiftId: 'shift-1');

      notifier.signOut();

      final SessionState session = container.read(sessionProvider);
      expect(session.isSignedIn, isFalse);
      expect(session.user, isNull);
      expect(session.role, isNull);
      expect(session.activeShiftId, isNull);
      expect(container.read(sessionPermissionsProvider), isEmpty);
    });

    test('locking invalidates the session but remembers the account', () {
      final ProviderContainer container = buildContainer();
      final Session notifier = container.read(sessionProvider.notifier);
      notifier.signIn(account(UserRole.owner.code), activeShiftId: 'shift-1');

      notifier.lock();

      final SessionState session = container.read(sessionProvider);
      expect(session.isLocked, isTrue);
      expect(session.isSignedIn, isFalse);
      expect(session.hasOpenShift, isFalse);
      // Remembered on purpose so P1-07 can offer a fast switch back.
      expect(session.role, UserRole.owner);
      expect(session.activeShiftId, 'shift-1');
      // The acceptance criterion: locking withdraws every permission.
      expect(container.read(sessionPermissionsProvider), isEmpty);
    });

    test('switching users replaces the whole session', () {
      final ProviderContainer container = buildContainer();
      final Session notifier = container.read(sessionProvider.notifier);

      notifier.signIn(account(UserRole.owner.code), activeShiftId: 'shift-1');
      notifier.signIn(account(UserRole.cashier.code, id: 'u2'));

      final SessionState session = container.read(sessionProvider);
      expect(session.user?.id, 'u2');
      expect(session.role, UserRole.cashier);
      // Nothing from the previous session leaks into the new one.
      expect(session.activeShiftId, isNull);
      expect(
        container.read(sessionPermissionsProvider),
        contains(Permission.saleCreate),
      );
      expect(
        container.read(sessionPermissionsProvider),
        isNot(contains(Permission.userManage)),
      );
    });

    test('the active shift can be opened and closed', () {
      final ProviderContainer container = buildContainer();
      final Session notifier = container.read(sessionProvider.notifier);
      notifier.signIn(account(UserRole.cashier.code));

      notifier.setActiveShift('shift-7');
      expect(container.read(sessionProvider).hasOpenShift, isTrue);

      notifier.setActiveShift(null);
      final SessionState session = container.read(sessionProvider);
      expect(session.hasOpenShift, isFalse);
      expect(session.activeShiftId, isNull);
    });
  });
}

/// A stand-in matrix, so a test can prove the session asks the matrix instead
/// of assuming the built-in one.
final class _StubRoleMatrix implements RoleMatrix {
  const _StubRoleMatrix(this.granted);

  final Set<Permission> granted;

  @override
  Set<Permission> permissionsFor(UserRole role) => granted;

  @override
  bool allows(UserRole role, Permission permission) =>
      granted.contains(permission);
}
