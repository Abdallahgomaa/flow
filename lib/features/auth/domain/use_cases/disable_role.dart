import 'package:flow/core/result/failure.dart';
import 'package:flow/core/result/result.dart';

import '../role_repository.dart';

/// Logically disables a role.
///
/// The row is kept so `users.role_code` and the audit trail stay resolvable;
/// only `disabled_at` changes. Built-in roles are refused by the repository.
final class DisableRole {
  /// Creates the use case.
  const DisableRole(this._repository);

  final RoleRepository _repository;

  /// Audit action recorded for every disabled role.
  static const String auditAction = 'role.disabled';

  /// Failure code used when no role was chosen.
  static const String codeRequiredCode = 'role.codeRequired';

  /// Validates [code] and disables that role.
  Future<Result<void>> call(String code) async {
    final String normalised = code.trim();
    if (normalised.isEmpty) {
      return const Result<void>.err(
        ValidationFailure(message: 'Choose a role.', code: codeRequiredCode),
      );
    }

    return _repository.disable(
      code: normalised,
      action: auditAction,
      payload: <String, Object?>{'code': normalised},
    );
  }
}
