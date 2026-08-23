# Domain Model

Location: `lib/domain/`. The domain has no dependency on Flutter, Riverpod, Drift, or SharedPreferences.

## Core types

- `FuelType` — `fuel_type.dart`
- `ThresholdSource` and the standard threshold constant — `threshold_source.dart`
- `FuelPrice` — `fuel_price.dart`
- `VehicleEfficiency` — `vehicle_efficiency.dart`
- `FuelCalculationInput` — `fuel_calculation_input.dart`
- `FuelCalculationResult` — `fuel_calculation_result.dart`
- `VehicleProfile` — `vehicle_profile.dart`: single vehicle profile with a trimmed non-empty name and two optional consumption values (each null or greater than zero; both may be absent, unlike `VehicleEfficiency`). Immutable, with null-preserving `copyWith`.
- `CalculationHistoryEntry` — `calculation_history_entry.dart`: immutable snapshot of one calculation (prices, optional consumptions, recommendation, ratio, applied threshold and source, costs per km, maximum ethanol price, difference) plus storage id and UTC creation date.

All numeric fields use `Decimal` (ADR-002). Value objects validate their invariants in constructors: prices and consumption values must be greater than zero; efficiency requires at least one consumption value. `FuelCalculationInput.ratio` is an exact `Rational`; `applyCustomThreshold` decouples cost calculation (always derived from available consumption) from the user's threshold rule choice.

## Core rules

- Prices and consumption values must be greater than zero.
- The ratio determines the recommendation.
- Equality recommends ethanol.
- Missing valid consumption falls back to the standard threshold.
- Results carry the source of the applied rule.
- Rounding occurs only in the presentation layer.
