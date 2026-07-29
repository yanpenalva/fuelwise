# Domain Model

## Core types

- `FuelType`
- `ThresholdSource`
- `FuelPrice`
- `VehicleEfficiency`
- `FuelCalculationInput`
- `FuelCalculationResult`
- `VehicleProfile`
- `CalculationHistoryEntry`

## Core rules

- Prices and consumption values must be greater than zero.
- The ratio determines the recommendation.
- Equality recommends ethanol.
- Missing valid consumption falls back to the standard threshold.
- Results carry the source of the applied rule.
- Rounding occurs only in the presentation layer.
