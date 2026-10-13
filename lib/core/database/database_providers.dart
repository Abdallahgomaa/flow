import 'package:flow/core/utils/utils_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'app_database.dart';
import 'audit_service.dart';
import 'database_connector.dart';
import 'unit_of_work.dart';

part 'database_providers.g.dart';

/// The low-level engine that backs [appDatabaseProvider].
///
/// There is no safe default (the app must pick SQLCipher and the file
/// location), so `bootstrap` overrides it — the same pattern as
/// `appFlavorProvider`. Tests override it with an in-memory connector.
@Riverpod(keepAlive: true)
DatabaseConnector databaseConnector(Ref ref) => throw StateError(
  'databaseConnectorProvider must be overridden (see lib/bootstrap.dart).',
);

/// The application database, opened on first use and closed on dispose.
///
/// Everything that persists lives behind this provider, so there is exactly
/// one connection for the whole process.
@Riverpod(keepAlive: true)
AppDatabase appDatabase(Ref ref) {
  final AppDatabase database = AppDatabase(
    ref.watch(databaseConnectorProvider).open(),
  );
  ref.onDispose(database.close);
  return database;
}

/// Groups writes into atomic units of work (AGENTS rule 3).
@Riverpod(keepAlive: true)
UnitOfWork unitOfWork(Ref ref) =>
    DriftUnitOfWork(ref.watch(appDatabaseProvider));

/// Appends to the append-only audit chain of [appDatabaseProvider].
@Riverpod(keepAlive: true)
AuditService auditService(Ref ref) => AuditService(
  database: ref.watch(appDatabaseProvider),
  clock: ref.watch(clockProvider),
);
