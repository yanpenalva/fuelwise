import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rational/rational.dart';

import 'package:fuelwise/domain/fuel_calculation_input.dart';
import 'package:fuelwise/domain/fuel_price.dart';
import 'package:fuelwise/domain/fuel_type.dart';
import 'package:fuelwise/domain/threshold_source.dart';
import 'package:fuelwise/domain/vehicle_efficiency.dart';

void main() {
  group('FuelPrice', () {
    test('accepts a positive value', () {
      final price = FuelPrice(
        type: FuelType.gasoline,
        value: Decimal.parse('6.19'),
      );

      expect(price.value, Decimal.parse('6.19'));
    });

    test('rejects zero and negative values', () {
      expect(
        () => FuelPrice(type: FuelType.gasoline, value: Decimal.zero),
        throwsArgumentError,
      );
      expect(
        () => FuelPrice(type: FuelType.ethanol, value: Decimal.parse('-1')),
        throwsArgumentError,
      );
    });

    test('supports equality', () {
      final price = FuelPrice(
        type: FuelType.gasoline,
        value: Decimal.parse('6.19'),
      );

      expect(
        price,
        FuelPrice(type: FuelType.gasoline, value: Decimal.parse('6.19')),
      );
      expect(
        price,
        isNot(FuelPrice(type: FuelType.ethanol, value: Decimal.parse('6.19'))),
      );
    });
  });

  group('VehicleEfficiency', () {
    test('accepts partial data with one consumption value', () {
      final efficiency = VehicleEfficiency(
        gasolineKmPerLiter: Decimal.parse('10'),
      );

      expect(efficiency.isComplete, isFalse);
    });

    test('rejects empty data', () {
      expect(
        () => VehicleEfficiency(
          gasolineKmPerLiter: null,
          ethanolKmPerLiter: null,
        ),
        throwsArgumentError,
      );
    });

    test('rejects non-positive values', () {
      expect(
        () => VehicleEfficiency(gasolineKmPerLiter: Decimal.zero),
        throwsArgumentError,
      );
    });
  });

  group('FuelCalculationInput', () {
    test('computes ratio as ethanol price divided by gasoline price', () {
      final input = FuelCalculationInput(
        gasolinePrice: FuelPrice(
          type: FuelType.gasoline,
          value: Decimal.parse('6.00'),
        ),
        ethanolPrice: FuelPrice(
          type: FuelType.ethanol,
          value: Decimal.parse('4.20'),
        ),
      );

      expect(input.ratio, Rational.fromInt(7, 10));
    });

    test('supports equality including efficiency', () {
      final efficiency = VehicleEfficiency(
        gasolineKmPerLiter: Decimal.parse('10'),
        ethanolKmPerLiter: Decimal.parse('7'),
      );
      final gasoline = FuelPrice(
        type: FuelType.gasoline,
        value: Decimal.parse('6'),
      );
      final ethanol = FuelPrice(
        type: FuelType.ethanol,
        value: Decimal.parse('4.2'),
      );
      final input = FuelCalculationInput(
        gasolinePrice: gasoline,
        ethanolPrice: ethanol,
        efficiency: efficiency,
      );

      expect(
        input,
        FuelCalculationInput(
          gasolinePrice: gasoline,
          ethanolPrice: ethanol,
          efficiency: efficiency,
        ),
      );
    });
  });

  group('FuelThreshold', () {
    test('standard threshold is 0.70', () {
      expect(FuelThreshold.standard, Decimal.parse('0.70'));
    });
  });
}
