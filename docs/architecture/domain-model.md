# Domain Model

Location: `lib/domain/`. The domain has no dependency on Flutter, Riverpod, Drift, or SharedPreferences.

## Core types

- `FuelType` — `fuel_type.dart`
- `ThresholdSource` and the standard threshold constant — `threshold_source.dart`
- `FuelPrice` — `fuel_price.dart`
- `VehicleEfficiency` — `vehicle_efficiency.dart`
- `FuelCalculationInput` — `fuel_calculation_input.dart`
- `FuelCalculationResult` — `fuel_calculation_result.dart`
- `VehicleProfile` — NOT FOUND (V1, persistence phase)
- `CalculationHistoryEntry` — NOT FOUND (V1, persistence phase)

All numeric fields use `Decimal` (ADR-002). Value objects validate their invariants in constructors: prices and consumption values must be greater than zero; efficiency requires at least one consumption value.

## Core rules

- Prices and consumption values must be greater than zero.
- The ratio determines the recommendation.
- Equality recommends ethanol.
- Missing valid consumption falls back to the standard threshold.
- Results carry the source of the applied rule.
- Rounding occurs only in the presentation layer.
