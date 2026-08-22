import 'package:decimal/decimal.dart';

import 'fuel_type.dart';
import 'threshold_source.dart';

class FuelCalculationResult {
  final FuelType recommendedFuel;
  final Decimal ratio;
  final Decimal appliedThreshold;
  final ThresholdSource thresholdSource;
  final Decimal? gasolineCostPerKilometer;
  final Decimal? ethanolCostPerKilometer;
  final Decimal maximumEthanolPrice;
  final Decimal difference;

  const FuelCalculationResult({
    required this.recommendedFuel,
    required this.ratio,
    required this.appliedThreshold,
    required this.thresholdSource,
    required this.gasolineCostPerKilometer,
    required this.ethanolCostPerKilometer,
    required this.maximumEthanolPrice,
    required this.difference,
  });

  @override
  bool operator ==(Object other) =>
      other is FuelCalculationResult &&
      other.recommendedFuel == recommendedFuel &&
      other.ratio == ratio &&
      other.appliedThreshold == appliedThreshold &&
      other.thresholdSource == thresholdSource &&
      other.gasolineCostPerKilometer == gasolineCostPerKilometer &&
      other.ethanolCostPerKilometer == ethanolCostPerKilometer &&
      other.maximumEthanolPrice == maximumEthanolPrice &&
      other.difference == difference;

  @override
  int get hashCode => Object.hash(
        recommendedFuel,
        ratio,
        appliedThreshold,
        thresholdSource,
        gasolineCostPerKilometer,
        ethanolCostPerKilometer,
        maximumEthanolPrice,
        difference,
      );
}
