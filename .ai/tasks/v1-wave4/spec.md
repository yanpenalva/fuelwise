# V1 Wave 4 — UX Refinement, Persistence Test Hardening, Full-Flow Validation

## Objective

Close V1: make the complete flow clear and usable on small screens (V1-012), protect persistence behavior with a hardened test suite (V1-013), and validate the full local flow plus V0 regression with deterministic tests and an on-device smoke pass (V1-014).

## Task mapping

| Wave 4 content | Doc task |
|---|---|
| UX small-screen refinement | V1-012 |
| Drift/preferences persistence test hardening | V1-013 |
| Full flow + V0 regression + device validation | V1-014 |

## Scope

### V1-012 — UX refinement

- Review all screens at 320 px width (home form, result, history, profile): no overflow, scrollable everywhere, touch targets adequate.
- Make async states unmistakable: history loading/error/empty already exist; verify result save status text does not clip on narrow screens.
- Standard-fallback indication is explicit in results (`Limiar padrão (0,70)`); keep wording consistent between home hint, result view, and history tile threshold label.
- Accessibility pass: field labels/hints present, error messages actionable, contrast via theme defaults.
- Preserve intentional behaviors: currency mask untouched; dark mode via `ThemeMode.system`; release footer `v1.0.0 · 22/08/2026 · yanpenalva`.

Known review leftovers addressed here as UX polish (from waves 1–3 cross-review, MINOR tier):

- `home_page.dart`: profile prefill writes dot-decimal (`10.5`) while ProfilePage prefills comma (`10,5`) — normalize to pt-BR comma for display consistency (parser accepts both).
- `home_page.dart`: `_ => ''` wildcard in the sealed `HistorySaveStatus` switch replaced with exhaustive cases to keep compiler exhaustiveness checks.

### V1-013 — persistence test hardening

Gaps identified by wave reviews, added under `test/infrastructure/`:

- Comma-normalized decimal storage: store `'12,5'`-style raw text path through mapper boundary (comma normalization covered indirectly today).
- Non-positive stored threshold/values: preferences `-1` custom-threshold fallback case (`parsed <= Decimal.zero` branch untested).
- Malformed welcome flag: wrong-typed stored value behavior pinned by test.
- UTC dates: fake repositories in application tests use non-UTC `DateTime` — fix fakes to `isUtc: true` so a UTC regression cannot slip; add explicit assertion that stored `createdAt` round-trips as the same instant.
- Schema v1: existing schema tests assert table/column shape; extend with an explicit `schemaVersion == 1` guard test.

Non-goal: real migration tests (schema still v1; no migrations exist yet).

### V1-014 — full flow + regression

- Integration suite from wave 3 fixes (`test/integration/full_flow_test.dart`) extended if gaps surface during this wave's review.
- Full V0 regression: existing comparison flow tests must remain green without modification of expectations (mask, pt-BR messages, threshold rules).
- Device smoke validation (host ADB, Moto G35 5G): fresh-install welcome dialog once; valid calculation creates history entry; history list + delete-with-confirmation; profile save/prefill across app restarts; footer label correct; airplane-mode full functionality; dark mode follows system; layout OK rotated and at small sizes. Results recorded in this spec's Execution record / Versioned Handoff.

## Non-goals

Manual dark-mode toggle (own later wave, user decision 2026-08-22). Custom threshold preference feeding the calculator. Schema v2/migrations. Bulk delete/export. New product features or visual redesign beyond V1. HOST/local APK server phase.

## Affected files

- `lib/presentation/pages/home_page.dart` (prefill formatting, exhaustive switch)
- `test/infrastructure/database/*_test.dart` (comma normalization, UTC instant, schema version)
- `test/infrastructure/preferences/*_test.dart` (non-positive threshold, malformed flag)
- `test/application/history_controller_test.dart`, `test/application/*` fakes (UTC datetimes)
- Widget tests for any V1-012 change that alters rendered output
- `docs/testing/test-strategy.md` (persistence/integration coverage notes)
- `.ai/tasks/v1-wave4/spec.md` (this file)

## Acceptance criteria

- All screens usable at 320 px without overflow; prefill format consistent (pt-BR comma) between profile page and home prefill.
- Sealed switch on `HistorySaveStatus` exhaustive (no wildcard).
- Persistence suite covers comma normalization, non-positive values, malformed flag, UTC instants, schema v1 guard.
- Fakes use UTC datetimes.
- Container `flutter analyze` clean; full suite green (baseline 146/146 before wave additions).
- Device smoke checklist passed and recorded.

## Test plan

Per step: affected tests, then gate `docker compose run --rm dev flutter analyze && docker compose run --rm dev flutter test`. Device step per `docs/device-testing/android-device-testing.md` with host ADB.

## Versioned Handoff

Wave 4 opened 2026-08-22 immediately after retroactive cross-review of waves 1–3 (done this session via explore-subagent fallback; cavecrew reviewer/investigator still broken until opencode server restart — frontmatter fix applied but server caches old agent model). Four MAJOR findings fixed and pushed (commits e025370, b118a61, 7f2739c; suite 143→146). MINOR findings either folded into this wave's scope (prefill format, sealed-switch wildcard) or listed below as open user tasks:

- Open MINOR backlog (user decides): drift `dateTime` epoch-seconds representation (reads back local-time DateTime; consider `store_date_time_values_as_text` before schema v2), sqlcipher EOL transitive dep audit, `requireValue` race guards in preferences controller, side-effect-in-build welcome dialog trigger, `rule_mode.dart` placement vs infrastructure mapping rule, profile load-error silent blank form, history controller read-modify-write state races, duplicate car icon semantics, unused-import lint verification.

Next concrete actions: implement V1-012 → V1-013 → V1-014 code steps, then APK build + device smoke, then wrap up.
