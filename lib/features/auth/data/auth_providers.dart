import 'package:flow/core/database/database_providers.dart';
import 'package:flow/core/utils/utils_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/password_hasher.dart';
import '../domain/role_repository.dart';
import '../domain/use_cases/create_role.dart';
import '../domain/use_cases/create_user.dart';
import '../domain/use_cases/disable_role.dart';
import '../domain/use_cases/disable_user.dart';
import '../domain/use_cases/load_roles.dart';
import '../domain/use_cases/load_users.dart';
import '../domain/user_repository.dart';
import 'argon2_password_hasher.dart';
import 'drift_role_repository.dart';
import 'drift_user_repository.dart';

part 'auth_providers.g.dart';

/// The role repository used by the auth feature.
///
/// It is the single bridge between the database providers in `core` and the
/// role tables, so no widget ever constructs a repository by hand.
@Riverpod(keepAlive: true)
RoleRepository roleRepository(Ref ref) => DriftRoleRepository(
  database: ref.watch(appDatabaseProvider),
  unitOfWork: ref.watch(unitOfWorkProvider),
  auditService: ref.watch(auditServiceProvider),
  clock: ref.watch(clockProvider),
);

/// The user repository used by the auth feature.
@Riverpod(keepAlive: true)
UserRepository userRepository(Ref ref) => DriftUserRepository(
  database: ref.watch(appDatabaseProvider),
  unitOfWork: ref.watch(unitOfWorkProvider),
  auditService: ref.watch(auditServiceProvider),
  clock: ref.watch(clockProvider),
);

/// Hashes and verifies login passwords and quick-unlock PINs.
///
/// `keepAlive` so the calibrated cost is built once per process, not per call.
@Riverpod(keepAlive: true)
PasswordHasher passwordHasher(Ref ref) => Argon2PasswordHasher();

/// Reads every role, including the disabled ones.
@Riverpod(keepAlive: true)
LoadRoles loadRoles(Ref ref) => LoadRoles(ref.watch(roleRepositoryProvider));

/// Creates a role after validating its code and name.
@Riverpod(keepAlive: true)
CreateRole createRole(Ref ref) => CreateRole(ref.watch(roleRepositoryProvider));

/// Disables a role. Built-in roles are refused.
@Riverpod(keepAlive: true)
DisableRole disableRole(Ref ref) =>
    DisableRole(ref.watch(roleRepositoryProvider));

/// Reads every user account, including the disabled ones.
@Riverpod(keepAlive: true)
LoadUsers loadUsers(Ref ref) => LoadUsers(ref.watch(userRepositoryProvider));

/// Creates a user account, generating its identifier.
@Riverpod(keepAlive: true)
CreateUser createUser(Ref ref) => CreateUser(
  ref.watch(userRepositoryProvider),
  ref.watch(idGeneratorProvider),
  ref.watch(clockProvider),
);

/// Disables a user account. The row is never deleted.
@Riverpod(keepAlive: true)
DisableUser disableUser(Ref ref) =>
    DisableUser(ref.watch(userRepositoryProvider));
