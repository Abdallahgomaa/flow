import 'package:drift/drift.dart';
import 'package:flow/core/database/database.dart';
import 'package:flow/core/result/failure.dart';
import 'package:flow/core/result/result.dart';
import 'package:flow/core/utils/clock.dart';
import 'package:flow/core/utils/logger.dart';

import '../domain/category.dart';
import '../domain/category_repository.dart';

/// Drift-backed [CategoryRepository] (`P2-01`).
///
/// Every write wraps the row change **and** its audit entry in a single
/// [UnitOfWork] transaction (AGENTS rule 3), so a stored category can never
/// exist without the audit row that explains it.
///
/// The tree stays well-formed through two guards: SQLite enforces that
/// [Category.parentId] points at a real row (the self-referencing foreign key),
/// and [create] refuses an unknown parent with a typed failure so the caller
/// gets a business error instead of a constraint violation.
final class DriftCategoryRepository implements CategoryRepository {
  /// Creates the repository over its injected collaborators.
  const DriftCategoryRepository({
    required this.database,
    required this.unitOfWork,
    required this.auditService,
    required this.clock,
  });

  /// Audit entity name recorded for every category change.
  static const String auditEntity = 'categories';

  static const String _logName = 'catalog.category_repository';
  static const String _readFailedMessage = 'Could not load the categories.';
  static const String _createFailedMessage = 'Could not save the category.';
  static const String _disableFailedMessage = 'Could not disable the category.';

  /// The database that owns the `categories` table.
  final AppDatabase database;

  /// Groups the row change and the audit entry into one transaction.
  final UnitOfWork unitOfWork;

  /// Appends to the append-only audit chain.
  final AuditService auditService;

  /// Supplies the timestamps for updates.
  final Clock clock;

  @override
  Future<Result<List<Category>>> readAll() async {
    try {
      final List<CategoryRow> rows =
          await (database.select(database.categories)
                ..orderBy(<OrderingTerm Function($CategoriesTable)>[
                  ($CategoriesTable table) => OrderingTerm.asc(table.sortOrder),
                  ($CategoriesTable table) => OrderingTerm.asc(table.name),
                  ($CategoriesTable table) => OrderingTerm.asc(table.createdAt),
                ]))
              .get();
      return Result<List<Category>>.ok(
        rows.map(_toEntity).toList(growable: false),
      );
    } on Object catch (error, stackTrace) {
      AppLogger.instance.error(
        'Failed to read categories',
        name: _logName,
        error: error,
        stackTrace: stackTrace,
      );
      return Result<List<Category>>.err(
        StorageFailure(
          message: _readFailedMessage,
          cause: error,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  @override
  Future<Result<Category>> readById(String id) async {
    try {
      final CategoryRow? row = await _find(id);
      if (row == null) {
        return const Result<Category>.err(_notFound);
      }
      return Result<Category>.ok(_toEntity(row));
    } on Object catch (error, stackTrace) {
      AppLogger.instance.error(
        'Failed to read category $id',
        name: _logName,
        error: error,
        stackTrace: stackTrace,
      );
      return Result<Category>.err(
        StorageFailure(
          message: _readFailedMessage,
          cause: error,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  @override
  Future<Result<Category>> create({
    required Category category,
    required String action,
    Map<String, Object?> payload = const <String, Object?>{},
  }) async {
    try {
      final Failure? failure = await unitOfWork.run<Failure?>(() async {
        // Checked inside the transaction so the reference cannot vanish between
        // the check and the insert; the foreign key stays the last line of
        // defence.
        final String? parentId = category.parentId;
        if (parentId != null && await _find(parentId) == null) {
          return const NotFoundFailure(
            message: 'The parent category no longer exists.',
            code: CategoryRepository.parentNotFoundCode,
          );
        }
        await database
            .into(database.categories)
            .insert(
              CategoriesCompanion.insert(
                id: category.id,
                name: category.name,
                createdAt: category.createdAt,
                parentId: Value<String?>(parentId),
                sortOrder: Value<int>(category.sortOrder),
              ),
            );
        await auditService.append(
          action: action,
          entity: auditEntity,
          entityId: category.id,
          payload: payload,
        );
        return null;
      });
      return failure == null
          ? Result<Category>.ok(category)
          : Result<Category>.err(failure);
    } on Object catch (error, stackTrace) {
      AppLogger.instance.error(
        'Failed to create category ${category.id}',
        name: _logName,
        error: error,
        stackTrace: stackTrace,
      );
      return Result<Category>.err(
        StorageFailure(
          message: _createFailedMessage,
          cause: error,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  @override
  Future<Result<void>> disable({
    required String id,
    required String action,
    Map<String, Object?> payload = const <String, Object?>{},
  }) async {
    try {
      final Failure? failure = await unitOfWork.run<Failure?>(() async {
        final CategoryRow? row = await _find(id);
        if (row == null) {
          return _notFound;
        }
        if (_toEntity(row).isDisabled) {
          // Nothing changes, so nothing is audited (see the interface docs).
          return null;
        }
        // A parent with children would leave them orphaned, so the caller has to
        // move or retire the children first.
        final CategoryRow? child =
            await (database.select(database.categories)
                  ..where(($CategoriesTable table) => table.parentId.equals(id))
                  ..limit(1))
                .getSingleOrNull();
        if (child != null) {
          return const ConflictFailure(
            message: 'Move or disable the sub-categories first.',
            code: CategoryRepository.hasChildrenCode,
          );
        }
        final DateTime now = clock.nowUtc();
        await (database.update(
          database.categories,
        )..where(($CategoriesTable table) => table.id.equals(id))).write(
          CategoriesCompanion(
            disabledAt: Value<DateTime?>(now),
            updatedAt: Value<DateTime?>(now),
          ),
        );
        await auditService.append(
          action: action,
          entity: auditEntity,
          entityId: id,
          payload: payload,
        );
        return null;
      });
      return failure == null
          ? const Result<void>.ok(null)
          : Result<void>.err(failure);
    } on Object catch (error, stackTrace) {
      AppLogger.instance.error(
        'Failed to disable category $id',
        name: _logName,
        error: error,
        stackTrace: stackTrace,
      );
      return Result<void>.err(
        StorageFailure(
          message: _disableFailedMessage,
          cause: error,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  /// The failure returned when a category id does not resolve to a row.
  static const NotFoundFailure _notFound = NotFoundFailure(
    message: 'That category no longer exists.',
    code: CategoryRepository.notFoundCode,
  );

  Future<CategoryRow?> _find(String id) => (database.select(
    database.categories,
  )..where(($CategoriesTable table) => table.id.equals(id))).getSingleOrNull();

  Category _toEntity(CategoryRow row) => Category(
    id: row.id,
    name: row.name,
    createdAt: row.createdAt,
    parentId: row.parentId,
    sortOrder: row.sortOrder,
    disabledAt: row.disabledAt,
    updatedAt: row.updatedAt,
  );
}
