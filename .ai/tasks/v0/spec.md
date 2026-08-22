# V0-001..009 — Local Calculation Prototype

## Objective

Implement the complete V0 phase: pure calculation domain, pt-BR input validation, comparison form, result view, and full widget test coverage, without persistence or state-management infrastructure.

## Scope

- App identity (`Fuelwise`, package `br.com.fuelwise.fuelwise`) and `pt_BR` locale.
- Strict analyzer options, Material 3 light theme, pinned dependencies (`decimal`, `rational`, `intl`).
- Pure domain under `lib/domain/`: types, parser with sealed typed failures, calculator with exact `Rational` math.
- Presentation: validated form (comma/period decimals), standard/custom rule selection, `ResultView` with pt-BR formatting and unavailable states.
- End-to-end widget tests including 320px regression.

## Non-goals

Drift, SharedPreferences, Riverpod, history, vehicle profile (V1 scope).

## Execution record

Implemented in four waves with parallel subagents:

- Wave 1: V0-001 remainder + V0-002.
- Wave 2: V0-003 (main thread) → V0-004 ∥ V0-005.
- Wave 3: contract frozen (`ResultView` API) → V0-007 ∥ V0-008.
- Wave 4: V0-009 → review findings fixed → device validation.

Review fixes applied: exact decimal formatting without `double` conversion, guard-clause refactor in calculator, costs decoupled from rule selection via `FuelCalculationInput.applyCustomThreshold`, pinned dependency versions, removed unused `cupertino_icons`, boundary tests added (custom-threshold equality, multi-separator rejection).

## Acceptance criteria

All criteria of `docs/tasks/v0/V0-001..009.md` met; `flutter analyze` clean; full suite passing in container; debug APK installs and runs on a physical device.

## Test plan

`docker compose run --rm dev flutter analyze && flutter test`; on-device smoke via host ADB.

## Versioned Handoff

V0 complete as of 2026-08-22. Next phase: V1 (`docs/tasks/v1/`) — Riverpod state, Drift persistence, preferences, vehicle profile, history. Known deferral: form orchestration lives in widget State until V1 introduces an application layer.
