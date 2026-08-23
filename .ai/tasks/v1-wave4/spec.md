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

---

## Execution record

### V1-012 — UX (commit 6de6bff)

- `home_page.dart`: profile prefill now writes pt-BR comma decimals; `HistorySaveStatus` switch made exhaustive (no wildcard).
- New user requirement, committed bf57793: consumption fields accept **dot or comma** as decimal separator with on-the-fly formatting via new `DecimalInputFormatter` (`lib/presentation/widgets/fuel_input_field.dart`). Normalizes `.` → `,`, keeps a single separator, prefixes `0` for leading separators, strips invalid chars. Applied to home consumption fields and profile form (profile page previously had no formatter). Unit tests in `test/presentation/decimal_input_formatter_test.dart`. Regression: replaced obsolete "negative consumption" widget test (minus now untypeable) with stripping test.

### V1-013 — persistence hardening (commit 8f7c139)

- New `test/infrastructure/database/vehicle_profile_mapper_test.dart`: comma normalization (`12,5`), ambiguous `1,234`, nulls, malformed → typed exception.
- `shared_preferences_app_preferences_test.dart`: `-1` and `0` threshold fallback → null; wrong-typed welcome flag → unseen; fake `getBool` now mimics platform type filtering.
- `app_database_test.dart`: schema v1 pin guard.
- `history_controller_test.dart`: fake entries converted to `isUtc: true`.

### V1-014 — full flow, regression, device validation

- Integration suite `test/integration/full_flow_test.dart` (commit 7f2739c, adjusted 6de6bff): real in-memory Drift through the UI — one entry per valid calculation (2 calculations → 2 entries, newest first), prefill after restart, explicit profile save without blocking calculation.
- Gate after each step: container `flutter analyze` clean; full suite **161/161**.

### CRITICAL bug found by device smoke (commit 15ea7e4)

- `lib/main.dart` wired only the preferences repository. `vehicleProfileRepositoryProvider` and `calculationHistoryRepositoryProvider` defaulted to `UnimplementedError()` in production (only tests overrode them) → history saves and profile persistence failed **only on device**; no `fuelwise.sqlite` created; container tests all green because they override providers. This was invisible to the suite.
- Fix: `main()` composes both Drift repositories over a single `AppDatabase` (`driftDatabase(name: 'fuelwise')`).
- Lesson (recorded for future waves): end-to-end composition-root wiring must be exercised by at least one test that builds the real app without test overrides, or validated on device before claiming a wave complete.

### Device smoke — Moto G35 5G (`ZF525GVCTR`), host ADB, 2026-08-23

Build: `docker compose run --rm dev flutter build apk --debug`; install `adb install -r` (data preserved). Results:

| Check | Result |
|---|---|
| Welcome dialog only on first launch | PASS — never reappeared across cold restarts (flag persisted) |
| Valid calculation → history entry | PASS — "Salvo no histórico."; DB file `app_flutter/fuelwise.sqlite` created |
| History lists snapshot | PASS — date, recommendation, prices, ratio, threshold label, newest first (3 entries across restarts) |
| Delete with confirmation | PASS — dialog "Excluir este registro?" / "Esta ação não pode ser desfeita." / Cancelar preserved entry; Excluir removed it, list refreshed live ("Nenhum cálculo salvo ainda.") |
| Profile save + prefill | PASS — name + "10,5" saved; after cold start consumption field prefilled "10,5" and cost per km computed (R$ 0,60 = 6,29/10,5) |
| Footer | PASS — "v1.0.0 · 22/08/2026 · yanpenalva" rendered |
| Airplane mode (offline end-to-end) | PASS — calculation + history save succeeded with airplane mode on |
| Dark mode follows system | PASS — pixel-verified: light RGB ~(247,251,241) vs dark ~(16,20,15) via `cmd uimode night` |
| Rotation | PASS — landscape 2400x1080, result + history screens render, no RenderFlex overflow in logcat |
| Decimal input (new feature) | PASS — "10,5" typed with comma on device, masked correctly |
| Currency mask | PASS — R\$ 6,29 / R\$ 4,59 entered via digits |

Smoke drove the UI blind via uiautomator bounds + `adb input` (screenshots captured but not readable by the agent model); all assertions verified through UI dumps and pixel sampling.

### Wrap up

- `docs/testing/test-strategy.md` updated (test layers + on-device smoke).
- Wave 4 was executed without a `progress.md` at the user's request to keep flow linear; all state recorded here.
- Remaining open user decisions: manual dark-mode toggle (own wave), MINOR backlog above.

## Versioned Handoff (final)

Wave 4 complete 2026-08-23. All V1 doc tasks V1-012, V1-013, V1-014 met. Next candidate product wave: manual dark-mode toggle persisted via preferences (user decision). Prior to any further on-device work, restart the opencode server so cavecrew reviewer/investigator pick up `opencode/big-pickle` (frontmatter already fixed; server cache is the blocker).
