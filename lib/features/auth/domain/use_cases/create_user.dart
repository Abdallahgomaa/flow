import 'package:flow/core/result/failure.dart';
import 'package:flow/core/result/result.dart';
import 'package:flow/core/utils/clock.dart';
import 'package:flow/core/utils/uuid_v7.dart';

import '../user.dart';
import '../user_repository.dart';

/// Validates and creates a user account.
///
/// Identity (`id`, `created_at`) is decided here rather than in the database
/// layer, so the same [Clock] that stamps the row also seeds the UUID v7 that
/// orders it: identifiers and timestamps never disagree.
final class CreateUser {
  /// Creates the use case.
  const CreateUser(this._repository, this._idGenerator, this._clock);

  final UserRepository _repository;
  final UuidV7Generator _idGenerator;
  final Clock _clock;

  /// Audit action recorded for every created account.
  static const String auditAction = 'user.created';

  /// Failure code used when the login name is missing.
  static const String usernameRequiredCode = 'user.usernameRequired';

  /// Failure code used when the login name is not a well-formed slug.
  static const String usernameInvalidCode = 'user.usernameInvalid';

  /// Failure code used when the display name is missing.
  static const String nameRequiredCode = 'user.nameRequired';

  /// Failure code used when no role was chosen.
  static const String roleRequiredCode = 'user.roleRequired';

  /// Allowed login names: 3–32 characters of letters, digits, dot, dash or
  /// underscore. Deliberately strict, because the login name is typed on a
  /// keyboard at the sign-in screen.
  static final RegExp _usernamePattern = RegExp(r'^[A-Za-z0-9._-]{3,32}$');

  /// Validates the account fields and creates the account.
  ///
  /// Returns the stored account on success, or a [ValidationFailure] naming the
  /// first problem via its code. A login name that is already taken comes back
  /// as a [ConflictFailure], and a role that does not exist as a
  /// [ValidationFailure], both from the repository.
  Future<Result<User>> call({
    required String username,
    required String displayName,
    required String roleCode,
  }) async {
    final String login = username.trim();
    if (login.isEmpty) {
      return const Result<User>.err(
        ValidationFailure(
          message: 'Enter a login name.',
          code: usernameRequiredCode,
        ),
      );
    }
    if (!_usernamePattern.hasMatch(login)) {
      return const Result<User>.err(
        ValidationFailure(
          message: 'Use 3 to 32 letters, digits, dots, dashes or underscores.',
          code: usernameInvalidCode,
        ),
      );
    }

    final String name = displayName.trim();
    if (name.isEmpty) {
      return const Result<User>.err(
        ValidationFailure(
          message: 'Enter a display name.',
          code: nameRequiredCode,
        ),
      );
    }

    final String role = roleCode.trim();
    if (role.isEmpty) {
      return const Result<User>.err(
        ValidationFailure(message: 'Choose a role.', code: roleRequiredCode),
      );
    }

    final User user = User(
      id: _idGenerator.next(),
      username: login,
      displayName: name,
      roleCode: role,
      createdAt: _clock.nowUtc(),
    );

    // The audit payload carries identifiers only: the login name is personal
    // data and credentials never enter the trail.
    return _repository.create(
      user: user,
      action: auditAction,
      payload: <String, Object?>{'id': user.id, 'roleCode': role},
    );
  }
}
