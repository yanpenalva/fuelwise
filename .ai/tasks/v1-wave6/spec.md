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

---

## Execution record

Implemented 2026-08-23; gate after each step: container `flutter analyze` clean, full suite **179/179**.

### Export (commit 5fb6594)

- `HistoryExportService` port + `HistoryExportController` (sealed `idle/exporting/ready/failure`, exportId-guarded listener).
- `csv_history_exporter.dart` builds the CSV (useful info only: date, recommendation, prices, consumptions, ratio, threshold+source, costs/km, max ethanol price, difference; `;`-separated, pt-BR comma decimals, vehicle context line) as a pure function run through `compute` in `DartHistoryExportService` (isolate — UI never blocks); file written to a temp dir with BOM.
- Delivery: `SystemExportNotifier` (flutter_local_notifications; channel `fuelwise_export`, `POST_NOTIFICATIONS` runtime-requested) + share sheet (`share_plus`) with the CSV — verified on device: system notification posted **and** Android share sheet opened (WhatsApp/Gmail/Telegram listed).
- UI: month header and each entry get export actions; month sections **collapsed by default** (request 2). Deps pinned 13.3.0 / 22.3.0; core library desugaring enabled in gradle (plugin requirement).
- Tests: CSV builder (header/columns, vehicle line, pt-BR decimals, empty optionals), controller states, history page icons + collapse/expand.

### Form reset (request 1, commit c4750ec)

- Home no longer prefills consumption from the profile (`ref.listen` + `_prefillFromProfile` removed). Fields start empty on every cold start; history persistence unchanged. Verified on device after restart: consumption fields empty; integration test now asserts empty fields despite a persisted profile.

### Profile load error state (request 4, commit c4750ec)

- `ProfilePage`: explicit error view + "Tentar novamente" (invalidate) when the provider is in `AsyncError`; tested with a flaky repository (error → retry → form).

### HOST phase (commits 9b53289 + TLS follow-up)

- `apk-server` compose service: nginx serving the download page (`docker/nginx/index.html`) and the APK dir at `/apk/`; HTTP `:8080` redirects to HTTPS `:8443` with a self-signed cert (Chrome blocks plain-HTTP APK downloads on modern Android — page + download must be HTTPS for the phone browser flow).
- Docs: `docs/hosting/local-apk-server.md` rewritten per HOST-001..HOST-005 (artifact, server, phone-browser install/update, ADB alternative, offline checklist).

### Device validation (requests 3/7; Moto G35 5G same Wi-Fi as host)

- Page served over LAN from the phone browser; APK (220 MB) **downloaded over Wi-Fi** from the server.
- Install caveats found on this device (not product bugs, recorded for the environment): the Itaú app hijacks `application/vnd.android.package-archive` VIEW intents; Android 15 `InstallStart` accepts `content://` grants (raw `file://` from shell is not resolved) and LMK kills the installer under memory pressure; sdcard file access from the shell install path denied (fuse) → install completed via `cmd package install` from `/data/local/tmp` after `am kill-all` freed RAM. Itaú was temporarily `pm disable-user`'d and re-`enable`d; handler table already preferred the system installer.
- **HOST-005 offline scenario — all PASS with airplane mode on**: calculation + save; history grouped/collapsed by month; export of the month → system notification ("Exportação concluída") + share sheet with a correct CSV (spot-checked on disk: header, vehicle line, 6,29/4,59 pt-BR rows); confirmed deletion keeps the list updated; cold restart preserves history (5 entries) while the form starts empty; notification permission prompt appears on first export and works.

### Tooling/docs (requests 5, 6)

- Isolated commits `style(dart)` (5164c39, 604b8d3): formatter applied with zero logic changes.
- `.ai/stack.md` refreshed (full V1 status, export deps, `apk-server` service, canonical commands) + stale test-count references swept from current docs.

## Versioned Handoff (final)

Wave 6 complete 2026-08-23. Wrap-up docs committed with this record. Remaining product backlog: none (dark-mode toggle done in wave 5). Next candidates from `docs/planning/store-publication.md`: HOST leftovers are done; pre-release tasks (release signing, EOL dep audit — sqlite3/ sqlcipher EOL, privacy policy, listing assets). Cavecrew reviewer/investigator still need an opencode server restart to pick up `opencode/big-pickle`.