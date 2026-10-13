import 'package:flow/core/result/result.dart';

import '../role.dart';
import '../role_repository.dart';

/// Lists every role, including disabled ones.
///
/// A read-only use case: it changes nothing, so it records no audit entry.
final class LoadRoles {
  /// Creates the use case.
  const LoadRoles(this._repository);

  final RoleRepository _repository;

  /// Returns all roles, oldest first.
  Future<Result<List<Role>>> call() => _repository.readAll();
}
