import 'package:flow/core/result/failure.dart';
import 'package:flow/core/result/result.dart';

import '../user_repository.dart';

/// Logically disables a user account.
///
/// The row is kept so sales history and the audit trail stay resolvable; only
/// `disabled_at` changes. A disabled account keeps its role, so re-enabling it
/// later (a `P1-14` concern) needs no repair.
final class DisableUser {
  /// Creates the use case.
  const DisableUser(this._repository);

  final UserRepository _repository;

  /// Audit action recorded for every disabled account.
  static const String auditAction = 'user.disabled';

  /// Failure code used when no account was chosen.
  static const String idRequiredCode = 'user.idRequired';

  /// Validates [id] and disables that account.
  Future<Result<void>> call(String id) async {
    final String normalised = id.trim();
    if (normalised.isEmpty) {
      return const Result<void>.err(
        ValidationFailure(message: 'Choose a user.', code: idRequiredCode),
      );
    }

    return _repository.disable(
      id: normalised,
      action: auditAction,
      payload: <String, Object?>{'id': normalised},
    );
  }
}
