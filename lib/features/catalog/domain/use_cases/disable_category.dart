import 'package:flow/core/result/failure.dart';
import 'package:flow/core/result/result.dart';

import '../category_repository.dart';

/// Validates and disables a category.
final class DisableCategory {
  /// Creates the use case.
  const DisableCategory(this._repository);

  final CategoryRepository _repository;

  /// Audit action recorded for every disabled category.
  static const String auditAction = 'category.disabled';

  /// Failure code used when the category id is missing.
  static const String idRequiredCode = 'category.idRequired';

  /// Logically disables the category with [id].
  ///
  /// Returns a [ValidationFailure] when [id] is blank, a [NotFoundFailure] when
  /// no category matches it, and a [ConflictFailure] when the category still has
  /// children. Disabling an already-disabled category succeeds without writing an
  /// audit entry, because nothing changed.
  Future<Result<void>> call(String id) async {
    final String trimmed = id.trim();
    if (trimmed.isEmpty) {
      return const Result<void>.err(
        ValidationFailure(
          message: 'Choose a category to disable.',
          code: idRequiredCode,
        ),
      );
    }
    return _repository.disable(id: trimmed, action: auditAction);
  }
}
