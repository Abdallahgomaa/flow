import 'package:flow/core/result/result.dart';

import '../category.dart';
import '../category_repository.dart';

/// Lists every category, including disabled ones.
///
/// A read-only use case: it changes nothing, so it records no audit entry.
final class LoadCategories {
  /// Creates the use case.
  const LoadCategories(this._repository);

  final CategoryRepository _repository;

  /// Returns all categories, ordered for display.
  Future<Result<List<Category>>> call() => _repository.readAll();
}
