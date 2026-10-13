import 'package:flow/core/result/failure.dart';
import 'package:flow/core/result/result.dart';

import '../role.dart';
import '../role_repository.dart';

/// Validates and creates a role.
///
/// This is the only way a role is ever written (AGENTS rule 3): callers use the
/// use case, and the repository wraps the row plus its audit entry in one unit
/// of work.
final class CreateRole {
  /// Creates the use case.
  const CreateRole(this._repository);

  final RoleRepository _repository;

  /// Audit action recorded for every created role.
  static const String auditAction = 'role.created';

  /// Failure code used when the role code is missing.
  static const String codeRequiredCode = 'role.codeRequired';

  /// Failure code used when the role code is not a well-formed slug.
  static const String codeInvalidCode = 'role.codeInvalid';

  /// Failure code used when the role name is missing.
  static const String nameRequiredCode = 'role.nameRequired';

  /// The shape a role code must have: lowercase letters and digits separated by
  /// single dots, dashes or underscores — for example `cashier` or `shift_lead`.
  /// The value doubles as `users.role_code`, so it has to stay machine-friendly.
  static final RegExp _codePattern = RegExp(r'^[a-z0-9]+([._-][a-z0-9]+)*$');

  /// Validates [role] and creates it.
  ///
  /// Returns the normalised (trimmed) role on success, or a
  /// [ValidationFailure] naming the first problem via its code. A role code
  /// that is already taken comes back as a [ConflictFailure] from the
  /// repository.
  Future<Result<Role>> call(Role role) async {
    final String code = role.code.trim().toLowerCase();
    if (code.isEmpty) {
      return const Result<Role>.err(
        ValidationFailure(
          message: 'Enter a role code.',
          code: codeRequiredCode,
        ),
      );
    }
    if (!_codePattern.hasMatch(code)) {
      return const Result<Role>.err(
        ValidationFailure(
          message:
              'Use lowercase letters, digits, dots, dashes or underscores.',
          code: codeInvalidCode,
        ),
      );
    }

    final String name = role.name.trim();
    if (name.isEmpty) {
      return const Result<Role>.err(
        ValidationFailure(
          message: 'Enter a role name.',
          code: nameRequiredCode,
        ),
      );
    }

    return _repository.create(
      role: Role(
        code: code,
        name: name,
        createdAt: role.createdAt,
        description: _normalise(role.description),
      ),
      action: auditAction,
      payload: <String, Object?>{'code': code},
    );
  }

  /// Trims [value] and maps blank input to `null`, so an empty description is
  /// stored as absent rather than as an empty string.
  static String? _normalise(String? value) {
    final String? trimmed = value?.trim();
    return (trimmed == null || trimmed.isEmpty) ? null : trimmed;
  }
}
