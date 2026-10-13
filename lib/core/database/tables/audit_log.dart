import 'package:drift/drift.dart';

/// Append-only audit trail.
///
/// Every row links to the previous one through [prevHash], forming a hash chain
/// that `AuditService` and `verifyChain()` (P0-16) can validate. UPDATE and
/// DELETE are blocked by database triggers created in the migration, so the
/// chain cannot be rewritten through the SQL surface (AGENTS rule 4).
class AuditLog extends Table {
  /// Monotonic sequence; insertion order is chain order.
  IntColumn get seq => integer().autoIncrement()();

  /// When the event happened (UTC).
  DateTimeColumn get occurredAt => dateTime()();

  /// Who caused it (`system`, a user id, …). Null for background events.
  TextColumn get actor => text().nullable()();

  /// Stable action id, for example `setting.write`.
  TextColumn get action => text()();

  /// Affected entity / table name.
  TextColumn get entity => text()();

  /// Affected row identity, when applicable.
  TextColumn get entityId => text().nullable()();

  /// Canonical (key-sorted) JSON payload.
  TextColumn get payload => text()();

  /// Hash of the previous row; 64 zeros for the genesis row.
  TextColumn get prevHash => text()();

  /// SHA-256 over `prevHash` + the canonical record.
  TextColumn get hash => text()();
}
