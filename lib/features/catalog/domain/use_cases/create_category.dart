import 'package:flow/core/result/failure.dart';
import 'package:flow/core/result/result.dart';
import 'package:flow/core/utils/clock.dart';
import 'package:flow/core/utils/uuid_v7.dart';

import '../category.dart';
import '../category_repository.dart';

/// Validates and creates a category.
///
/// This is the only way a category is ever written (AGENTS rule 3): callers use
/// the use case, and the repository wraps the row plus its audit entry in one
/// unit of work. Identity (`id`, `createdAt`) is decided here rather than in the
/// database layer, so the same [Clock] that stamps the row also seeds the UUID
/// v7 that orders it: identifiers and timestamps never disagree.
final class CreateCategory {
  /// Creates the use case.
  const CreateCategory(this._repository, this._idGenerator, this._clock);

  final CategoryRepository _repository;
  final UuidV7Generator _idGenerator;
  final Clock _clock;

  /// Audit action recorded for every created category.
  static const String auditAction = 'category.created';

  /// Failure code used when the category name is missing.
  static const String nameRequiredCode = 'category.nameRequired';

  /// Validates the fields and creates the category.
  ///
  /// [parentId] names the parent category, or is omitted (or blank) for a root.
  /// Returns the stored category on success, or a [ValidationFailure] naming the
  /// first problem via its code. A parent that does not exist comes back as a
  /// [NotFoundFailure] from the repository.
  Future<Result<Category>> call({
    required String name,
    String? parentId,
    int sortOrder = 0,
  }) async {
    final String trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      return const Result<Category>.err(
        ValidationFailure(
          message: 'Enter a category name.',
          code: nameRequiredCode,
        ),
      );
    }

    final String? parent = _normalise(parentId);
    final Category category = Category(
      id: _idGenerator.next(),
      name: trimmedName,
      createdAt: _clock.nowUtc(),
      parentId: parent,
      sortOrder: sortOrder,
    );

    return _repository.create(
      category: category,
      action: auditAction,
      payload: <String, Object?>{
        'id': category.id,
        'name': trimmedName,
        'parentId': ?parent,
      },
    );
  }

  /// Trims [value] and maps blank input to `null`, so an empty id is stored as
  /// "no parent" rather than as an empty string.
  static String? _normalise(String? value) {
    final String? trimmed = value?.trim();
    return (trimmed == null || trimmed.isEmpty) ? null : trimmed;
  }
}
