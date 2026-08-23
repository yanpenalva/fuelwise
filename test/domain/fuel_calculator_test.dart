import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fuelwise/domain/fuel_calculator.dart';
import 'package:fuelwise/domain/fuel_calculation_input.dart';
import 'package:fuelwise/domain/fuel_price.dart';
import 'package:fuelwise/domain/fuel_type.dart';
import 'package:fuelwise/domain/threshold_source.dart';
import 'package:fuelwise/domain/vehicle_efficiency.dart';

void main() {
  const calculator = FuelCalculator();

  FuelCalculationInput buildInput({
    required String gasolinePrice,
    required String ethanolPrice,
    VehicleEfficiency? efficiency,
    bool applyCustomThreshold = true,
  }) {
    return FuelCalculationInput(
      gasolinePrice: FuelPrice(
        type: FuelType.gasoline,
        value: Decimal.parse(gasolinePrice),
      ),
      ethanolPrice: FuelPrice(
        type: FuelType.ethanol,
        value: Decimal.parse(ethanolPrice),
      ),
      efficiency: efficiency,
      applyCustomThreshold: applyCustomThreshold,
    );
  }

  group('FuelCalculator', () {
    test('recommends ethanol when ratio is below standard threshold', () {
      final result = calculator.calculate(
        buildInput(gasolinePrice: '6.00', ethanolPrice: '3.90'),
      );

      expect(result.recommendedFuel, FuelType.ethanol);
      expect(result.thresholdSource, ThresholdSource.standard);
      expect(result.appliedThreshold, Decimal.parse('0.70'));
    });

    test('recommends gasoline when ratio is above standard threshold', () {
      final result = calculator.calculate(
        buildInput(gasolinePrice: '6.00', ethanolPrice: '4.80'),
      );

      expect(result.recommendedFuel, FuelType.gasoline);
      expect(result.thresholdSource, ThresholdSource.standard);
    });

    test('recommends ethanol when ratio equals standard threshold exactly', () {
      final result = calculator.calculate(
        buildInput(gasolinePrice: '6.00', ethanolPrice: '4.20'),
      );

      expect(result.ratio, Decimal.parse('0.70'));
      expect(result.recommendedFuel, FuelType.ethanol);
    });

    group('custom threshold', () {
      test('uses consumption ratio as threshold when data is complete', () {
        final efficiency = VehicleEfficiency(
          gasolineKmPerLiter: Decimal.parse('10'),
          ethanolKmPerLiter: Decimal.parse('7'),
        );
        final result = calculator.calculate(
          buildInput(
            gasolinePrice: '6.00',
            ethanolPrice: '4.20',
            efficiency: efficiency,
          ),
        );

        expect(result.appliedThreshold, Decimal.parse('0.70'));
        expect(result.thresholdSource, ThresholdSource.custom);
      });

      test('recommends ethanol above standard when below custom threshold', () {
        final efficiency = VehicleEfficiency(
          gasolineKmPerLiter: Decimal.parse('10'),
          ethanolKmPerLiter: Decimal.parse('9'),
        );
        final result = calculator.calculate(
          buildInput(
            gasolinePrice: '6.00',
            ethanolPrice: '4.50',
            efficiency: efficiency,
          ),
        );

        expect(result.appliedThreshold, Decimal.parse('0.90'));
        expect(result.thresholdSource, ThresholdSource.custom);
        expect(result.recommendedFuel, FuelType.ethanol);
      });

      test('recommends ethanol when ratio equals custom threshold exactly', () {
        final efficiency = VehicleEfficiency(
          gasolineKmPerLiter: Decimal.parse('10'),
          ethanolKmPerLiter: Decimal.parse('7'),
        );
        final result = calculator.calculate(
          buildInput(
            gasolinePrice: '10.00',
            ethanolPrice: '7.00',
            efficiency: efficiency,
          ),
        );

        expect(result.appliedThreshold, Decimal.parse('0.70'));
        expect(result.thresholdSource, ThresholdSource.custom);
        expect(result.recommendedFuel, FuelType.ethanol);
      });

      test(
        'keeps standard threshold with complete consumption when custom rule '
        'is not applied but still reports costs',
        () {
          final efficiency = VehicleEfficiency(
            gasolineKmPerLiter: Decimal.parse('10'),
            ethanolKmPerLiter: Decimal.parse('9'),
          );
          final result = calculator.calculate(
            buildInput(
              gasolinePrice: '6.00',
              ethanolPrice: '4.50',
              efficiency: efficiency,
              applyCustomThreshold: false,
            ),
          );

          expect(result.thresholdSource, ThresholdSource.standard);
          expect(result.gasolineCostPerKilometer, isNotNull);
          expect(result.ethanolCostPerKilometer, isNotNull);
        },
      );
    });

    test('falls back to standard threshold with partial consumption', () {
      final efficiency = VehicleEfficiency(
        ethanolKmPerLiter: Decimal.parse('7'),
      );
      final result = calculator.calculate(
        buildInput(
          gasolinePrice: '6.00',
          ethanolPrice: '4.80',
          efficiency: efficiency,
        ),
      );

      expect(result.appliedThreshold, Decimal.parse('0.70'));
      expect(result.thresholdSource, ThresholdSource.standard);
      expect(result.recommendedFuel, FuelType.gasoline);
    });

    test('cost per kilometer is null for fuel without consumption', () {
      final efficiency = VehicleEfficiency(
        gasolineKmPerLiter: Decimal.parse('10'),
      );
      final result = calculator.calculate(
        buildInput(
          gasolinePrice: '6.00',
          ethanolPrice: '4.20',
          efficiency: efficiency,
        ),
      );

      expect(result.gasolineCostPerKilometer, Decimal.parse('0.60'));
      expect(result.ethanolCostPerKilometer, isNull);
    });

    test('maximum ethanol price is gasoline price times applied threshold', () {
      final result = calculator.calculate(
        buildInput(gasolinePrice: '6.00', ethanolPrice: '4.20'),
      );

      expect(result.maximumEthanolPrice, Decimal.parse('4.20'));

      final efficiency = VehicleEfficiency(
        gasolineKmPerLiter: Decimal.parse('10'),
        ethanolKmPerLiter: Decimal.parse('8'),
      );
      final customResult = calculator.calculate(
        buildInput(
          gasolinePrice: '5.50',
          ethanolPrice: '4.00',
          efficiency: efficiency,
        ),
      );

      expect(customResult.maximumEthanolPrice, Decimal.parse('4.40'));
    });

    test('difference changes sign around the threshold', () {
      final below = calculator.calculate(
        buildInput(gasolinePrice: '6.00', ethanolPrice: '3.90'),
      );
      final above = calculator.calculate(
        buildInput(gasolinePrice: '6.00', ethanolPrice: '4.80'),
      );

      expect(below.difference, lessThan(Decimal.zero));
      expect(below.difference, Decimal.parse('-0.05'));
      expect(above.difference, greaterThan(Decimal.zero));
      expect(above.difference, Decimal.parse('0.10'));
    });

    test('preserves decimal precision that breaks with double', () {
      final result = calculator.calculate(
        buildInput(gasolinePrice: '6.30', ethanolPrice: '4.41'),
      );

      expect(result.ratio, Decimal.parse('0.70'));
      expect(result.recommendedFuel, FuelType.ethanol);
      expect(result.difference, Decimal.zero);
    });

    test('handles repeating decimal ratio without throwing', () {
      final result = calculator.calculate(
        buildInput(gasolinePrice: '3.00', ethanolPrice: '1.00'),
      );

      expect(result.ratio, Decimal.parse('0.333333333333'));
      expect(result.recommendedFuel, FuelType.ethanol);
    });
  });
}
