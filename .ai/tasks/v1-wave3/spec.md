# V1 Wave 3 — Riverpod Composition Complete, History, Profile UI, Form Orchestration Migration

## Objective

Complete the Riverpod composition (profile, history, form controllers), persist one history entry per valid calculation, deliver history screen with safe deletion and profile screen with explicit save, and migrate form orchestration from `_HomePageState` into the application layer.

## Task mapping

User wave plan "Onda 3" content = docs V1-006 (remainder), V1-007, V1-008 (table existed; wiring here), V1-009, V1-010, V1-011.

## Scope

- Domain: `CalculationHistoryEntry` (complete snapshot, ADR-006).
- Infrastructure: Drift history repository (`record` from input+result, `loadAll` newest-first, `deleteById`), mapper both ways, DB query additions.
- Application: history + profile controllers/providers; `ComparisonFormState` + `ComparisonFormController` owning validation and calculation (form orchestration leaves the widget State).
- Presentation: home page consumes providers (no business rules); HistoryPage (loading/empty/error/list/delete-with-confirmation); ProfilePage (name + consumptions, explicit save only); navigation from AppBar.
- Existing behavior preserved: currency mask, pt-BR messages, dark mode, first-run dialog, 320px layout.

## Frozen contracts

### Domain — lib/domain/calculation_history_entry.dart

```dart
final class CalculationHistoryEntry {
  final int id;                       // assigned by storage; 0 allowed pre-persist
  final DateTime createdAt;           // UTC
  final Decimal gasolinePrice;
  final Decimal ethanolPrice;
  final Decimal? gasolineConsumption;
  final Decimal? ethanolConsumption;
  final FuelType recommendedFuel;
  final Decimal ratio;
  final Decimal appliedThreshold;
  final ThresholdSource thresholdSource;
  final Decimal? gasolineCostPerKilometer;
  final Decimal? ethanolCostPerKilometer;
  final Decimal maximumEthanolPrice;
  final Decimal difference;
  // const ctor all required; == / hashCode all fields
}
```

### Application — ports and providers

```dart
// lib/application/history/calculation_history_repository.dart
abstract interface class CalculationHistoryRepository {
  Future<List<CalculationHistoryEntry>> loadAll(); // newest first
  Future<CalculationHistoryEntry> record({required FuelCalculationInput input, required FuelCalculationResult result});
  Future<void> deleteById(int id);
}

// lib/application/history/history_controller.dart
final calculationHistoryRepositoryProvider = Provider<CalculationHistoryRepository>((_) => throw UnimplementedError());
final historyProvider = AsyncNotifierProvider<HistoryController, List<CalculationHistoryEntry>>(HistoryController.new);
class HistoryController extends AsyncNotifier<List<CalculationHistoryEntry>> {
  build() -> repo.loadAll()
  Future<void> record({input, result})   // persists, prepends to state (newest first)
  Future<void> deleteById(int id)        // deletes, removes from state
}

// lib/application/profile/vehicle_profile_controller.dart
final vehicleProfileRepositoryProvider = Provider<VehicleProfileRepository>((_) => throw UnimplementedError()); // port exists from wave 2
final vehicleProfileProvider = AsyncNotifierProvider<VehicleProfileController, VehicleProfile?>(VehicleProfileController.new);
class VehicleProfileController extends AsyncNotifier<VehicleProfile?> {
  build() -> repo.load()
  Future<void> save(VehicleProfile profile) // persists then updates state
}
```

Errors propagate as typed/generic exceptions; async states surface them explicitly. No snackbars/navigation inside providers.

### Application — form composition

```dart
// lib/application/comparison/comparison_form_state.dart
sealed class HistorySaveStatus { const HistorySaveStatus(); }
final class HistorySaveIdle extends HistorySaveStatus { const HistorySaveIdle(); }
final class HistorySaveSaving extends HistorySaveStatus { const HistorySaveSaving(); }
final class HistorySaveSuccess extends HistorySaveStatus { const HistorySaveSuccess(); }
final class HistorySaveFailure extends HistorySaveStatus { const HistorySaveFailure(this.message); final String message; }

final class ComparisonFormState {
  final bool isSubmitting;
  final String? gasolinePriceError, ethanolPriceError, gasolineConsumptionError, ethanolConsumptionError;
  final FuelCalculationResult? result;
  final HistorySaveStatus historySave;
  static const ComparisonFormState initial();
  copyWith(...);
}

// lib/application/comparison/comparison_form_controller.dart
final comparisonFormProvider = NotifierProvider<ComparisonFormController, ComparisonFormState>(ComparisonFormController.new);
class ComparisonFormController extends Notifier<ComparisonFormState> {
  build() -> initial
  Future<void> submit({required String gasolinePrice, required String ethanolPrice, required String gasolineConsumption, required String ethanolConsumption});
  // parse via domain parser (same rules/messages as today); any failure sets field errors and returns early
  // valid -> result computed by const FuelCalculator() with applyCustomThreshold = prefs.ruleMode == RuleMode.custom
  // then historySave: Saving -> Success | Failure('Não foi possível salvar no histórico.')
  void reset(); // back to initial
}
```

