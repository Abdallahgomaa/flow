# P0-15 — `audit_log`, append-only triggers and the hash chain

**Date:** 2026-10-13 · **Author:** Big Pickle (OpenCode) · **Status:** implemented (host-verified)

## Table

`audit_log` (Drift table `AuditLog`, schema **version 2**):

| Column | Type | Meaning |
|---|---|---|
| `seq` | INTEGER PK autoincrement | insertion order = chain order |
| `occurred_at` | DateTime (UTC) | when the event happened |
| `actor` | TEXT NULL | `system`, a user id, … |
| `action` | TEXT | stable action id, e.g. `setting.write` |
| `entity` | TEXT | affected entity/table |
| `entity_id` | TEXT NULL | affected row identity |
| `payload` | TEXT | canonical (key-sorted) JSON |
| `prev_hash` | TEXT | hash of the previous row (64 zeros for genesis) |
| `hash` | TEXT | SHA-256(prevHash + canonical record) |

## Append-only enforcement

SQLite has no "deny" privilege, so two triggers created in the migration abort
any mutation:

```sql
CREATE TRIGGER IF NOT EXISTS audit_log_no_update
BEFORE UPDATE ON audit_log BEGIN
  SELECT RAISE(ABORT, 'audit_log is append-only');
END;
```

(and the equivalent `audit_log_no_delete`).

## Hash chain

`AuditService.append()` reads the current tail, uses its `hash` as `prev_hash`
(or 64 zeros for the first row), computes
`SHA-256(canonicalJson({prevHash, occurredAt, actor, action, entity, entityId, payload}))`
and inserts the row with `RETURNING`. `canonicalJson` sorts the top-level keys so
the same logical record always hashes identically (keep payloads flat).

Expected use is inside a `UnitOfWork`, so the audit row commits or rolls back
with the business change it records (AGENTS rules 3 and 4).

## Verification (host, plain SQLite)

`test/core/database/audit_service_test.dart`:

- genesis `prev_hash` and link-by-link chaining across three entries;
- `hashEntry` reproducibility and payload sensitivity;
- audit rows commit inside a `UnitOfWork`;
- audit rows roll back when the transaction throws;
- `UPDATE` and `DELETE` are rejected and the row is left untouched.

## Migration

Version 1 → 2 adds the table and the triggers (`onUpgrade`). Fresh databases get
them from `onCreate`. Schema snapshots begin with the first shipped release.
