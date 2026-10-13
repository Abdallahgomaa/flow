import 'package:drift/drift.dart';

/// Generic application settings store.
///
/// A single key/value table: values are stored as text and typed at the edge
/// (the repository layer owns serialisation). It is the first table and grows
/// with the app.
class AppSettings extends Table {
  /// Stable setting identifier (for example `theme_mode`).
  TextColumn get key => text()();

  /// Serialised value.
  TextColumn get value => text()();

  /// Last update, in UTC.
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{key};
}
