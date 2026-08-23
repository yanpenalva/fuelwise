# V1 Wave 5 — History Retention, Dark Mode Toggle, Launch Branding, Store Plan

## Objective

Bound stored history so storage stays small (fixed cap + oldest-first eviction, history grouped by month in the UI), ship the user-requested manual dark-mode toggle (persisted, default system), make the branded launch loading legible (minimum display time + motto), and document the app-store publication plan including the retention strategy.

## Task mapping / user requests (2026-08-23)

1. History storage limitation strategy: cap entries, auto-evict oldest (choose auto; documented), group by month with expandable sections.
2. Dark-mode toggle button visible in the app (replaces system-only behavior; resolves wave 4 backlog item).
3. Launch loading: currently only the native splash symbol is perceived — ensure the branded loading with the motto is actually visible on entry.
4. Strategy doc under `docs/` for store publication planning.

## Scope

### History retention (auto-evict, capped)

- `HistoryController`: constant `maxHistoryEntries = 500`. After a successful `record`, if state length exceeds the cap, delete the oldest entries (newest-first list tail) via repository `deleteById` and trim state. Auto-eviction chosen over prompting: offline-first, zero-friction; conservative cap keeps DB tiny (text rows, ~0.5 MB ceiling at 500).
- UI: `history_page.dart` groups entries by month (label like `Agosto de 2026`, own month-name list — no intl locale init), `ExpansionTile` per month (initially expanded, count in header), entry tiles and per-entry delete unchanged. Loading/error/empty states unchanged.

### Dark mode toggle

- New persisted preference `ThemeModePreference { system, light, dark }` under `lib/application/preferences/theme_mode_preference.dart` (mirrors `rule_mode.dart` pattern), preference key `theme_mode` in `PreferenceKeys`, saved/loaded by `SharedPreferencesAppPreferences` (unknown string → system), surfaced through `AppPreferencesData.themeMode` + `AppPreferencesController.selectThemeMode`.
- `FuelwiseApp` becomes a `ConsumerWidget` mapping the preference onto `MaterialApp.themeMode` (system default while loading).
- Home AppBar action: icon button cycling `system → light → dark` with context-aware icon (`brightness_auto` / `light_mode` / `dark_mode`). Keep the 320 px layout green (AppBar already uses Flexible title).
- `FakeAppPreferences` and tests updated; new widget + preferences tests.

### Launch loading visibility

- Loading gate keeps the splash visible for a minimum of 1 s after first frame (`Timer` in `_HomePageState`) in addition to `appPreferencesProvider.isLoading`, so the motto is readable on entry. Timer canceled on dispose. `pumpAndSettle` in existing tests advances the fake clock, so the floor does not break them; `launch_loading_test` extended to pin the minimum-display behavior.

### Documentation

- New `docs/planning/store-publication.md`: readiness checklist (release signing/AAB, dep EOL audit — sqlcipher/sqlite3 EOL, privacy policy, listing assets, API targets), phased plan mapping, and the history retention strategy (cap 500, auto-evict oldest, monthly grouping, rationale). Linked from `docs/README.md` reading order.

## Non-goals

Prompt-before-evict UX; bulk delete/export; schema v2/migrations; automatic month pagination beyond grouping; remote anything.

## Affected files

- `lib/application/history/history_controller.dart`
- `lib/presentation/pages/history_page.dart`
- `lib/application/preferences/theme_mode_preference.dart` (new), `app_preferences.dart`, `app_preferences_data.dart`, `app_preferences_controller.dart`
- `lib/infrastructure/preferences/preference_keys.dart`, `shared_preferences_app_preferences.dart`
- `lib/main.dart`, `lib/presentation/pages/home_page.dart`
- Tests: prefs repo/controller, history controller (cap + eviction), history page (grouping), theme toggle widget, launch loading floor
- `test/helpers/fake_app_preferences.dart`
- Docs: `docs/planning/store-publication.md` (new), `docs/README.md`

## Acceptance criteria

- Record beyond 500 evicts oldest (state + repository), newest kept.
- History page groups by month, expandable, keep per-entry delete + confirmation.
- Theme toggle cycles and persists across restarts; default system until touched; 320 px flows stay green.
- Launch shows motto loading for ≥ 1 s on cold start.
- Store publication doc exists, agnostic, and includes the retention strategy.
- Container `flutter analyze` clean; full suite green.

## Test plan

Unit: controller eviction with fake repo (501+ seeds → cap kept, evicted ids). Preferences: theme mode round-trip + unknown fallback. Widget: theme toggle icon cycle + persistence via fake; loading floor (still loading at <1 s after prefs resolve); history grouping renders month headers and entries. Gate: `docker compose run --rm dev flutter analyze && docker compose run --rm dev flutter test`.

## Versioned Handoff (opened)

Wave 4 complete; this wave resolves its single backlog item (dark-mode toggle). Cavecrew reviewer/investigator still require an opencode server restart (operational note, not backlog). Commands/results will be appended here at Wrap up.

---

## Execution record

Implemented 2026-08-23, gate after each step: container `flutter analyze` clean, full suite 170/170.

### History retention (commit e72d56f)

- `HistoryController.maxHistoryEntries = 500`; `record()` evicts oldest beyond the cap in the same flow (state + repository).
- `history_page.dart`: entries grouped by month in expandable `ExpansionTile` sections (`Agosto de 2026`, entry count subtitle); first/latest month expanded by default; per-entry delete + confirmation preserved.
- Tests: eviction-at-cap (state length, newest kept, oldest deleted), grouping widget test (month headers, counts, collapse hides entries).

### Dark mode toggle — resolves wave 4 backlog (commit afb6f78)

- New `ThemeModePreference { system, light, dark }` + `themeModePreferenceFromName`, preference key `theme_mode`, round-trip + unknown-string fallback tested.
- `FuelwiseApp` maps the preference onto `MaterialApp.themeMode` (default system).
- Home AppBar action cycles system → light → dark with context icons (`brightness_auto` / `light_mode` / `dark_mode`); persists via `AppPreferencesController.selectThemeMode`.
- Tests: preference round-trip/fallback, controller persistence, widget cycle + persisted-start, 320 px house flow still green.

### Launch loading visibility (commit afb6f78)

- Cold start keeps the branded splash (motto "Combustível certo, custo consciente." + spinner) for a minimum of 1 s (`_splashTimer` in `_HomePageState`, canceled on dispose) in addition to the preferences-loading gate.
- Tests: `launch_loading_test` pins still-loading at 600 ms after data resolves, form after 1 s; welcome-dialog test updated to assert splash during loading.

### Documentation (commit after e72d56f/afb6f78)

- `docs/planning/store-publication.md` — readiness gates (release AAB/signing, dependency EOL audit, release smoke, privacy policy, listing assets, targets), phased plan (HOST → pre-release → submission → post-launch), and the history retention strategy with storage estimate.
- `docs/README.md` — added to reading order.
- This spec now closed; next product wave candidates: HOST phase tasks, store pre-release tasks per `store-publication.md`.

## Versioned Handoff (final)

Wave 5 complete 2026-08-23. Backlog empty; remaining work is the HOST phase and store pre-release (see `docs/planning/store-publication.md`). Device validation of this wave performed by user after APK rebuild; cavecrew operational note unchanged (restart opencode server).