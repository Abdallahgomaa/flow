import 'package:flow/core/result/result.dart';

import '../user.dart';
import '../user_repository.dart';

/// Lists every user account, including disabled ones.
///
/// A read-only use case: it changes nothing, so it records no audit entry.
final class LoadUsers {
  /// Creates the use case.
  const LoadUsers(this._repository);

  final UserRepository _repository;

  /// Returns all accounts, oldest first.
  Future<Result<List<User>>> call() => _repository.readAll();
}
