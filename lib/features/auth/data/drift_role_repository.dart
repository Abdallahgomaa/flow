import 'package:drift/drift.dart';
import 'package:flow/core/database/database.dart';
import 'package:flow/core/result/failure.dart';
import 'package:flow/core/result/result.dart';
import 'package:flow/core/utils/clock.dart';
import 'package:flow/core/utils/logger.dart';

import '../domain/role.dart';
import '../domain/role_repository.dart';

/// Drift-backed [RoleRepository] (`P1-02`).
///
/// Every write wraps the row change **and** its audit entry in a single
/// [UnitOfWork] transaction (AGENTS rule 3), so a stored role can never exist
/// without the audit row that explains it.
final class DriftRoleRepository implements RoleRepository {
  /// Creates the repository over its injected collaborators.
  const DriftRoleRepository({
    required this.database,
    required this.unitOfWork,
    required this.auditService,
    required this.clock,
  });

  /// Audit entity name recorded for every role change.
  static const String auditEntity = 'roles';

  static const String _logName = 'auth.role_repository';
  static const String _readFailedMessage = 'Could not load the roles.';
  static const String _createFailedMessage = 'Could not save the role.';
  static const String _disableFailedMessage = 'Could not disable the role.';

  /// The database that owns the `roles` table.
  final AppDatabase database;

  /// Groups the row change and the audit entry into one transaction.
  final UnitOfWork unitOfWork;

  /// Appends to the append-only audit chain.
  final AuditService auditService;

  /// Supplies the timestamps for updates.
  final Clock clock;

  @override
  Future<Result<List<Role>>> readAll() async {
    try {
      final List<RoleRow> rows =
          await (database.select(database.roles)
                ..orderBy(<OrderingTerm Function($RolesTable)>[
                  ($RolesTable table) => OrderingTerm.asc(table.createdAt),
                  ($RolesTable table) => OrderingTerm.asc(table.code),
                ]))
              .get();
      return Result<List<Role>>.ok(rows.map(_toEntity).toList(growable: false));
    } on Object catch (error, stackTrace) {
      AppLogger.instance.error(
        'Failed to read roles',
        name: _logName,
        error: error,
        stackTrace: stackTrace,
      );
      return Result<List<Role>>.err(
        StorageFailure(
          message: _readFailedMessage,
          cause: error,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  @override
  Future<Result<Role>> readByCode(String code) async {
    try {
      final RoleRow? row = await _find(code);
      if (row == null) {
        return const Result<Role>.err(_notFound);
      }
      return Result<Role>.ok(_toEntity(row));
    } on Object catch (error, stackTrace) {
      AppLogger.instance.error(
        'Failed to read role $code',
        name: _logName,
        error: error,
        stackTrace: stackTrace,
      );
      return Result<Role>.err(
        StorageFailure(
          message: _readFailedMessage,
          cause: error,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  @override
  Future<Result<Role>> create({
    required Role role,
    required String action,
    Map<String, Object?> payload = const <String, Object?>{},
  }) async {
    try {
      final Failure? failure = await unitOfWork.run<Failure?>(() async {
        // Checked inside the transaction so the uniqueness rule holds even if
        // two writes race; the primary key stays the last line of defence.
        if (await _find(role.code) != null) {
          return const ConflictFailure(
            message: 'A role with that code already exists.',
            code: RoleRepository.codeTakenCode,
          );
        }
        await database
            .into(database.roles)
            .insert(
              RolesCompanion.insert(
                code: role.code,
                name: role.name,
                createdAt: role.createdAt,
                description: Value<String?>(role.description),
                isBuiltIn: Value<bool>(role.isBuiltIn),
              ),
            );
        await auditService.append(
          action: action,
          entity: auditEntity,
          entityId: role.code,
          payload: payload,
        );
        return null;
      });
      return failure == null
          ? Result<Role>.ok(role)
          : Result<Role>.err(failure);
    } on Object catch (error, stackTrace) {
      AppLogger.instance.error(
        'Failed to create role ${role.code}',
        name: _logName,
        error: error,
        stackTrace: stackTrace,
      );
      return Result<Role>.err(
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
    required String code,
    required String action,
    Map<String, Object?> payload = const <String, Object?>{},
  }) async {
    try {
      final Failure? failure = await unitOfWork.run<Failure?>(() async {
        final RoleRow? row = await _find(code);
        if (row == null) {
          return _notFound;
        }
        final Role role = _toEntity(row);
        if (role.isBuiltIn) {
          return const ConflictFailure(
            message: 'Built-in roles cannot be disabled.',
            code: RoleRepository.builtInCode,
          );
        }
        if (role.isDisabled) {
          // Nothing changes, so nothing is audited (see the interface docs).
          return null;
        }
        final DateTime now = clock.nowUtc();
        await (database.update(
          database.roles,
        )..where(($RolesTable table) => table.code.equals(code))).write(
          RolesCompanion(
            disabledAt: Value<DateTime?>(now),
            updatedAt: Value<DateTime?>(now),
          ),
        );
        await auditService.append(
          action: action,
          entity: auditEntity,
          entityId: code,
          payload: payload,
        );
        return null;
      });
      return failure == null
          ? const Result<void>.ok(null)
          : Result<void>.err(failure);
    } on Object catch (error, stackTrace) {
      AppLogger.instance.error(
        'Failed to disable role $code',
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

  /// The failure returned when a role code does not resolve to a row.
  static const NotFoundFailure _notFound = NotFoundFailure(
    message: 'That role no longer exists.',
    code: RoleRepository.notFoundCode,
  );

  Future<RoleRow?> _find(String code) => (database.select(
    database.roles,
  )..where(($RolesTable table) => table.code.equals(code))).getSingleOrNull();

  Role _toEntity(RoleRow row) => Role(
    code: row.code,
    name: row.name,
    createdAt: row.createdAt,
    description: row.description,
    isBuiltIn: row.isBuiltIn,
    disabledAt: row.disabledAt,
    updatedAt: row.updatedAt,
  );
}
