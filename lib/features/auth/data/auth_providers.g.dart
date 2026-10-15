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

/// Every account, read straight from the database.
///
/// The synchronous `loadUsers` hands out the use case; this provider runs it, so
/// a widget or the router can watch the result without calling into the database
/// itself. Kept alive so a single read serves the whole session.

@ProviderFor(allUsers)
final allUsersProvider = AllUsersProvider._();

/// Every account, read straight from the database.
///
/// The synchronous `loadUsers` hands out the use case; this provider runs it, so
/// a widget or the router can watch the result without calling into the database
/// itself. Kept alive so a single read serves the whole session.

final class AllUsersProvider
    extends
        $FunctionalProvider<
          AsyncValue<Result<List<User>>>,
          Result<List<User>>,
          FutureOr<Result<List<User>>>
        >
    with
        $FutureModifier<Result<List<User>>>,
        $FutureProvider<Result<List<User>>> {
  /// Every account, read straight from the database.
  ///
  /// The synchronous `loadUsers` hands out the use case; this provider runs it, so
  /// a widget or the router can watch the result without calling into the database
  /// itself. Kept alive so a single read serves the whole session.
  AllUsersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'allUsersProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$allUsersHash();

  @$internal
  @override
  $FutureProviderElement<Result<List<User>>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Result<List<User>>> create(Ref ref) {
    return allUsers(ref);
  }
}

String _$allUsersHash() => r'b103f291552ea8232b1443913625a6dda553b395';

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

/// Authenticates an operator against a stored password or PIN.

@ProviderFor(signIn)
final signInProvider = SignInProvider._();

/// Authenticates an operator against a stored password or PIN.

final class SignInProvider extends $FunctionalProvider<SignIn, SignIn, SignIn>
    with $Provider<SignIn> {
  /// Authenticates an operator against a stored password or PIN.
  SignInProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'signInProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$signInHash();

  @$internal
  @override
  $ProviderElement<SignIn> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SignIn create(Ref ref) {
    return signIn(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SignIn value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SignIn>(value),
    );
  }
}

String _$signInHash() => r'99cfb472d3c413048cecf98df91fdb6543a4e714';

/// Seeds the built-in roles an empty installation needs before any account.
///
/// The owner cannot be created until its role exists, so setup runs this first.

@ProviderFor(seedBuiltInRoles)
final seedBuiltInRolesProvider = SeedBuiltInRolesProvider._();

/// Seeds the built-in roles an empty installation needs before any account.
///
/// The owner cannot be created until its role exists, so setup runs this first.

final class SeedBuiltInRolesProvider
    extends
        $FunctionalProvider<
          SeedBuiltInRoles,
          SeedBuiltInRoles,
          SeedBuiltInRoles
        >
    with $Provider<SeedBuiltInRoles> {
  /// Seeds the built-in roles an empty installation needs before any account.
  ///
  /// The owner cannot be created until its role exists, so setup runs this first.
  SeedBuiltInRolesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'seedBuiltInRolesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$seedBuiltInRolesHash();

  @$internal
  @override
  $ProviderElement<SeedBuiltInRoles> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SeedBuiltInRoles create(Ref ref) {
    return seedBuiltInRoles(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SeedBuiltInRoles value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SeedBuiltInRoles>(value),
    );
  }
}

String _$seedBuiltInRolesHash() => r'fe2582af7d76c7cad917cad2a07b0d70a7b3be6a';

/// Creates the very first account — the owner — on an empty installation.

@ProviderFor(initializeOwner)
final initializeOwnerProvider = InitializeOwnerProvider._();

/// Creates the very first account — the owner — on an empty installation.

final class InitializeOwnerProvider
    extends
        $FunctionalProvider<InitializeOwner, InitializeOwner, InitializeOwner>
    with $Provider<InitializeOwner> {
  /// Creates the very first account — the owner — on an empty installation.
  InitializeOwnerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'initializeOwnerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$initializeOwnerHash();

  @$internal
  @override
  $ProviderElement<InitializeOwner> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  InitializeOwner create(Ref ref) {
    return initializeOwner(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(InitializeOwner value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<InitializeOwner>(value),
    );
  }
}

String _$initializeOwnerHash() => r'6a6dd3764680fdf7fe546956564d6e44f9cb7a90';

/// Whether the app must still ask for an owner before it can be used.
///
/// `true` only when the account list loaded successfully **and** is empty. A
/// loading or failed read answers `false`, so a database problem can never trap
/// the app on the setup screen; the destination reports the failure itself.

@ProviderFor(ownerSetupRequired)
final ownerSetupRequiredProvider = OwnerSetupRequiredProvider._();

/// Whether the app must still ask for an owner before it can be used.
///
/// `true` only when the account list loaded successfully **and** is empty. A
/// loading or failed read answers `false`, so a database problem can never trap
/// the app on the setup screen; the destination reports the failure itself.

final class OwnerSetupRequiredProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Whether the app must still ask for an owner before it can be used.
  ///
  /// `true` only when the account list loaded successfully **and** is empty. A
  /// loading or failed read answers `false`, so a database problem can never trap
  /// the app on the setup screen; the destination reports the failure itself.
  OwnerSetupRequiredProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'ownerSetupRequiredProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$ownerSetupRequiredHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return ownerSetupRequired(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$ownerSetupRequiredHash() =>
    r'47265b8b5a21d899e6a8e1be4894dc5a7e8dcf93';
