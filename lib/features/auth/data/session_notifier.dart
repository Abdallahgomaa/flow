import 'package:flow/core/result/failure.dart';
import 'package:flow/core/result/result.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/permission.dart';
import '../domain/role_matrix.dart';
import '../domain/session_state.dart';
import '../domain/user.dart';
import '../domain/user_role.dart';

part 'session_notifier.g.dart';

/// The authorisation matrix a session resolves its permissions through.
///
/// It is a provider so `P1-14`'s custom roles can replace the implementation
/// without touching the session, and so a test can pin a matrix of its own.
@Riverpod(keepAlive: true)
RoleMatrix roleMatrix(Ref ref) => const DefaultRoleMatrix();

/// Who is using the till right now (`P1-04`).
///
/// The session is the single source of truth for the current user, their role,
/// their permissions and the active shift. It carries no UI, no `KeyManager` and
/// no database handle: the login screen (`P1-05`) signs in, the lock policy
/// (`P1-07`) locks, and every other feature reads.
///
/// Permissions are *derived* from [roleMatrixProvider] rather than copied into
/// the state, so editing the matrix can never leave a running session holding
/// authorisation it should no longer have.
@Riverpod(keepAlive: true)
class Session extends _$Session {
  /// Failure code returned by [signIn] for a disabled account.
  static const String disabledAccountCode = 'auth.accountDisabled';

  @override
  SessionState build() => const SessionState.signedOut();

  /// Starts a session for [user], optionally on the shift [activeShiftId].
  ///
  /// The state is replaced in a single assignment, so a session is never
  /// half-established. The role is resolved from the stored code and degrades to
  /// `null` — and therefore to no permissions — if that code is not a built-in
  /// role, which is what keeps `P1-14`'s custom roles from inheriting anything by
  /// accident.
  Result<void> signIn(User user, {String? activeShiftId}) {
    if (user.isDisabled) {
      return const Result<void>.err(
        ValidationFailure(
          message: 'This account is disabled.',
          code: disabledAccountCode,
        ),
      );
    }

    state = SessionState.signedIn(
      user: user,
      role: UserRole.fromCode(user.roleCode),
      activeShiftId: activeShiftId,
    );
    return const Result<void>.ok(null);
  }

  /// Ends the session completely; nothing about the account is kept.
  void signOut() => state = const SessionState.signedOut();

  /// Locks the session.
  ///
  /// Locking invalidates it: the account stays known so `P1-07` can offer a fast
  /// switch back to the same user, but every permission is withdrawn until
  /// [signIn] runs again.
  void lock() => state = state.lock();

  /// Records the shift this till is on, or clears it when [shiftId] is `null`.
  void setActiveShift(String? shiftId) =>
      state = state.withActiveShift(shiftId);
}

/// The permissions the current session holds.
///
/// Empty whenever nobody usable is signed in, and resolved against the matrix on
/// every read, so it cannot go stale.
@Riverpod(keepAlive: true)
Set<Permission> sessionPermissions(Ref ref) {
  final SessionState session = ref.watch(sessionProvider);
  final UserRole? role = session.role;
  if (!session.isSignedIn || role == null) {
    return const <Permission>{};
  }

  return ref.watch(roleMatrixProvider).permissionsFor(role);
}
