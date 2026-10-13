/// The immutable state of a signed-in session (`P1-04`).
///
/// Pure Dart on purpose: this is the value every feature *reads*, and a feature
/// may only reach another feature through its `domain/` or its barrel, so the
/// value must not drag Riverpod, Drift or Flutter along. The controller that
/// mutates it lives in `lib/features/auth/data/session_notifier.dart`.
library;

import 'user.dart';
import 'user_role.dart';

/// Who is using the till, which role they hold, and whether the session is
/// locked.
///
/// Every transition returns a new instance instead of mutating one, so `==` and
/// `hashCode` describe the whole state and listeners only rebuild when something
/// genuinely changed.
final class SessionState {
  const SessionState._({
    this.user,
    this.role,
    this.activeShiftId,
    this.isLocked = false,
  });

  /// Nobody is signed in: no user, no role, no shift.
  const SessionState.signedOut() : this._();

  /// A session for [user].
  ///
  /// [role] is `null` when the account's stored role code is not one of the
  /// built-in roles — a custom role that `P1-14` will introduce. An unresolved
  /// role deliberately yields no permissions at all, so the session fails closed
  /// instead of guessing what the account may do.
  const SessionState.signedIn({
    required User user,
    required UserRole? role,
    String? activeShiftId,
  }) : this._(user: user, role: role, activeShiftId: activeShiftId);

  /// The signed-in account, or `null` when nobody is signed in.
  final User? user;

  /// The account's role resolved against the built-in roles, or `null` when it
  /// could not be resolved (see [SessionState.signedIn]).
  ///
  /// It is deliberately kept while locked, so `P1-07` can offer a fast switch
  /// back to the same account.
  final UserRole? role;

  /// The shift the till is currently on, or `null` when none is open.
  ///
  /// Only the identifier is held here: the `Shift` entity belongs to `P3-11`,
  /// and until then the session only has to answer "is a shift open?".
  final String? activeShiftId;

  /// Whether an authenticated account is locked out until it signs in again.
  final bool isLocked;

  /// Whether this session may be used right now.
  ///
  /// A locked session is **not** signed in, so locking invalidates it: no
  /// permission is granted until a fresh sign-in.
  bool get isSignedIn => user != null && !isLocked;

  /// Whether a usable session has a shift open.
  bool get hasOpenShift => isSignedIn && activeShiftId != null;

  /// The same session, locked.
  ///
  /// Returns itself when nothing would change, so locking twice is free and
  /// never notifies listeners.
  SessionState lock() => !isLocked && user != null
      ? SessionState._(
          user: user,
          role: role,
          activeShiftId: activeShiftId,
          isLocked: true,
        )
      : this;

  /// The same session pointed at [shiftId], or at no shift when `null`.
  ///
  /// A session with no account has nowhere to record a shift, so it is returned
  /// unchanged in that case.
  SessionState withActiveShift(String? shiftId) =>
      user != null && shiftId != activeShiftId
      ? SessionState._(
          user: user,
          role: role,
          activeShiftId: shiftId,
          isLocked: isLocked,
        )
      : this;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SessionState &&
          other.user == user &&
          other.role == role &&
          other.activeShiftId == activeShiftId &&
          other.isLocked == isLocked;

  @override
  int get hashCode => Object.hash(user, role, activeShiftId, isLocked);

  @override
  String toString() =>
      'SessionState(user: ${user?.username}, role: ${role?.code}, '
      'activeShiftId: $activeShiftId, isLocked: $isLocked)';
}
