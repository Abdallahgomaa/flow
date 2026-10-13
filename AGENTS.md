# AGENTS.md — Flow

Guidance for AI coding agents (and humans) working on **Flow**, an offline-first
business & point-of-sale app built with Flutter.

> **Read `EXECUTION_STATE.md` first.** It is the single source of truth for the
> project state. Never rebuild or edit anything already marked `[DONE]` except to
> fix an integration problem — and then only with the smallest possible change,
> a regression test, and a short integration report (problem, cause, fix, proof).

Companion documents:

- `EXECUTION_STATE.md` — authoritative progress tracker and working rules.
- `docs/DAY2_PLAN.md` — the Day-2 step plan (Money, Clock/UUID, l10n, router).

---

## 1. Binding architecture rules

These rules come from the Technical Architecture spec (§11) and must never be
broken. `tool/check_boundaries.dart` enforces the import-related ones in CI.

1. **No duplicated logic.** One implementation per concern; share via `core/`
   or `shared/`, never copy-paste between features.
2. **`Money` is never a `double`.** Monetary values use the `Money` value object
   (integer minor units). The same applies to quantities (`Quantity`, integer
   thousandths). No floating point for money or amounts anywhere.
3. **Every write goes through a use case + `UnitOfWork` and is audited.**
   (Lands with the database steps; keep use cases the only mutators.)
4. **Append-only tables** for ledgers/audit — never update or delete history.
5. **Permissions/PIN checks live inside use cases**, never only in the UI.
6. **No network, no secrets, no PII.** The app is offline-first; logs pass
   through `Redactor` and never contain secrets or personal data.
7. **Schema changes ship with a migration, a data snapshot, and a test.**
8. **Generated files are read-only.** Never hand-edit `*.g.dart` or
   `*.freezed.dart`; regenerate with `dart run build_runner build`.
9. **Interface first.** Depend on abstractions (`abstract interface class`) and
   inject implementations, so everything is testable.
10. **One step at a time.** Work only within the current step's scope.

---

## 2. Working rules (from `EXECUTION_STATE.md`)

1. Read `EXECUTION_STATE.md` fully before touching code.
2. Implement exactly one step per iteration; never skip ahead.
3. Keep code clean, flexible and extensible; comment the why, not the what.
4. Every step ships with its own tests.
5. On any contradiction between the state file and the real project, **stop and
   report** — do not guess.
6. Update `EXECUTION_STATE.md` after every step (header, checklist, change log).

---

## 3. Layer boundaries

Enforced by `dart run tool/check_boundaries.dart` (fails CI on violation).

| Layer | May import | Must not import |
|---|---|---|
| `lib/features/<f>/domain/` | pure Dart, `core/`, same-feature `domain/` | Flutter, Drift, Riverpod, `data/`, `presentation/` |
| `lib/features/<f>/data/` | `core/`, `shared/`, same-feature `domain/`, `data/` | same-feature `presentation/` |
| `lib/features/<f>/presentation/` | `core/`, `shared/`, same-feature `domain/`, `data/`, `presentation/` | other features' `data/`/`presentation/`, `app/` |
| `lib/core/` | `core/` | `shared/`, `features/`, `app/` |
| `lib/shared/` | `core/`, `shared/` | `features/`, `app/` |
| `lib/app/` | anything | — |

Cross-feature access is allowed **only** through the other feature's barrel
(`lib/features/<other>/<other>.dart`) or its `domain/` layer. A feature must
never reach into another feature's `data/` or `presentation/`.

---

## 4. Conventions

- **File names:** `snake_case.dart`; one primary type per file.
- **Imports:** use `package:flow/...` for anything outside the current folder;
  keep relative imports for siblings (`./`, `../`) inside the same feature.
- **Dart style:** `dart format` is authoritative; lints come from
  `analysis_options.yaml` (stricter than `flutter_lints`).
- **Domain purity:** `core/money`, `core/utils` and every `domain/` file are
  pure Dart — no Flutter imports.
- **State:** Riverpod 3 with code generation (`@riverpod`); never hand-write
  providers that codegen can produce.
- **Errors:** return `Result<T>` from use cases/repositories; never throw for
  expected business failures. `Failure` subclasses carry user-safe messages.
- **Commit messages:** `P0-06: add Money and Rate value objects`.

---

## 5. Standard verification commands

Run these after every step; all must be clean before moving on.

```bash
dart format --set-exit-if-changed .
flutter pub get
flutter analyze                        # "No issues found!"
dart run tool/check_boundaries.dart    # "Boundary check passed."
flutter test                           # whole suite green
```

For UI steps also run the app:

```bash
flutter run --dart-define=APP_FLAVOR=dev
```

---

## 6. Repository map

```
lib/
  app/        # composition root: router, shell, theme assembly, l10n wiring
  core/       # pure, feature-agnostic building blocks (money, result, utils, error)
  features/   # feature-first modules: <name>/{domain,data,presentation}
  shared/     # cross-feature UI: design tokens, widgets, l10n
  bootstrap.dart
  main.dart
test/         # mirrors lib/ ; unit + widget tests
tool/         # developer tooling (architecture checker)
```
