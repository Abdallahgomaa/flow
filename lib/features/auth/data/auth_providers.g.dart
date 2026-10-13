// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The role repository used by the auth feature.
///
/// It is the single bridge between the database providers in `core` and the
/// role tables, so no widget ever constructs a repository by hand.

@ProviderFor(roleRepository)
final roleRepositoryProvider = RoleRepositoryProvider._();

/// The role repository used by the auth feature.
///
/// It is the single bridge between the database providers in `core` and the
/// role tables, so no widget ever constructs a repository by hand.

final class RoleRepositoryProvider
    extends $FunctionalProvider<RoleRepository, RoleRepository, RoleRepository>
    with $Provider<RoleRepository> {
  /// The role repository used by the auth feature.
  ///
  /// It is the single bridge between the database providers in `core` and the
  /// role tables, so no widget ever constructs a repository by hand.
  RoleRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'roleRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$roleRepositoryHash();

  @$internal
  @override
  $ProviderElement<RoleRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  RoleRepository create(Ref ref) {
    return roleRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RoleRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RoleRepository>(value),
    );
  }
}

String _$roleRepositoryHash() => r'6cf75bce7c233db8c68c9c1a0665617435ad5f7c';

/// The user repository used by the auth feature.

@ProviderFor(userRepository)
final userRepositoryProvider = UserRepositoryProvider._();

/// The user repository used by the auth feature.

final class UserRepositoryProvider
    extends $FunctionalProvider<UserRepository, UserRepository, UserRepository>
    with $Provider<UserRepository> {
  /// The user repository used by the auth feature.
  UserRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userRepositoryHash();

  @$internal
  @override
  $ProviderElement<UserRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  UserRepository create(Ref ref) {
    return userRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UserRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UserRepository>(value),
    );
  }
}

String _$userRepositoryHash() => r'7e179f9ecb2dc02ac7195254e594ae31c6a565c0';

/// Hashes and verifies login passwords and quick-unlock PINs.
///
/// `keepAlive` so the calibrated cost is built once per process, not per call.

@ProviderFor(passwordHasher)
final passwordHasherProvider = PasswordHasherProvider._();

/// Hashes and verifies login passwords and quick-unlock PINs.
///
/// `keepAlive` so the calibrated cost is built once per process, not per call.

final class PasswordHasherProvider
    extends $FunctionalProvider<PasswordHasher, PasswordHasher, PasswordHasher>
    with $Provider<PasswordHasher> {
  /// Hashes and verifies login passwords and quick-unlock PINs.
  ///
  /// `keepAlive` so the calibrated cost is built once per process, not per call.
  PasswordHasherProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'passwordHasherProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$passwordHasherHash();

  @$internal
  @override
  $ProviderElement<PasswordHasher> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PasswordHasher create(Ref ref) {
    return passwordHasher(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PasswordHasher value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PasswordHasher>(value),
    );
  }
}

String _$passwordHasherHash() => r'7c67002d503d17b0c2420e9a93268f005d0ce292';

/// Reads every role, including the disabled ones.

@ProviderFor(loadRoles)
final loadRolesProvider = LoadRolesProvider._();

/// Reads every role, including the disabled ones.

final class LoadRolesProvider
    extends $FunctionalProvider<LoadRoles, LoadRoles, LoadRoles>
    with $Provider<LoadRoles> {
  /// Reads every role, including the disabled ones.
  LoadRolesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'loadRolesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$loadRolesHash();

  @$internal
  @override
  $ProviderElement<LoadRoles> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LoadRoles create(Ref ref) {
    return loadRoles(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LoadRoles value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LoadRoles>(value),
    );
  }
}

String _$loadRolesHash() => r'86427bde577e1c6935a9e28aa30a135b61437955';

/// Creates a role after validating its code and name.

@ProviderFor(createRole)
final createRoleProvider = CreateRoleProvider._();

/// Creates a role after validating its code and name.

final class CreateRoleProvider
    extends $FunctionalProvider<CreateRole, CreateRole, CreateRole>
    with $Provider<CreateRole> {
  /// Creates a role after validating its code and name.
  CreateRoleProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'createRoleProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$createRoleHash();

  @$internal
  @override
  $ProviderElement<CreateRole> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CreateRole create(Ref ref) {
    return createRole(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CreateRole value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CreateRole>(value),
    );
  }
}

String _$createRoleHash() => r'1cbb7e686a1185e73e5f3f71b6bb8843b0b223be';

/// Disables a role. Built-in roles are refused.

@ProviderFor(disableRole)
final disableRoleProvider = DisableRoleProvider._();

/// Disables a role. Built-in roles are refused.

final class DisableRoleProvider
    extends $FunctionalProvider<DisableRole, DisableRole, DisableRole>
    with $Provider<DisableRole> {
  /// Disables a role. Built-in roles are refused.
  DisableRoleProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'disableRoleProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$disableRoleHash();

  @$internal
  @override
  $ProviderElement<DisableRole> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DisableRole create(Ref ref) {
    return disableRole(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DisableRole value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DisableRole>(value),
    );
  }
}

String _$disableRoleHash() => r'17e3a65baf4735664711c30f0ceabc41a2c98cba';

/// Reads every user account, including the disabled ones.

@ProviderFor(loadUsers)
final loadUsersProvider = LoadUsersProvider._();

/// Reads every user account, including the disabled ones.

final class LoadUsersProvider
    extends $FunctionalProvider<LoadUsers, LoadUsers, LoadUsers>
    with $Provider<LoadUsers> {
  /// Reads every user account, including the disabled ones.
  LoadUsersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'loadUsersProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$loadUsersHash();

  @$internal
  @override
  $ProviderElement<LoadUsers> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LoadUsers create(Ref ref) {
    return loadUsers(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LoadUsers value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LoadUsers>(value),
    );
  }
}

String _$loadUsersHash() => r'939c8ff3579e008e4b6649cd3aa65766082f95b0';

/// Creates a user account, generating its identifier.

@ProviderFor(createUser)
final createUserProvider = CreateUserProvider._();

/// Creates a user account, generating its identifier.

final class CreateUserProvider
    extends $FunctionalProvider<CreateUser, CreateUser, CreateUser>
    with $Provider<CreateUser> {
  /// Creates a user account, generating its identifier.
  CreateUserProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'createUserProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$createUserHash();

  @$internal
  @override
  $ProviderElement<CreateUser> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CreateUser create(Ref ref) {
    return createUser(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CreateUser value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CreateUser>(value),
    );
  }
}

String _$createUserHash() => r'08cd981d061e6b6da9c7423a4a7c440eed479b94';

/// Disables a user account. The row is never deleted.

@ProviderFor(disableUser)
final disableUserProvider = DisableUserProvider._();

/// Disables a user account. The row is never deleted.

final class DisableUserProvider
    extends $FunctionalProvider<DisableUser, DisableUser, DisableUser>
    with $Provider<DisableUser> {
  /// Disables a user account. The row is never deleted.
  DisableUserProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'disableUserProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$disableUserHash();

  @$internal
  @override
  $ProviderElement<DisableUser> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DisableUser create(Ref ref) {
    return disableUser(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DisableUser value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DisableUser>(value),
    );
  }
}

String _$disableUserHash() => r'a53800e288538ba3848cae65bb1b8b60f8bbb1ea';
