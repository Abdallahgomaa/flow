import 'app_database.dart';

/// Runs a set of writes as one atomic unit of work.
///
/// Use cases depend on this abstraction (never on a concrete database) so that
/// the "all or nothing" guarantee is testable and the storage engine stays
/// swappable. Any error thrown by [run]'s action rolls the whole unit back.
abstract interface class UnitOfWork {
  /// Executes [action] inside a single transaction.
  ///
  /// Nested writes performed on the same database during [action] join the
  /// transaction. If [action] throws, every write in the unit is rolled back
  /// and the error is rethrown to the caller.
  Future<T> run<T>(Future<T> Function() action);
}

/// The Drift-backed [UnitOfWork].
///
/// Drift installs the transaction executor for the duration of the callback,
/// so the repositories (which hold the same [AppDatabase]) automatically write
/// inside it.
class DriftUnitOfWork implements UnitOfWork {
  const DriftUnitOfWork(this.database);

  /// The database whose writes are grouped.
  final AppDatabase database;

  @override
  Future<T> run<T>(Future<T> Function() action) =>
      database.transaction<T>(action);
}
