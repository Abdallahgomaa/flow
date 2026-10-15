import 'package:drift/drift.dart';
import 'package:flow/core/database/database.dart';
import 'package:flow/core/money/money_core.dart';
import 'package:flow/core/result/failure.dart';
import 'package:flow/core/result/result.dart';
import 'package:flow/core/utils/clock.dart';
import 'package:flow/core/utils/logger.dart';

import '../domain/barcode.dart';
import '../domain/barcode_repository.dart';

/// Drift-backed [BarcodeRepository] (`P2-03`).
///
/// Every write wraps the row change **and** its audit entry in a single
/// [UnitOfWork] transaction (AGENTS rule 3), so a label can never exist without
/// the audit row that explains it.
///
/// Nothing here knows about money or the shop currency: a barcode is an
/// identity, not a price. The multiplier is stored as an integer (thousandths)
/// because that is the only representation that is exact.
///
/// Uniqueness is enforced in two places on purpose. Inside the transaction the
/// repository checks whether the code is taken, so the caller gets a clean
/// [ConflictFailure] it can explain instead of a database exception; the `UNIQUE`
/// constraint on the column stays the last line of defence, so no writer — not
/// even a future one that forgets the check — can create a duplicate code.
final class DriftBarcodeRepository implements BarcodeRepository {
  /// Creates the repository over its injected collaborators.
  const DriftBarcodeRepository({
    required this.database,
    required this.unitOfWork,
    required this.auditService,
    required this.clock,
  });

  /// Audit entity name recorded for every barcode change.
  static const String auditEntity = 'barcodes';

  static const String _logName = 'catalog.barcode_repository';
  static const String _readFailedMessage = 'Could not load the barcodes.';
  static const String _createFailedMessage = 'Could not save the barcode.';
  static const String _disableFailedMessage = 'Could not disable the barcode.';

  /// The database whose `barcodes` table is read and written.
  final AppDatabase database;

  /// Groups every write with its audit entry.
  final UnitOfWork unitOfWork;

  /// Appends the audit entry that explains a write.
  final AuditService auditService;

  /// Supplies the timestamps used when disabling a label.
  final Clock clock;

