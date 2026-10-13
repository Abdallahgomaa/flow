import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:drift/drift.dart';
import 'package:flow/core/utils/canonical_json.dart';
import 'package:flow/core/utils/clock.dart';

import 'app_database.dart';
import 'audit_chain_status.dart';

/// Appends entries to the append-only `audit_log` while maintaining a SHA-256
/// hash chain, and verifies that chain (P0-15 / P0-16).
///
/// Callers must run [append] inside a `UnitOfWork` so the audit row commits
/// together with the business change it describes (AGENTS rule 3). The audit
/// tables reject UPDATE/DELETE at the database level.
class AuditService {
  /// Creates the service over [database], stamping entries with [clock].
  AuditService({required this.database, required this.clock});

  /// The database the chain lives in.
  final AppDatabase database;

  /// Time source for `occurred_at` / `created_at` (UTC).
  final Clock clock;

  /// `prev_hash` of the very first row: 64 zeros.
  static final String genesisHash = List<String>.filled(64, '0').join();

  /// Appends one entry and returns the inserted row.
  ///
  /// [payload] must be JSON-encodable; its keys are sorted so the hash is
  /// reproducible. Nested maps are not re-sorted (keep payloads flat).
  Future<AuditLogData> append({
    required String action,
    required String entity,
    String? entityId,
    String? actor,
    Map<String, Object?> payload = const <String, Object?>{},
  }) async {
    // Drift persists `DateTime` with second precision (a Unix timestamp in
    // seconds), so the timestamp is truncated before it is hashed *and* stored:
    // what the hash covers must be exactly what the database can round-trip,
    // otherwise [verifyChain] would recompute a different hash.
    final DateTime occurredAt = _toWholeSeconds(clock.nowUtc());
    final String payloadJson = canonicalJson(payload);

    final AuditLogData? previous = await _tail();
    final String prevHash = previous?.hash ?? genesisHash;

    final String hash = await hashEntry(
      prevHash: prevHash,
      occurredAt: occurredAt,
      actor: actor,
      action: action,
      entity: entity,
      entityId: entityId,
      payloadJson: payloadJson,
    );

    return database
        .into(database.auditLog)
        .insertReturning(
          AuditLogCompanion.insert(
            occurredAt: occurredAt,
            actor: Value<String?>(actor),
            action: action,
            entity: entity,
            entityId: Value<String?>(entityId),
            payload: payloadJson,
            prevHash: prevHash,
            hash: hash,
          ),
        );
  }

  /// Pins the current tail of the chain as a checkpoint.
  ///
  /// Returns `null` when the chain is empty. Call it periodically (for example
  /// at the end of a shift) so a later tamper has fewer rows to hide behind.
  Future<AuditCheckpoint?> checkpoint() async {
    final AuditLogData? tail = await _tail();
    if (tail == null) {
      return null;
    }
    return database
        .into(database.auditCheckpoints)
        .insertReturning(
          AuditCheckpointsCompanion.insert(
            seq: Value<int>(tail.seq),
            hash: tail.hash,
            createdAt: clock.nowUtc(),
          ),
        );
  }

  /// Recomputes the whole chain and every checkpoint.
  ///
  /// Returns the **first** broken link so tampering can be located precisely.
  Future<AuditChainStatus> verifyChain() async {
    final List<AuditLogData> rows =
        await (database.select(database.auditLog)
              ..orderBy(<OrderingTerm Function($AuditLogTable)>[
                ($AuditLogTable t) => OrderingTerm.asc(t.seq),
              ]))
            .get();

    final Map<int, AuditLogData> bySeq = <int, AuditLogData>{
      for (final AuditLogData row in rows) row.seq: row,
    };

    String expectedPrev = genesisHash;
    int checked = 0;
    for (final AuditLogData row in rows) {
      if (row.prevHash != expectedPrev) {
        return AuditChainStatus.broken(
          checkedEntries: checked,
          firstBrokenSeq: row.seq,
          reason: 'prev_hash does not match the previous entry',
        );
      }
      final String recomputed = await hashEntry(
        prevHash: row.prevHash,
        occurredAt: row.occurredAt,
        actor: row.actor,
        action: row.action,
        entity: row.entity,
        entityId: row.entityId,
        payloadJson: row.payload,
      );
      if (recomputed != row.hash) {
        return AuditChainStatus.broken(
          checkedEntries: checked,
          firstBrokenSeq: row.seq,
          reason: 'stored hash does not match the recomputed hash',
        );
      }
      expectedPrev = row.hash;
      checked++;
    }

    final List<AuditCheckpoint> checkpoints = await database
        .select(database.auditCheckpoints)
        .get();
    for (final AuditCheckpoint checkpoint in checkpoints) {
      final AuditLogData? anchored = bySeq[checkpoint.seq];
      if (anchored == null || anchored.hash != checkpoint.hash) {
        return AuditChainStatus.broken(
          checkedEntries: checked,
          firstBrokenSeq: checkpoint.seq,
          reason: 'checkpoint no longer matches the chain',
        );
      }
    }

    return AuditChainStatus.valid(checked);
  }

  /// Canonical JSON: a stable encoding with top-level keys sorted, so the same
  /// logical payload always hashes identically.
  ///
  /// Delegates to the shared helper so the audit chain and licence signatures
  /// cannot drift apart.
  static String canonicalJson(Map<String, Object?> value) =>
      encodeCanonicalJson(value);

  /// The SHA-256 hash of one audit entry, hex-encoded.
  ///
  /// [verifyChain] recomputes exactly this to detect tampering.
  static Future<String> hashEntry({
    required String prevHash,
    required DateTime occurredAt,
    required String? actor,
    required String action,
    required String entity,
    required String? entityId,
    required String payloadJson,
  }) async {
    final String canonical = canonicalJson(<String, Object?>{
      'prevHash': prevHash,
      'occurredAt': _toWholeSeconds(occurredAt).toIso8601String(),
      'actor': actor,
      'action': action,
      'entity': entity,
      'entityId': entityId,
      'payload': payloadJson,
    });
    final Hash hash = await Sha256().hash(utf8.encode(canonical));
    return hash.bytes
        .map((int byte) => byte.toRadixString(16).padLeft(2, '0'))
        .join();
  }

  /// Truncates [value] to whole seconds — exactly the precision Drift persists
  /// for a `DateTime` column (it stores a Unix timestamp in seconds).
  ///
  /// Normalising here as well as in [append] makes the hash stable no matter
  /// which side supplies the timestamp, so a value the database cannot
  /// round-trip can never make [verifyChain] report a false tamper.
  static DateTime _toWholeSeconds(DateTime value) {
    final DateTime utc = value.toUtc();
    return DateTime.fromMillisecondsSinceEpoch(
      (utc.millisecondsSinceEpoch ~/ 1000) * 1000,
      isUtc: true,
    );
  }

  /// The newest row of the chain, or `null` when it is empty.
  Future<AuditLogData?> _tail() =>
      (database.select(database.auditLog)
            ..orderBy(<OrderingTerm Function($AuditLogTable)>[
              ($AuditLogTable t) => OrderingTerm.desc(t.seq),
            ])
            ..limit(1))
          .getSingleOrNull();
}
