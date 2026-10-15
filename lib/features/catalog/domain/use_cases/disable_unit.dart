import 'package:flow/core/result/failure.dart';
import 'package:flow/core/result/result.dart';

import '../unit_repository.dart';

/// Validates and disables a unit of measure.
final class DisableUnit {
  /// Creates the use case.
  const DisableUnit(this._repository);

  final UnitRepository _repository;

  /// Audit action recorded for every disabled unit.
  static const String auditAction = 'unit.disabled';

  /// Failure code used when the unit code is missing.
  static const String codeRequiredCode = 'unit.codeRequired';

  /// Logically disables the unit with [code].
  ///
  /// Returns a [ValidationFailure] when [code] is blank and a [NotFoundFailure]
  /// when no unit matches it. Disabling an already-disabled unit succeeds without
  /// writing an audit entry, because nothing changed.
  Future<Result<void>> call(String code) async {
    final String trimmed = code.trim().toLowerCase();
    if (trimmed.isEmpty) {
      return const Result<void>.err(
        ValidationFailure(
          message: 'Choose a unit to disable.',
          code: codeRequiredCode,
        ),
      );
    }
    return _repository.disable(code: trimmed, action: auditAction);
  }
}