  @override
  Future<Result<List<Barcode>>> readForProduct(String productId) async {
    try {
      final List<BarcodeRow> rows =
          await (database.select(database.barcodes)
                ..where(
                  ($BarcodesTable table) => table.productId.equals(productId),
                )
                ..orderBy(<OrderingTerm Function($BarcodesTable)>[
                  ($BarcodesTable table) => OrderingTerm.asc(table.createdAt),
                ]))
              .get();
      return Result<List<Barcode>>.ok(
        rows.map(_toEntity).toList(growable: false),
      );
    } on Object catch (error, stackTrace) {
      AppLogger.instance.error(
        'Failed to read the barcodes of product $productId',
        name: _logName,
        error: error,
        stackTrace: stackTrace,
      );
      return Result<List<Barcode>>.err(
        StorageFailure(
          message: _readFailedMessage,
          cause: error,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  @override
  Future<Result<Barcode>> readByCode(String code) async {
    try {
      // Active labels only: a retired code is reserved to the product it used to
      // identify, so a scan must not resolve to it (see the interface docs).
      final BarcodeRow? row = await _findByCode(code, activeOnly: true);
      if (row == null) {
        return const Result<Barcode>.err(_notFound);
      }
      return Result<Barcode>.ok(_toEntity(row));
    } on Object catch (error, stackTrace) {
      AppLogger.instance.error(
        'Failed to read barcode $code',
        name: _logName,
        error: error,
        stackTrace: stackTrace,
      );
      return Result<Barcode>.err(
        StorageFailure(
          message: _readFailedMessage,
          cause: error,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  @override
  Future<Result<Barcode>> readById(String id) async {
    try {
      final BarcodeRow? row = await _find(id);
      if (row == null) {
        return const Result<Barcode>.err(_notFound);
      }
      return Result<Barcode>.ok(_toEntity(row));
    } on Object catch (error, stackTrace) {
      AppLogger.instance.error(
        'Failed to read barcode $id',
        name: _logName,
        error: error,
        stackTrace: stackTrace,
      );
      return Result<Barcode>.err(
        StorageFailure(
          message: _readFailedMessage,
          cause: error,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  @override
  Future<Result<Barcode>> create({
    required Barcode barcode,
    required String action,
    Map<String, Object?> payload = const <String, Object?>{},
  }) async {
    try {
      final Failure? failure = await unitOfWork.run<Failure?>(() async {
        // Checked inside the transaction so the product cannot vanish between
        // the check and the insert; the foreign key stays the last line of
        // defence.
        if (await _findProduct(barcode.productId) == null) {
          return const NotFoundFailure(
            message: 'The product no longer exists.',
            code: BarcodeRepository.productNotFoundCode,
          );
        }
        // The duplicate check lives here, not in the caller, so two writers
        // cannot both pass it.
        if (await _findByCode(barcode.code, activeOnly: false) != null) {
          return const ConflictFailure(
            message: 'That barcode is already used by another product.',
            code: BarcodeRepository.alreadyLinkedCode,
          );
        }
        await database
            .into(database.barcodes)
            .insert(
              BarcodesCompanion.insert(
                id: barcode.id,
                code: barcode.code,
                productId: barcode.productId,
                createdAt: barcode.createdAt,
                multiplierThousandths: Value<int>(
                  barcode.multiplier.thousandths,
                ),
              ),
            );
        await auditService.append(
          action: action,
          entity: auditEntity,
          entityId: barcode.id,
          payload: payload,
        );
        return null;
      });
      return failure == null
          ? Result<Barcode>.ok(barcode)
          : Result<Barcode>.err(failure);
    } on Object catch (error, stackTrace) {
      AppLogger.instance.error(
        'Failed to create barcode ${barcode.id}',
        name: _logName,
        error: error,
        stackTrace: stackTrace,
      );
      return Result<Barcode>.err(
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
        final BarcodeRow? row = await _find(id);
        if (row == null) {
          return _notFound;
        }
        if (_toEntity(row).isDisabled) {
          // Nothing changes, so nothing is audited (see the interface docs).
          return null;
        }
        final DateTime now = clock.nowUtc();
        await (database.update(
          database.barcodes,
        )..where(($BarcodesTable table) => table.id.equals(id))).write(
          BarcodesCompanion(
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
        'Failed to disable barcode $id',
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

  static const NotFoundFailure _notFound = NotFoundFailure(
    message: 'That barcode no longer exists.',
    code: BarcodeRepository.notFoundCode,
  );

  Future<BarcodeRow?> _find(String id) => (database.select(
    database.barcodes,
  )..where(($BarcodesTable table) => table.id.equals(id))).getSingleOrNull();

  /// Finds a label by its code.
  ///
  /// When [activeOnly] is set, retired labels are invisible; the unique
  /// constraint spans them either way, so the duplicate check asks for every
  /// row while the scan path asks for the live one.
  Future<BarcodeRow?> _findByCode(String code, {required bool activeOnly}) {
    final SimpleSelectStatement<$BarcodesTable, BarcodeRow> query =
        database.select(database.barcodes)
          ..where(($BarcodesTable table) => table.code.equals(code));
    if (activeOnly) {
      query.where(($BarcodesTable table) => table.disabledAt.isNull());
    }
    return query.getSingleOrNull();
  }

  Future<ProductRow?> _findProduct(String id) => (database.select(
    database.products,
  )..where(($ProductsTable table) => table.id.equals(id))).getSingleOrNull();

  Barcode _toEntity(BarcodeRow row) => Barcode(
    id: row.id,
    code: row.code,
    productId: row.productId,
    multiplier: Quantity.thousandths(row.multiplierThousandths),
    createdAt: row.createdAt,
    disabledAt: row.disabledAt,
    updatedAt: row.updatedAt,
  );
}
