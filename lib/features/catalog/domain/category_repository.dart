import 'package:flow/core/result/result.dart';

import 'category.dart';

/// Reads and changes category records (`P2-01`).
///
/// Every write here is one atomic, audited unit of work: the row change and its
/// audit entry commit together, or not at all (AGENTS rule 3). Categories are
/// never hard-deleted — [disable] retires them instead, so products, child
/// categories and the audit trail keep resolving them.
abstract interface class CategoryRepository {
  /// Failure code returned by [readById] and [disable] when no row matches.
  static const String notFoundCode = 'category.notFound';

  /// Failure code returned by [create] when the named parent does not exist.
  static const String parentNotFoundCode = 'category.parentNotFound';

  /// Failure code returned by [disable] while the category still has children.
  static const String hasChildrenCode = 'category.hasChildren';

  /// Every category, including disabled ones, ordered by [Category.sortOrder]
  /// and then by name.
  Future<Result<List<Category>>> readAll();

  /// The category with [id], or a [NotFoundFailure] carrying [notFoundCode].
  Future<Result<Category>> readById(String id);

  /// Inserts [category] and appends one audit row for [action].
  ///
  /// [payload] is recorded verbatim in the audit entry and must stay free of
  /// personal data.
  Future<Result<Category>> create({
    required Category category,
    required String action,
    Map<String, Object?> payload = const <String, Object?>{},
  });

  /// Logically disables the category with [id] and appends an audit row.
  ///
  /// Disabling an already-disabled category is a no-op and writes no audit
  /// entry, because nothing changed. A category that still has children is
  /// refused with [hasChildrenCode] so the tree can never be left with orphans.
  Future<Result<void>> disable({
    required String id,
    required String action,
    Map<String, Object?> payload = const <String, Object?>{},
  });
}
