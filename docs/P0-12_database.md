# P0-12 — `AppDatabase` (Drift) + encrypted connection + PRAGMAs

**Date:** 2026-10-13 · **Author:** Big Pickle (OpenCode) · **Status:** DONE (host-verified)

## Design

The database is split into three layers so the engine stays swappable:

| Layer | File | Responsibility |
|---|---|---|
| Schema + migrations | `lib/core/database/app_database.dart` | Drift `@DriftDatabase`, `schemaVersion`, `MigrationStrategy`, `foreign_keys` re-assertion. |
| Engine abstraction | `lib/core/database/database_connector.dart` | `DatabaseConnector.open() → QueryExecutor`. No engine-specific imports. |
| Connection PRAGMAs | `lib/core/database/database_pragmas.dart` | `WAL`, `foreign_keys = ON`, `secure_delete = ON`, applied on every connection. |
| Production engine | `lib/app/database/sqlcipher_database_connector.dart` | `NativeDatabase` over a file, `PRAGMA key` **first**, then the shared pragmas. |

Because the engine is injected, the **app** runs on SQLCipher while **host tests**
run on plain SQLite. `PRAGMA key` is deliberately the first statement issued on
the connection, as SQLCipher requires it before any other command (including
`PRAGMA journal_mode`).

## Schema (version 1)

`app_settings` — a key/value table (`key` PK, `value`, `updated_at`). It is the
first table and grows with the app. Drift stores `DateTime` as a Unix-seconds
integer by default.

## Verification

Host (`flutter test`, plain SQLite) asserts the connection configuration and a
round-trip:

- `PRAGMA foreign_keys` = 1
- `PRAGMA secure_delete` = 1
- `PRAGMA journal_mode` = `wal`
- insert/read of an `app_settings` row

### Device / integration only (cannot run on host)

`sqlcipher_flutter_libs` links the encrypted engine **only inside application
builds** (see `docs/P0-11_sqlite_spike.md`). Therefore these P0-12 acceptance
criteria are verified on a **device/app run**, not by `flutter test`:

- `PRAGMA cipher_version` is non-empty.
- A wrong key fails to open the database.
- A plain SQLite client cannot open the file.
