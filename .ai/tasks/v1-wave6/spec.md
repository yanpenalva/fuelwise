# V1 Wave 6 — History Export, Form Reset, HOST Phase, Polish

## Objective

Add background CSV export of history (single entry or whole month) with system notification; start the home form empty on every launch (no profile prefill); make history month sections collapsed by default; fix the silent profile load-error state; implement and validate the HOST phase (local APK server + Wi-Fi install + offline validation); apply the Dart formatter as an isolated change; refresh `.ai/stack.md` and stale test counts.

## Task mapping / user requests (2026-08-23)

0. Export history (single result or whole month), useful info only, background (non-blocking), system notification when ready.
1. Home consumption fields must start empty on every cold start (currently prefilled "10,5" from profile); only history persists across restarts.
2. History month sections expanded by default → collapsed by default.
3. Implement HOST-001..HOST-005.
4. Fix profile load error state (silent blank form).
5. Dart formatter applied as an isolated commit.
6. Refresh `.ai/stack.md` and old test counts.
7. Revalidate Wi-Fi install and offline flow after the local server is in place.

## Scope

### Export (request 0)

- **Format**: CSV (utf-8, pt-BR `,` decimal? — use dot decimals to keep spreadsheet-safe; decision: dot decimals, `;` separator for pt-BR Excel? — single decision: comma separator + dot decimals? pt-BR Excel expects `;` + `,` decimals. Choose `;` separated, `,` decimals, BOM for Excel). Encoding: utf-8 with BOM.
- **Columns** (useful info only): Data (dd/MM/yyyy HH:mm), Recomendação, Preço gasolina (R$), Preço etanol (R$), Consumo gasolina (km/L), Consumo etanol (km/L), Proporção, Limiar, Fonte do limiar, Custo/km gasolina, Custo/km etanol, Etanol máximo (R$), Diferença (R$). A header comment line includes the current vehicle profile name when loaded (`Veículo: X`) — profile name is not stored per-entry (ADR-006 snapshot has no vehicle name), so it is exported as context, not per-row.
- **Granularity**: export selected single entry, or all entries of one month (per section).
- **Background**: CSV built in an isolate (`compute`) via an infrastructure service; app layer orchestrates via port + controller with sealed state `idle / exporting / ready(file) / failure(message)`.
- **Notification**: on completion, a system notification ("Exportação concluída") via `flutter_local_notifications` (new dep, justified: only maintained plugin for Android notifications; permission `POST_NOTIFICATIONS` requested at runtime, denied → graceful SnackBar fallback); share sheet (`share_plus`, new dep, justified: only lean plugin exposing the system share intent; no storage permission needed) opens with the CSV file so the user saves/sends it.
- UI: history page — month header gets an export icon; each entry tile gets an export icon next to delete.

### Form reset (request 1)

- Remove automatic prefill of consumption fields from `home_page.dart` (the `ref.listen(vehicleProfileProvider)` + `_prefillFromProfile` block). Fields start empty every launch; profile screen keeps working; history persistence unchanged.
- Tests: integration test updated to assert empty fields despite a persisted profile.

### History sections collapsed by default (request 2)

- `_MonthSection`: drop `initiallyExpanded: true` (default collapsed). Update widget tests to expand before asserting entries.

### Profile load error state (request 4)

- `ProfilePage`: when `vehicleProfileProvider` is in `AsyncError`, show an explicit error view with retry (invalidate) instead of the silent blank form; loading unchanged.

### HOST phase (request 3)

- `docker-compose.yml`: new `apk-server` service — nginx serving `build/app/outputs/flutter-apk/` plus a generated download page (name, version `v1.0.0`, build date) on a published local port.
- `docker/nginx/` conf + `docs/hosting/local-apk-server.md` rewrite per HOST-001..HOST-005 (server URL, firewall/Wi-Fi notes, install/update via phone browser, ADB alternative, offline validation checklist).
- Validation on device (request 7): build APK, serve over Wi-Fi, phone downloads + installs via browser, offline scenario passes (airplane mode, calculation, history, restart).

### Tooling/docs (requests 5, 6)

- Isolated commit: `dart format` applied to `lib/` and `test/` (no logic changes).
- `.ai/stack.md`: refresh statuses (V1 complete incl. wave 5/6 features; HOST implemented), remove wave-pending phrasing; sweep current (non-spec) docs for stale test-count claims.

## Non-goals

Export to PDF/XLS; export-all-history (month-level max for now); scheduled exports; cloud anything; release signing (HOST phase keeps debug APK only, per HOST-001 out of scope).

## Affected files

lib: `home_page.dart`, `history_page.dart`, `profile_page.dart`, application export port + controller + state, infrastructure export service (CSV builder × isolate, file writer), notification + share services (infra), main wiring/fakes.
pubspec: `share_plus`, `flutter_local_notifications` pinned.
compose: `apk-server` service; `docker/nginx/`.
tests: export unit (CSV builder), export controller, history page (collapsed + export buttons), home integration (empty fields), profile error state.
docs: `docs/hosting/local-apk-server.md`, `docs/device-testing/android-device-testing.md`, `.ai/stack.md`, wave6 spec.

## Acceptance criteria

- Single-entry and month export produce correct CSV in background; notification appears; share sheet opens.
- Home form empty on every launch; history persists.
- Month sections collapsed by default; export actions present.
- Profile error state explicit with retry.
- `docker compose up apk-server` serves APK + page; phone installs over Wi-Fi; offline scenario passes.
- Formatter commit contains only formatting.
- `flutter analyze` clean; suite green (count recorded).

## Test plan

Unit: CSV builder rows (all fields, pt-BR, header), controller states (idle→exporting→ready/failure), isolate service with sample entries. Widget: history collapsed/expand + export icon presence, profile error+retry, home empty-fields integration. Host: server responds (curl), APK 200; device: Wi-Fi install + offline flow. Gate: container analyze + full test.

## Versioned Handoff (opened)

Depends on wave 5 (complete). New deps flagged for review per conventions (share_plus, flutter_local_notifications). Results appended at Wrap up.