import 'package:drift/drift.dart';
import 'package:flow/core/database/database.dart';
import 'package:flow/core/result/failure.dart';
import 'package:flow/core/result/result.dart';
import 'package:flow/core/utils/clock.dart';
import 'package:flow/core/utils/logger.dart';

import '../domain/user.dart';
import '../domain/user_repository.dart';

/// Drift-backed [UserRepository] (`P1-02`).
///
/// Every write wraps the row change **and** its audit entry in a single
/// [UnitOfWork] transaction (AGENTS rule 3), so an account can never exist
/// without the audit row that explains it.
final class DriftUserRepository implements UserRepository {
  /// Creates the repository over its injected collaborators.
  const DriftUserRepository({
    required this.database,
    required this.unitOfWork,
    required this.auditService,
    required this.clock,
  });

  /// Audit entity name recorded for every user change.
  static const String auditEntity = 'users';

  static const String _logName = 'auth.user_repository';
  static const String _readFailedMessage = 'Could not load the users.';
  static const String _createFailedMessage = 'Could not save the user.';
  static const String _disableFailedMessage = 'Could not disable the user.';

  /// The database that owns the `users` table.
  final AppDatabase database;

  /// Groups the row change and the audit entry into one transaction.
  final UnitOfWork unitOfWork;

  /// Appends to the append-only audit chain.
  final AuditService auditService;

  /// Supplies the timestamps for updates.
  final Clock clock;

  @override
  Future<Result<List<User>>> readAll() async {
    try {
      final List<UserRow> rows =
          await (database.select(database.users)
                ..orderBy(<OrderingTerm Function($UsersTable)>[
                  ($UsersTable table) => OrderingTerm.asc(table.username),
                ]))
              .get();
      return Result<List<User>>.ok(rows.map(_toEntity).toList(growable: false));
    } on Object catch (error, stackTrace) {
      AppLogger.instance.error(
        'Failed to read users',
        name: _logName,
        error: error,
        stackTrace: stackTrace,
      );
      return Result<List<User>>.err(
        StorageFailure(
          message: _readFailedMessage,
          cause: error,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  @override
  Future<Result<User>> readById(String id) async {
    try {
      final UserRow? row = await _findById(id);
      if (row == null) {
        return const Result<User>.err(_notFound);
      }
      return Result<User>.ok(_toEntity(row));
    } on Object catch (error, stackTrace) {
      AppLogger.instance.error(
        'Failed to read user $id',
        name: _logName,
        error: error,
        stackTrace: stackTrace,
      );
      return Result<User>.err(
        StorageFailure(
          message: _readFailedMessage,
          cause: error,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  @override
  Future<Result<User>> readByUsername(String username) async {
    try {
      final UserRow? row =
          await (database.select(database.users)
                ..where(($UsersTable table) => table.username.equals(username)))
              .getSingleOrNull();
      if (row == null) {
        return const Result<User>.err(_notFound);
      }
      return Result<User>.ok(_toEntity(row));
    } on Object catch (error, stackTrace) {
      AppLogger.instance.error(
        'Failed to read user by name',
        name: _logName,
        error: error,
        stackTrace: stackTrace,
      );
      return Result<User>.err(
        StorageFailure(
          message: _readFailedMessage,
          cause: error,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  @override
  Future<Result<User>> create({
    required User user,
    required String action,
    Map<String, Object?> payload = const <String, Object?>{},
  }) async {
    try {
      final Failure? failure = await unitOfWork.run<Failure?>(() async {
        // Checked inside the transaction so the uniqueness rule holds even if
        // two writes race; the unique index stays the last line of defence.
        final UserRow? existing =
            await (database.select(database.users)..where(
                  ($UsersTable table) => table.username.equals(user.username),
                ))
                .getSingleOrNull();
        if (existing != null) {
          return const ConflictFailure(
            message: 'That username is already taken.',
            code: UserRepository.usernameTakenCode,
          );
        }
        // A user must point at a role that exists; checking first turns a raw
        // foreign-key error into a message the form can show.
        final RoleRow? role =
            await (database.select(database.roles)..where(
                  ($RolesTable table) => table.code.equals(user.roleCode),
                ))
                .getSingleOrNull();
        if (role == null) {
          return const ValidationFailure(
            message: 'Choose a role that exists.',
            code: UserRepository.roleUnknownCode,
          );
        }
        await database
            .into(database.users)
            .insert(
              UsersCompanion.insert(
                id: user.id,
                username: user.username,
                displayName: user.displayName,
                roleCode: user.roleCode,
                createdAt: user.createdAt,
                passwordHash: Value<String?>(user.passwordHash),
                pinHash: Value<String?>(user.pinHash),
              ),
            );
        await auditService.append(
          action: action,
          entity: auditEntity,
          entityId: user.id,
          payload: payload,
        );
        return null;
      });
      return failure == null
          ? Result<User>.ok(user)
          : Result<User>.err(failure);
    } on Object catch (error, stackTrace) {
      AppLogger.instance.error(
        'Failed to create user ${user.id}',
        name: _logName,
        error: error,
        stackTrace: stackTrace,
      );
      return Result<User>.err(
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
        final UserRow? row = await _findById(id);
        if (row == null) {
          return _notFound;
        }
        if (row.disabledAt != null) {
          // Nothing changes, so nothing is audited (see the interface docs).
          return null;
        }
        final DateTime now = clock.nowUtc();
        await (database.update(
          database.users,
        )..where(($UsersTable table) => table.id.equals(id))).write(
          UsersCompanion(
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
        'Failed to disable user $id',
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

  /// The failure returned when a user id does not resolve to a row.
  static const NotFoundFailure _notFound = NotFoundFailure(
    message: 'That user no longer exists.',
    code: UserRepository.notFoundCode,
  );

  Future<UserRow?> _findById(String id) => (database.select(
    database.users,
  )..where(($UsersTable table) => table.id.equals(id))).getSingleOrNull();

  User _toEntity(UserRow row) => User(
    id: row.id,
    username: row.username,
    displayName: row.displayName,
    roleCode: row.roleCode,
    createdAt: row.createdAt,
    passwordHash: row.passwordHash,
    pinHash: row.pinHash,
    disabledAt: row.disabledAt,
    updatedAt: row.updatedAt,
  );
}
