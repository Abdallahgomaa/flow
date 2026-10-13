# P0-11 — Spike: SQLite / SQLCipher / FTS5 availability

**Date:** 2026-10-13 · **Author:** Big Pickle (OpenCode) · **Status:** DONE (decision recorded)

## Goal

Decide the persistence engine's capabilities *before* building `AppDatabase`
(P0-12): is SQLCipher available, is FTS5 available, and how do we test both on
this project.

## Method

A throwaway probe (`test/spike/sqlite_spike_test.dart`, since deleted) opened an
in-memory database through `package:sqlite3` and queried `sqlite_version()`,
`pragma cipher_version`, and whether `CREATE VIRTUAL TABLE … USING fts5(…)`
succeeds.

## Results (measured on the Windows dev host)

| Probe | Result |
|---|---|
| `sqlite_version()` | `3.53.4` |
| `pragma cipher_version` | *(empty)* |
| `CREATE VIRTUAL TABLE … USING fts5(…)` | **supported** |

## Decisions

1. **FTS5: yes.** Full-text search will be built on FTS5; a `LIKE` path is kept
   only as a defensive fallback for platforms that ship an FTS5-less SQLite
   (P2-06 references this decision).
2. **SQLCipher is app-only.** `sqlcipher_flutter_libs` installs the encrypted
   engine inside *application* builds (Android / Windows / iOS), **not** inside
   the host `flutter test` VM. Consequently:
   - The database connection is an **injectable abstraction**: `AppDatabase`
     receives an opener. Device builds use SQLCipher; host tests use plain
     SQLite.
   - Cipher assertions (`cipher_version` non-empty, a wrong key is rejected, a
     plain SQLite client cannot open the file) are verified on a
     **device/integration** run. Host unit tests cover PRAGMAs, the
     schema/migrations, repositories, `UnitOfWork` and the audit hash chain.

## Environment note (developer blocker discovered here)

The installed Flutter SDK path is `D:\flow business\flutter\flutter`, which
contains a space. Flutter's native-assets hook invokes `dart compile kernel`
with that path **unquoted**, so `cmd` splits at the space and the build fails
(`'D:\flow' is not recognized…`) for any program whose asset graph includes
`package:sqlite3` (drift ≥ 2.35 requires sqlite3 ≥ 3.4, which hard-requires
native assets).

Workaround used in this session:

```powershell
subst Z: "D:\flow business\flutter\flutter"
Z:\bin\flutter.bat test          # space-free drive letter → hook compiles
```

Disabling native assets is **not** viable — sqlite3 3.x refuses to run without
the `dart assets` feature.

**Durable fix:** install/move the Flutter SDK to a space-free path (e.g.
`D:\flutter`) and update `PATH`.
