# P0-16 — `verifyChain()`, checkpoint hashes and tamper detection (Gate G0)

**Date:** 2026-10-13 · **Author:** Big Pickle (OpenCode) · **Status:** DONE (host-verified)

## Goal

Prove that the audit trail cannot be silently rewritten: recompute the whole
hash chain on demand and report the **first** broken link.

## Pieces

| Piece | File | Responsibility |
|---|---|---|
| Chain status | `lib/core/database/audit_chain_status.dart` | `AuditChainStatus.valid(checkedEntries)` / `.broken(checkedEntries:, firstBrokenSeq:, reason:)`. |
| Checkpoints | `lib/core/database/tables/audit_checkpoints.dart` | `audit_checkpoints(seq PK, hash, created_at)` — periodic anchors into the chain. |
| Verification | `lib/core/database/audit_service.dart` | `verifyChain()` + `checkpoint()`; shares `hashEntry()`/`canonicalJson()` with `append()`. |
| Guards | `lib/core/database/app_database.dart` | Append-only triggers for **both** audit tables; schema **v3**. |

## How `verifyChain()` works

1. Read `audit_log` in `seq` order.
2. Start from `genesisHash` (64 zeros) and, for each row:
   - the stored `prev_hash` must equal the previous row's `hash`;
   - the stored `hash` must equal `hashEntry(...)` recomputed from the row.
   Stop at the **first** mismatch and report its `seq`.
3. Finally, every checkpoint's `hash` must equal the current `hash` of the row
   at its `seq`. This catches a rewrite of the tail that keeps the chain
   internally consistent.

## Checkpoints

`AuditService.checkpoint()` pins the current tail (`seq`, `hash`, `created_at`).
Because `audit_checkpoints` is append-only too, an attacker who rewrites history
must also rewrite every checkpoint that anchors it — which `verifyChain()`
detects. Take a checkpoint periodically (for example at the end of a shift).

## Schema v3

`onCreate` creates everything; `onUpgrade` adds `audit_log` for `from < 2` and
`audit_checkpoints` for `from < 3`, then (re)creates the append-only triggers.

## Verification (host, plain SQLite)

`test/core/database/audit_chain_test.dart`:

- an empty chain verifies as intact (`checkedEntries == 0`);
- a clean 7-entry chain with a checkpoint verifies as intact;
- a tampered row (trigger dropped, then `payload` rewritten) is detected and the
  **first broken `seq`** plus a `hash` reason are reported;
- a rewritten tail (forged `hash`) is caught through its checkpoint.

The tamper cases drop the `audit_log_no_update` trigger on purpose: the triggers
block ordinary writes, so the test simulates an attacker editing the database
file directly.

## Gate G0

With P0-16 done, Gate G0 is satisfied: the persistence foundation (encrypted
connection abstraction, pragmas, `UnitOfWork`, append-only audit log with a
verifiable hash chain) is in place and covered by tests.
