import 'package:decimal/decimal.dart';

import 'fuel_type.dart';
import 'threshold_source.dart';

final class CalculationHistoryEntry {
  final int id;
  final DateTime createdAt;
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

  const CalculationHistoryEntry({
    required this.id,
    required this.createdAt,
    required this.gasolinePrice,
    required this.ethanolPrice,
    required this.gasolineConsumption,
    required this.ethanolConsumption,
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
      other is CalculationHistoryEntry &&
      other.id == id &&
      other.createdAt == createdAt &&
      other.gasolinePrice == gasolinePrice &&
      other.ethanolPrice == ethanolPrice &&
      other.gasolineConsumption == gasolineConsumption &&
      other.ethanolConsumption == ethanolConsumption &&
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
    id,
    createdAt,
    gasolinePrice,
    ethanolPrice,
    gasolineConsumption,
    ethanolConsumption,
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
