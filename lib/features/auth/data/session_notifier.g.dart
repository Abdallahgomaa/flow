// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The authorisation matrix a session resolves its permissions through.
///
/// It is a provider so `P1-14`'s custom roles can replace the implementation
/// without touching the session, and so a test can pin a matrix of its own.

@ProviderFor(roleMatrix)
final roleMatrixProvider = RoleMatrixProvider._();

/// The authorisation matrix a session resolves its permissions through.
///
/// It is a provider so `P1-14`'s custom roles can replace the implementation
/// without touching the session, and so a test can pin a matrix of its own.

final class RoleMatrixProvider
    extends $FunctionalProvider<RoleMatrix, RoleMatrix, RoleMatrix>
    with $Provider<RoleMatrix> {
  /// The authorisation matrix a session resolves its permissions through.
  ///
  /// It is a provider so `P1-14`'s custom roles can replace the implementation
  /// without touching the session, and so a test can pin a matrix of its own.
  RoleMatrixProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'roleMatrixProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$roleMatrixHash();

  @$internal
  @override
  $ProviderElement<RoleMatrix> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  RoleMatrix create(Ref ref) {
    return roleMatrix(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RoleMatrix value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RoleMatrix>(value),
    );
  }
}

String _$roleMatrixHash() => r'86d9559df0bcaedf83ab1c02d525a3aa5d97084f';

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

@ProviderFor(Session)
final sessionProvider = SessionProvider._();

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
final class SessionProvider extends $NotifierProvider<Session, SessionState> {
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
  SessionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sessionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sessionHash();

  @$internal
  @override
  Session create() => Session();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SessionState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SessionState>(value),
    );
  }
}

String _$sessionHash() => r'7c660768c062c9d75bad97ad415af05436c7284e';

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

abstract class _$Session extends $Notifier<SessionState> {
  SessionState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<SessionState, SessionState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SessionState, SessionState>,
              SessionState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// The permissions the current session holds.
///
/// Empty whenever nobody usable is signed in, and resolved against the matrix on
/// every read, so it cannot go stale.

@ProviderFor(sessionPermissions)
final sessionPermissionsProvider = SessionPermissionsProvider._();

/// The permissions the current session holds.
///
/// Empty whenever nobody usable is signed in, and resolved against the matrix on
/// every read, so it cannot go stale.

final class SessionPermissionsProvider
    extends
        $FunctionalProvider<Set<Permission>, Set<Permission>, Set<Permission>>
    with $Provider<Set<Permission>> {
  /// The permissions the current session holds.
  ///
  /// Empty whenever nobody usable is signed in, and resolved against the matrix on
  /// every read, so it cannot go stale.
  SessionPermissionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sessionPermissionsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sessionPermissionsHash();

  @$internal
  @override
  $ProviderElement<Set<Permission>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Set<Permission> create(Ref ref) {
    return sessionPermissions(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Set<Permission> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Set<Permission>>(value),
    );
  }
}

String _$sessionPermissionsHash() =>
    r'3c901a9d8d0464ab7764c7d946ef1d5d292d5cbf';
