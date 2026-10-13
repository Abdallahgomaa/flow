import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flow/core/database/database_connector.dart';
import 'package:flow/core/database/database_pragmas.dart';
import 'package:sqlite3/sqlite3.dart';

/// Opens a file-backed, SQLCipher-encrypted database.
///
/// `PRAGMA key` must be the very first statement issued on a connection, so it
/// is executed inside `NativeDatabase.setup` before any other pragma or query.
/// [keyHex] is the 64-character hex form of the 32-byte data-encryption key
/// produced by the key manager (P0-13).
///
/// On desktop/host runs no SQLCipher engine is linked (see
/// `docs/P0-11_sqlite_spike.md`), so this connector is used by the real app
/// build; tests inject a plain-SQLite connector instead.
class SqlCipherDatabaseConnector implements DatabaseConnector {
  SqlCipherDatabaseConnector({required this.file, required this.keyHex});

  /// Database file on disk.
  final File file;

  /// 32-byte data-encryption key, hex-encoded.
  final String keyHex;

  @override
  QueryExecutor open() => NativeDatabase(
    file,
    setup: (Database db) {
      db.execute("PRAGMA key = \"x'$keyHex'\";");
      DatabasePragmas.apply(db);
    },
  );
}
