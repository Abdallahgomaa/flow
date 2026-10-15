import 'package:flow/core/result/failure.dart';
import 'package:flow/core/result/result.dart';
import 'package:flow/core/utils/clock.dart';

import '../role.dart';
import '../role_repository.dart';
import '../user_role.dart';

/// Seeds the four built-in roles exactly once (`P1-10`).
///
/// The first account cannot be created until its role exists, so this runs
/// before the owner is created. It is idempotent: a role that is already stored
/// is skipped, which keeps it safe to call on every setup attempt and makes the
/// built-in set reproducible after a restore.
final class SeedBuiltInRoles {
  /// Creates the use case.
  const SeedBuiltInRoles(this._repository, this._clock);

  final RoleRepository _repository;
  final Clock _clock;

  /// Audit action recorded for every seeded role.
  static const String auditAction = 'role.seeded';

  /// English display names for the built-in roles.
  ///
  /// Kept here rather than on the enum so `domain` stays free of presentation
  /// copy; a later step can localise them for the operator's language.
  static const Map<UserRole, String> _names = <UserRole, String>{
    UserRole.owner: 'Owner',
    UserRole.cashier: 'Cashier',
    UserRole.inventory: 'Inventory',
    UserRole.accountant: 'Accountant',
  };

  /// Stores every missing built-in role and reports the first real failure.
  ///
  /// A role that already exists is left untouched, so a second call writes
  /// nothing. A failure other than "not found" is propagated as-is: a storage
  /// problem must never be mistaken for a fresh installation.
  Future<Result<void>> call() async {
    for (final UserRole role in UserRole.values) {
      final Result<Role> existing = await _repository.readByCode(role.code);

      final Failure? lookupFailure = existing.failureOrNull;
      if (lookupFailure != null &&
          lookupFailure.code != RoleRepository.notFoundCode) {
        return Result<void>.err(lookupFailure);
      }
      if (existing.isOk) {
        continue;
      }

      final Result<Role> created = await _repository.create(
        role: Role(
          code: role.code,
          name: _names[role] ?? role.code,
          createdAt: _clock.nowUtc(),
          isBuiltIn: true,
        ),
        action: auditAction,
        payload: <String, Object?>{'code': role.code},
      );
      if (created case Err<Role>(:final Failure failure)) {
        return Result<void>.err(failure);
      }
    }

    return const Result<void>.ok(null);
  }
}
