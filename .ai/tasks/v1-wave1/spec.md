# V1 Wave 1 — Dependencies, Riverpod, Application Layer, Preferences

## Objective

Set up the V1 toolchain (Riverpod, shared_preferences, Drift deps + codegen), create the application layer with preference providers, persist the standard/custom mode and custom threshold, and make the welcome dialog first-run-only using the persisted preference.

## Task mapping

User wave plan references "V1-001..003" for this content, but `docs/tasks/v1/` numbering differs:

| Wave 1 content | Doc task |
|---|---|
| Add all V1 dependencies + codegen config | V1-001 |
| Preference persistence (`SharedPreferencesAsync`) | V1-005 |
| Riverpod provider composition (partial: preferences only) | V1-006 (partial) |
| Welcome dialog first-run-only | UX refinement within V1-012 scope |

V1-002 (Drift database) and V1-003 (profile domain) move to Wave 2 per user's wave descriptions. V1-006 completion (form/calculation controllers) is deferred to Wave 3 because it depends on V1-002/V1-004.

## Scope

- V1-001: add pinned dependencies — `flutter_riverpod`, `shared_preferences` (with `SharedPreferencesAsync` API), `drift`, `sqlite3_flutter_libs`; dev deps `build_runner`, `drift_dev`. Configure codegen command documentation.
- Application layer skeleton under `lib/application/`: abstraction (port) for app preferences; async state with explicit loading/data/error (sealed types).
- Infrastructure under `lib/infrastructure/preferences/`: `SharedPreferencesAsync` implementation; preference keys as named constants in one place.
- Persisted values: welcome-seen flag, comparison mode (standard/custom), custom threshold (decimal as string). Defaults and malformed-value fallback behavior defined and tested.
- Riverpod wiring: `ProviderScope` in `main.dart`; preference repository provider overridable in tests.
- Welcome dialog becomes first-run-only: shown once after load when flag absent/false; dismissing persists the flag.
- Preserve existing behavior: dark mode via `ThemeMode.system`, currency mask, pt-BR validation, V0 widget flows.

## Non-goals

Drift database creation, profile domain/persistence (Wave 2). Form orchestration migration, history, profile UI (Waves 2–4). Manual dark-mode toggle gets its own dedicated wave (user decision, 2026-08-22) — no theme preference key in this wave. No new product behavior beyond the first-run dialog.

## Affected files

- `pubspec.yaml`
- `lib/main.dart`
- `lib/application/preferences/` (port + state + providers)
- `lib/infrastructure/preferences/` (SharedPreferencesAsync implementation)
- `lib/presentation/pages/home_page.dart` (dialog gating; rule enum relocation if needed by port typing)
- `test/infrastructure/preferences_test.dart`
- `test/application/preferences_providers_test.dart`
- `test/presentation/comparison_flow_test.dart` (welcome dialog regression updates)

## Execution record

Implemented via parallel subagents (tests agent ∥ production agent with frozen contract), main-thread wiring (`main.dart`, `home_page.dart`, existing test pump helpers).

- Deps pinned: flutter_riverpod 3.4.2, shared_preferences 2.5.5, drift 2.34.3, sqlite3_flutter_libs 0.6.0+eol, build_runner 2.16.0, drift_dev 2.34.5.
- Riverpod 3.x notes: no `Override` type annotation; `AsyncValue.value` already nullable.
- Platform mocking: tests inject an in-memory `SharedPreferencesAsync` fake via the repo's optional constructor param.

## Acceptance criteria

All criteria met: deps resolve in container; codegen command documented in `docs/development/getting-started.md`; preferences defaults/writes/reads/malformed tested; welcome dialog first-run-only (unit + widget tested); providers overridable; explicit async states. `flutter analyze` clean; full suite 82/82 passing in container.

## Test plan

`docker compose run --rm dev flutter analyze && docker compose run --rm dev flutter test`.

## Versioned Handoff

Wave 1 complete 2026-08-22. Next: Wave 2 = V1-002 (Drift DB, schema v1) ∥ V1-003 (profile domain) / repos+mappers, strict file boundaries. Then Wave 3 = V1-007/V1-009..011 UI + form orchestration migration from `_HomePageState`; Wave 4 = V1-012..014 integration + device validation. Manual dark-mode toggle: own dedicated wave later (user decision). Reviewer subagent currently broken ("Model not found: haiku") — cross-review done inline this wave.
