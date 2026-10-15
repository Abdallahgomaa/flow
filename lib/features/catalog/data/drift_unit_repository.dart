import 'package:drift/drift.dart';
import 'package:flow/core/database/database.dart';
import 'package:flow/core/result/failure.dart';
import 'package:flow/core/result/result.dart';
import 'package:flow/core/utils/clock.dart';
import 'package:flow/core/utils/logger.dart';

import '../domain/unit.dart';
import '../domain/unit_repository.dart';

/// Drift-backed [UnitRepository] (`P2-01`).
///
/// Every write wraps the row change **and** its audit entry in a single
/// [UnitOfWork] transaction (AGENTS rule 3), so a stored unit can never exist
/// without the audit row that explains it.
///
/// The chain of base units stays acyclic because [create] walks up from the
/// proposed base and refuses a unit that would close a loop (for example making
/// `piece` a child of `carton` while `carton` is already defined in terms of
/// `piece`). The walk is bounded by a visited set, so even a row set that was
/// corrupted outside the app cannot hang the repository.
final class DriftUnitRepository implements UnitRepository {
  /// Creates the repository over its injected collaborators.
  const DriftUnitRepository({
    required this.database,
    required this.unitOfWork,
    required this.auditService,
    required this.clock,
  });

  /// Audit entity name recorded for every unit change.
  static const String auditEntity = 'units';

  static const String _logName = 'catalog.unit_repository';
  static const String _readFailedMessage = 'Could not load the units.';
  static const String _createFailedMessage = 'Could not save the unit.';
  static const String _disableFailedMessage = 'Could not disable the unit.';

  /// The database that owns the `units` table.
  final AppDatabase database;

  /// Groups the row change and the audit entry into one transaction.
  final UnitOfWork unitOfWork;

  /// Appends to the append-only audit chain.
  final AuditService auditService;

  /// Supplies the timestamps for updates.
  final Clock clock;

  @override
  Future<Result<List<Unit>>> readAll() async {
    try {
      final List<UnitRow> rows =
          await (database.select(database.units)
                ..orderBy(<OrderingTerm Function($UnitsTable)>[
                  ($UnitsTable table) => OrderingTerm.asc(table.name),
                  ($UnitsTable table) => OrderingTerm.asc(table.code),
                ]))
              .get();
      return Result<List<Unit>>.ok(rows.map(_toEntity).toList(growable: false));
    } on Object catch (error, stackTrace) {
      AppLogger.instance.error(
        'Failed to read units',
        name: _logName,
        error: error,
        stackTrace: stackTrace,
      );
      return Result<List<Unit>>.err(
        StorageFailure(
          message: _readFailedMessage,
          cause: error,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  @override
  Future<Result<Unit>> readByCode(String code) async {
    try {
      final UnitRow? row = await _find(code);
      if (row == null) {
        return const Result<Unit>.err(_notFound);
      }
      return Result<Unit>.ok(_toEntity(row));
    } on Object catch (error, stackTrace) {
      AppLogger.instance.error(
        'Failed to read unit $code',
        name: _logName,
        error: error,
        stackTrace: stackTrace,
      );
      return Result<Unit>.err(
        StorageFailure(
          message: _readFailedMessage,
          cause: error,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  @override
  Future<Result<Unit>> create({
    required Unit unit,
    required String action,
    Map<String, Object?> payload = const <String, Object?>{},
  }) async {
    try {
      final Failure? failure = await unitOfWork.run<Failure?>(() async {
        // Checked inside the transaction so the uniqueness rule holds even if
        // two writes race; the primary key stays the last line of defence.
        if (await _find(unit.code) != null) {
          return const ConflictFailure(
            message: 'A unit with that code already exists.',
            code: UnitRepository.codeTakenCode,
          );
        }
        final String? baseUnitCode = unit.baseUnitCode;
        if (baseUnitCode != null) {
          final UnitRow? base = await _find(baseUnitCode);
          if (base == null) {
            return const NotFoundFailure(
              message: 'The base unit no longer exists.',
              code: UnitRepository.baseNotFoundCode,
            );
          }
          if (await _wouldCycle(base: base, code: unit.code)) {
            return const ConflictFailure(
              message: 'Those units would form a loop.',
              code: UnitRepository.cycleCode,
            );
          }
        }
        await database
            .into(database.units)
            .insert(
              UnitsCompanion.insert(
                code: unit.code,
                name: unit.name,
                createdAt: unit.createdAt,
                baseUnitCode: Value<String?>(baseUnitCode),
                factorThousandths: Value<int?>(unit.factorThousandths),
              ),
            );
        await auditService.append(
          action: action,
          entity: auditEntity,
          entityId: unit.code,
          payload: payload,
        );
        return null;
      });
      return failure == null
          ? Result<Unit>.ok(unit)
          : Result<Unit>.err(failure);
    } on Object catch (error, stackTrace) {
      AppLogger.instance.error(
        'Failed to create unit ${unit.code}',
        name: _logName,
        error: error,
        stackTrace: stackTrace,
      );
      return Result<Unit>.err(
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
        final UnitRow? row = await _find(code);
        if (row == null) {
          return _notFound;
        }
        if (_toEntity(row).isDisabled) {
          // Nothing changes, so nothing is audited (see the interface docs).
          return null;
        }
        final DateTime now = clock.nowUtc();
        await (database.update(
          database.units,
        )..where(($UnitsTable table) => table.code.equals(code))).write(
          UnitsCompanion(
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
        'Failed to disable unit $code',
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

  /// The failure returned when a unit code does not resolve to a row.
  static const NotFoundFailure _notFound = NotFoundFailure(
    message: 'That unit no longer exists.',
    code: UnitRepository.notFoundCode,
  );

  /// Whether walking up from [base] reaches [code], which would close a loop.
  ///
  /// The visited set makes the walk terminate even if the stored chain already
  /// contains a loop, in which case extending it is refused.
  Future<bool> _wouldCycle({
    required UnitRow base,
    required String code,
  }) async {
    final Set<String> visited = <String>{};
    UnitRow? current = base;
    while (current != null) {
      if (current.code == code || !visited.add(current.code)) {
        return true;
      }
      final String? baseUnitCode = current.baseUnitCode;
      current = baseUnitCode == null ? null : await _find(baseUnitCode);
    }
    return false;
  }

  Future<UnitRow?> _find(String code) => (database.select(
    database.units,
  )..where(($UnitsTable table) => table.code.equals(code))).getSingleOrNull();

  Unit _toEntity(UnitRow row) => Unit(
    code: row.code,
    name: row.name,
    createdAt: row.createdAt,
    baseUnitCode: row.baseUnitCode,
    factorThousandths: row.factorThousandths,
    disabledAt: row.disabledAt,
    updatedAt: row.updatedAt,
  );
}
