import 'package:rational/rational.dart';

import 'fuel_price.dart';
import 'vehicle_efficiency.dart';

class FuelCalculationInput {
  final FuelPrice gasolinePrice;
  final FuelPrice ethanolPrice;
  final VehicleEfficiency? efficiency;

  const FuelCalculationInput._(this.gasolinePrice, this.ethanolPrice, this.efficiency);

  factory FuelCalculationInput({
    required FuelPrice gasolinePrice,
    required FuelPrice ethanolPrice,
    VehicleEfficiency? efficiency,
  }) {
    return FuelCalculationInput._(gasolinePrice, ethanolPrice, efficiency);
  }

  Rational get ratio => ethanolPrice.value / gasolinePrice.value;

  @override
  bool operator ==(Object other) =>
      other is FuelCalculationInput &&
      other.gasolinePrice == gasolinePrice &&
      other.ethanolPrice == ethanolPrice &&
      other.efficiency == efficiency;

  @override
  int get hashCode =>
      Object.hash(gasolinePrice, ethanolPrice, efficiency);
}
