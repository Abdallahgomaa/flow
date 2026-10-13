import 'package:sqlite3/sqlite3.dart';

/// Connection PRAGMAs that Flow requires on **every** database connection.
///
/// They are applied by both the production opener (SQLCipher, via
/// `NativeDatabase.setup`) and the test opener (plain SQLite), so the two
/// environments behave identically. Journal mode cannot be changed inside a
/// transaction, which is why these run at the connection level.
abstract final class DatabasePragmas {
  /// Write-ahead logging: better concurrency and crash resilience.
  static const String journalMode = 'WAL';

  /// SQLite disables foreign keys per connection by default.
  static const String foreignKeys = 'ON';

  /// Zero freed pages so deleted rows do not linger in the file at rest.
  static const String secureDelete = 'ON';

  /// Applies every pragma to the given raw [database].
  static void apply(Database database) {
    database.execute('PRAGMA journal_mode = $journalMode;');
    database.execute('PRAGMA foreign_keys = $foreignKeys;');
    database.execute('PRAGMA secure_delete = $secureDelete;');
  }
}
