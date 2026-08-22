import 'package:rational/rational.dart';

import 'fuel_price.dart';
import 'vehicle_efficiency.dart';

class FuelCalculationInput {
  final FuelPrice gasolinePrice;
  final FuelPrice ethanolPrice;
  final VehicleEfficiency? efficiency;
  final bool applyCustomThreshold;

  const FuelCalculationInput({
    required this.gasolinePrice,
    required this.ethanolPrice,
    this.efficiency,
    this.applyCustomThreshold = true,
  });

  Rational get ratio => ethanolPrice.value / gasolinePrice.value;

  @override
  bool operator ==(Object other) =>
      other is FuelCalculationInput &&
      other.gasolinePrice == gasolinePrice &&
      other.ethanolPrice == ethanolPrice &&
      other.efficiency == efficiency &&
      other.applyCustomThreshold == applyCustomThreshold;

  @override
  int get hashCode => Object.hash(
        gasolinePrice,
        ethanolPrice,
        efficiency,
        applyCustomThreshold,
      );
}
