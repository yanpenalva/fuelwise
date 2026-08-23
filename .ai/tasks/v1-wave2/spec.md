# V1 Wave 2 — Drift Schema v1, Profile Domain, Profile Persistence, Release Identifier

## Objective

Create the initial Drift database (schema version 1, profile + history tables), the pure `VehicleProfile` domain type, the profile repository with mappers (persist across restarts), and add the release identifier (version · date · developer) to the UI.

## Task mapping

User wave plan "V1-004..007" by content = docs V1-002 (Drift DB) ∥ V1-003 (profile domain) → V1-004 (profile persistence). Release identifier is an explicit user request outside `docs/tasks/v1/` — recorded here as a spec addition.

## Scope

- V1-002: `lib/infrastructure/database/` — Drift database, schema v1, decimals as text, dates UTC, typed queries for profile (+ insert-ready history table), in-memory schema/query tests. Codegen via documented build_runner command.
- V1-003: `lib/domain/vehicle_profile.dart` — name + optional consumption values, validation, update semantics via immutable copyWith; unit tests incl. boundary cases.
- V1-004: application port `VehicleProfileRepository` + Drift implementation + explicit mapper both ways; empty-state representation; in-memory DB tests (empty/create/read/update).
- User request: release line `vX.Y.Z · dd/mm/aaaa` plus developer name `yanpenalva` visible in home UI.

## Frozen contracts

### VehicleProfile (domain)

```dart
final class VehicleProfile {
  final String name; // trimmed non-empty, ArgumentError otherwise
  final Decimal? gasolineKmPerLiter; // null or > 0
  final Decimal? ethanolKmPerLiter;  // null or > 0
  const VehicleProfile({required this.name, this.gasolineKmPerLiter, this.ethanolKmPerLiter});
  bool get hasConsumption;
  VehicleProfile copyWith({String? name, Decimal? gasolineKmPerLiter, Decimal? ethanolKmPerLiter, bool setGasoline = false, bool setEthanol = false});
}
```

Both consumptions may be null simultaneously (unlike `VehicleEfficiency`). Equality/hashCode on all fields.

### Database schema v1

`vehicle_profiles`: `id INTEGER PK AUTOINCREMENT`, `name TEXT NOT NULL`, `gasoline_km_per_liter TEXT NULL`, `ethanol_km_per_liter TEXT NULL`, `updated_at DATETIME NOT NULL` (UTC).

`history_entries` (table only this wave): `id INTEGER PK AUTOINCREMENT`, `created_at DATETIME NOT NULL` (UTC), `gasoline_price TEXT NOT NULL`, `ethanol_price TEXT NOT NULL`, `gasoline_consumption TEXT NULL`, `ethanol_consumption TEXT NULL`, `recommended_fuel TEXT NOT NULL`, `ratio TEXT NOT NULL`, `applied_threshold TEXT NOT NULL`, `threshold_source TEXT NOT NULL`, `gasoline_cost_per_km TEXT NULL`, `ethanol_cost_per_km TEXT NULL`, `maximum_ethanol_price TEXT NOT NULL`, `difference TEXT NOT NULL`.

### Profile persistence

```dart
abstract interface class VehicleProfileRepository {
  Future<VehicleProfile?> load();          // null = empty state
  Future<VehicleProfile> save(VehicleProfile profile); // create or update single row, returns stored value with updated_at refreshed
}
```

Impl: `lib/infrastructure/database/drift_vehicle_profile_repository.dart`; mapper: `lib/infrastructure/database/vehicle_profile_mapper.dart`. Decimals via `.toString()` / `Decimal.tryParse` with non-positive rejection at boundary.

### Release info

`lib/presentation/release/app_release.dart`: `abstract final class AppRelease { static const String version = '1.0.0'; static const String date = '22/08/2026'; static const String developer = 'yanpalva'→'yanpenalva'; }` + formatted label `v1.0.0 · 22/08/2026 · yanpenalva`. Rendered as discreet footer text at the bottom of the home form. Constant kept in sync with `pubspec.yaml` manually (no new dependency).

## Non-goals

History domain type, history mapper/repository, history UI (Waves 3–4). Riverpod providers for profile (Wave 3). Migrations beyond v1. package_info_plus dependency.

## Affected files

- `lib/infrastructure/database/` (database, tables, generated parts, repository, mapper)
- `lib/domain/vehicle_profile.dart`
- `lib/application/profile/vehicle_profile_repository.dart`
- `lib/presentation/release/app_release.dart`, `lib/presentation/pages/home_page.dart` (footer only)
- Tests: `test/domain/vehicle_profile_test.dart`, `test/infrastructure/database/*_test.dart`, `test/presentation/release_info_test.dart`

## Acceptance criteria

- Database opens in memory and on device path; typed queries work; codegen reproducible without manual edits.
- Profile survives save/load round-trip preserving decimal precision (text storage).
- Empty state represented as `null` load result; create then update keeps a single row.
- Malformed/non-positive decimal in DB rejected explicitly at boundary.
- Release identifier visible in home form footer; tested.
- Domain stays pure; application does not import infrastructure.

## Test plan

In-memory Drift tests (schema, profile CRUD, malformed values); domain unit tests; widget test for footer. Gate: container `flutter analyze` + full `flutter test`.

## Execution record

Parallel subagents: release UI ∥ profile domain ∥ Drift database, then repository/mapper agent (first attempt returned empty; retry succeeded). Layer discipline verified via import audit: no violations. Reviewer/investigator subagents still resolve stale `haiku` model this session (config fixed to `opencode/big-pickle`, effective next session) — review done inline.

- Added dep `drift_flutter 0.3.1` for device-local executor (`fuelwise.sqlite` in private app storage); test executor injection kept.
- `AppDatabase([QueryExecutor?])`; schema v1; codegen reproducible.
- Mapper validates stored decimals at boundary (comma normalization, non-positive/malformed → `VehicleProfileStorageException`).

## Acceptance criteria

All met: DB opens in memory + device path with typed queries; profile round-trip preserves decimal precision (text storage); empty state = null load; single-row create-then-update; malformed values rejected explicitly; release line `v1.0.0 · 22/08/2026 · yanpenalva` visible and tested at 320px; domain pure; application free of infrastructure imports. Container `flutter analyze` clean, full suite 116/116.

## Versioned Handoff

Wave 2 complete 2026-08-22. Next: Wave 3 = V1-007/V1-009..011 — freeze provider contract FIRST, then vehicle profile UI ∥ history UI in parallel; migrate form orchestration from `_HomePageState` to application controllers. History table exists but has no domain type/mapper yet. Manual dark-mode toggle wave still pending. Subagent config fix (`opencode/big-pickle`) takes effect next session — use investigator/reviewer then.
