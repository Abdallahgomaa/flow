import 'package:drift/drift.dart';

/// Periodic anchors into the audit hash chain.
///
/// A checkpoint pins the `hash` of the audit row at [seq]. Because checkpoints
/// are themselves append-only, an attacker who rewrites history would also have
/// to rewrite every checkpoint that anchors it (P0-16).
class AuditCheckpoints extends Table {
  /// The `audit_log.seq` this checkpoint anchors.
  IntColumn get seq => integer()();

  /// The `audit_log.hash` observed at [seq].
  TextColumn get hash => text()();

  /// When the checkpoint was taken.
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{seq};
}
