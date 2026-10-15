import 'package:flow/core/result/result.dart';

import '../unit.dart';
import '../unit_repository.dart';

/// Lists every unit of measure, including disabled ones.
///
/// A read-only use case: it changes nothing, so it records no audit entry.
final class LoadUnits {
  /// Creates the use case.
  const LoadUnits(this._repository);

  final UnitRepository _repository;

  /// Returns all units, oldest first.
  Future<Result<List<Unit>>> call() => _repository.readAll();
}
