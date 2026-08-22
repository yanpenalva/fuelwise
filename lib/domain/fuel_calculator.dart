import 'package:decimal/decimal.dart';
import 'package:rational/rational.dart';

import 'fuel_calculation_input.dart';
import 'fuel_calculation_result.dart';
import 'fuel_type.dart';
import 'threshold_source.dart';
import 'vehicle_efficiency.dart';

class FuelCalculator {
  static const int _infinitePrecisionScale = 12;

  const FuelCalculator();

  FuelCalculationResult calculate(FuelCalculationInput input) {
    final Rational ratio = input.ratio;
    final VehicleEfficiency? efficiency = input.efficiency;

    Rational activeThreshold = FuelThreshold.standard.toRational();
    ThresholdSource thresholdSource = ThresholdSource.standard;
    if (input.applyCustomThreshold &&
        efficiency != null &&
        efficiency.isComplete) {
      activeThreshold =
          efficiency.ethanolKmPerLiter!.toRational() /
          efficiency.gasolineKmPerLiter!.toRational();
      thresholdSource = ThresholdSource.custom;
    }

    final Decimal ratioDecimal = _toDecimal(ratio);
    final Decimal appliedThreshold = _toDecimal(activeThreshold);

    FuelType recommendedFuel = FuelType.gasoline;
    if (ratio <= activeThreshold) {
      recommendedFuel = FuelType.ethanol;
    }

    final Decimal? gasolineCostPerKilometer = _costPerKilometer(
      input.gasolinePrice.value,
      efficiency?.gasolineKmPerLiter,
    );
    final Decimal? ethanolCostPerKilometer = _costPerKilometer(
      input.ethanolPrice.value,
      efficiency?.ethanolKmPerLiter,
    );

    final Decimal maximumEthanolPrice =
        input.gasolinePrice.value * appliedThreshold;

    final Decimal difference = ratioDecimal - appliedThreshold;

    return FuelCalculationResult(
      recommendedFuel: recommendedFuel,
      ratio: ratioDecimal,
      appliedThreshold: appliedThreshold,
      thresholdSource: thresholdSource,
      gasolineCostPerKilometer: gasolineCostPerKilometer,
      ethanolCostPerKilometer: ethanolCostPerKilometer,
      maximumEthanolPrice: maximumEthanolPrice,
      difference: difference,
    );
  }

  Decimal? _costPerKilometer(Decimal price, Decimal? consumption) {
    if (consumption == null) {
      return null;
    }

    return _toDecimal(price.toRational() / consumption.toRational());
  }

  Decimal _toDecimal(Rational value) {
    if (value.hasFinitePrecision) {
      return value.toDecimal();
    }

    return value.toDecimal(scaleOnInfinitePrecision: _infinitePrecisionScale);
  }
}