Rule selection stays persisted via existing `AppPreferencesController.selectRule`; custom-threshold preference value is NOT wired into the calculator this wave (current consumption-derived behavior unchanged).

### Infrastructure

`lib/infrastructure/database/drift_calculation_history_repository.dart` implements the port over `AppDatabase`; `lib/infrastructure/database/calculation_history_mapper.dart` maps row ↔ domain (decimals text, comma-normalized parse at boundary, enum names stored as strings). `AppDatabase` gains `getAllHistoryEntries()` (createdAt DESC, id DESC tiebreak) and `deleteHistoryEntry(int id)`. Existing tables unchanged (schema stays v1).

### Presentation

- `home_page.dart`: `ConsumerState`; watches `appPreferencesProvider` (welcome gating + rule segments), `comparisonFormProvider` (errors/result/isSubmitting/historySave listener → SnackBar feedback), `vehicleProfileProvider` (prefill consumption fields ONLY when fields are empty and data arrives). Dispatches `submit`/`reset`/`selectRule`. AppBar actions: profile (edit page), history (list page). Currency mask untouched. Release footer untouched.
- `pages/history_page.dart`: states loading (spinner) / error (message + retry) / empty ('Nenhum cálculo salvo ainda.') / list. Tile: date-time `dd/MM/yyyy HH:mm`, recommendation text, both prices, ratio (2 decimals pt-BR), threshold label. Trailing delete icon → confirmation dialog ('Excluir este registro?' / 'Excluir' / 'Cancelar') → `deleteById`; failure → SnackBar error.
- `pages/profile_page.dart`: name + two optional consumption fields; Save validates via domain constructor (catches ArgumentError → inline error), explicit action only; success SnackBar + pop. Calculation works without profile.

## Non-goals

Custom threshold preference feeding the calculator; schema v2; bulk delete/export; theme toggle (own wave later); V1-012 UX polish beyond stated strings.

## Affected files

New: domain entry; application history/profile/comparison files; infra history repo+mapper; presentation history_page/profile_page. Modified: `app_database.dart`, `home_page.dart`, affected existing presentation tests. Tests: application controller tests, persistence tests, widget tests per screen, integration tests (one-save-per-calculation, profile prefill/restart).

## Acceptance criteria

Each valid calculation creates exactly one history entry (repeated submission guarded by isSubmitting) and UI reflects save outcome; history readable with all async states handled; only confirmed entry deleted, list updates live; profile loads, prefills defaults, saves only explicitly, never blocks calculation; providers overridable; failures explicit. Container `flutter analyze` clean; full suite green.

## Test plan

Unit: controllers with overridden repositories (success/failure/repeat/refresh). Persistence: history round-trip, order, delete, malformed values. Widget: history states + delete flow, profile save/validation, migrated home flow regression incl. 320px. Integration: calculation → exactly one entry. Gate: container analyze + full test.

## Execution record

Four parallel subagents (application controllers ∥ Drift history repo ∥ form controller + home migration ∥ history/profile screens) with frozen contracts; main thread fixed leftovers from two silent agent failures (missing import in home_page.dart; mapper/repository/test alignment).

Fixes applied during integration:
- History mapper rejected non-positive decimals, breaking negative `difference` snapshots — parse now accepts any finite decimal (positivity is a boundary concern for inputs only).
- Success save feedback moved from SnackBar to inline status text under the result button: the SnackBar obscured `Novo cálculo` in tests and on small screens.
- AppBar title Row wrapped with `Flexible` + ellipsis: fixed 16 px horizontal overflow at 320 px introduced by the two new AppBar actions.

## Acceptance criteria

All met: exactly one history entry per valid submission (guarded by isSubmitting, verified by tests incl. failure and repeat paths); save outcome visible (inline status / error SnackBar); history screen handles loading/error/empty/list with confirmed single-entry deletion and live refresh; profile loads, prefills empty consumption fields only, saves explicitly, never blocks calculation; form orchestration fully in `ComparisonFormController`, widget dispatches intents only. Container `flutter analyze` clean; full suite 143/143.

## Versioned Handoff

Wave 3 complete 2026-08-22. Next: Wave 4 = V1-012..014 — UX refinement, persistence test hardening, full-flow device validation via host ADB (Moto G35 5G). Then pending user-requested wave: manual dark-mode toggle persisted via preferences. Subagent note: Big Pickle builders occasionally return empty results — verify artifacts after each run.
