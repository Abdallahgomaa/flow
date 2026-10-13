import 'package:drift/drift.dart';
import 'package:flow/core/database/database.dart';
import 'package:flow/core/result/failure.dart';
import 'package:flow/core/result/result.dart';
import 'package:flow/core/utils/clock.dart';
import 'package:flow/core/utils/logger.dart';

import '../domain/settings_repository.dart';

/// Drift-backed [SettingsRepository] over the `app_settings` key/value table.
///
/// A save writes every row **and** the audit entry inside one transaction, so a
/// crash can never leave settings changed but unaudited (AGENTS rule 3). Errors
/// are translated to [StorageFailure] instead of leaking engine exceptions.
final class DriftSettingsRepository implements SettingsRepository {
  /// Creates the repository.
  const DriftSettingsRepository({
    required this.database,
    required this.unitOfWork,
    required this.auditService,
    required this.clock,
  });

  /// Entity name recorded in the audit log.
  static const String auditEntity = 'app_settings';

  /// Logger component name.
  static const String _logName = 'settings.repository';

  /// The database holding `app_settings`.
  final AppDatabase database;

  /// Groups the writes into one transaction.
  final UnitOfWork unitOfWork;

  /// Appends the audit entry for each save.
  final AuditService auditService;

  /// Time source for `updated_at` and the audit entry.
  final Clock clock;

  @override
  Future<Result<Map<String, String>>> readAll() async {
    try {
      final List<AppSetting> rows = await database
          .select(database.appSettings)
          .get();
      return Result<Map<String, String>>.ok(<String, String>{
        for (final AppSetting row in rows) row.key: row.value,
      });
    } on Object catch (error, stackTrace) {
      AppLogger.instance.error(
        'Could not read app settings.',
        name: _logName,
        error: error,
        stackTrace: stackTrace,
      );
      return Result<Map<String, String>>.err(
        StorageFailure(
          message: 'Could not read the saved settings.',
          cause: error,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  @override
  Future<Result<void>> save({
    required Map<String, String> values,
    required String action,
    Map<String, Object?> payload = const <String, Object?>{},
  }) async {
    try {
      await unitOfWork.run(() async {
        final DateTime now = clock.nowUtc();
        for (final MapEntry<String, String> entry in values.entries) {
          await database
              .into(database.appSettings)
              .insertOnConflictUpdate(
                AppSettingsCompanion(
                  key: Value<String>(entry.key),
                  value: Value<String>(entry.value),
                  updatedAt: Value<DateTime>(now),
                ),
              );
        }
        await auditService.append(
          action: action,
          entity: auditEntity,
          payload: payload,
        );
      });
      return const Result<void>.ok(null);
    } on Object catch (error, stackTrace) {
      AppLogger.instance.error(
        'Could not save app settings.',
        name: _logName,
        error: error,
        stackTrace: stackTrace,
      );
      return Result<void>.err(
        StorageFailure(
          message: 'Could not save the settings.',
          cause: error,
          stackTrace: stackTrace,
        ),
      );
    }
  }
}
