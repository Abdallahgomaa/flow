import 'package:drift/drift.dart';

/// Opens the low-level [QueryExecutor] backing the application database.
///
/// The concrete engine is injected so the application can use an encrypted
/// SQLCipher database while host tests use plain SQLite (see
/// `docs/P0-11_sqlite_spike.md`). Depend on this abstraction, never on a
/// specific engine.
///
/// (Named `DatabaseConnector`, not `DatabaseOpener`: the latter is exported by
/// `package:drift/drift.dart` itself.)
abstract interface class DatabaseConnector {
  /// Creates a new executor. The caller owns its lifecycle and must close it.
  QueryExecutor open();
}
