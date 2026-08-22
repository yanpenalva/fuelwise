import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fuelwise/domain/fuel_calculation_result.dart';
import 'package:fuelwise/domain/fuel_type.dart';
import 'package:fuelwise/domain/threshold_source.dart';
import 'package:fuelwise/presentation/widgets/result_view.dart';

final Decimal _ratio = Decimal.parse('0.700');
final Decimal _appliedThreshold = Decimal.parse('0.700');
final Decimal _maximumEthanolPrice = Decimal.parse('4.50');

FuelCalculationResult _result({
  FuelType recommendedFuel = FuelType.ethanol,
  Decimal? ratio,
  Decimal? appliedThreshold,
  ThresholdSource thresholdSource = ThresholdSource.standard,
  Decimal? gasolineCostPerKilometer,
  Decimal? ethanolCostPerKilometer,
  Decimal? maximumEthanolPrice,
  Decimal? difference,
}) {
  return FuelCalculationResult(
    recommendedFuel: recommendedFuel,
    ratio: ratio ?? _ratio,
    appliedThreshold: appliedThreshold ?? _appliedThreshold,
    thresholdSource: thresholdSource,
    gasolineCostPerKilometer: gasolineCostPerKilometer,
    ethanolCostPerKilometer: ethanolCostPerKilometer,
    maximumEthanolPrice: maximumEthanolPrice ?? _maximumEthanolPrice,
    difference: difference ?? Decimal.zero,
  );
}

Future<void> _pumpResultView(WidgetTester tester, FuelCalculationResult result) {
  return tester.pumpWidget(
    MaterialApp(home: Scaffold(body: ResultView(result: result))),
  );
}

void main() {
  testWidgets(
    'renders ethanol recommendation when recommended fuel is ethanol',
    (WidgetTester tester) async {
      await _pumpResultView(tester, _result());

      expect(find.text('Abasteça com etanol'), findsOneWidget);
    },
  );

  testWidgets(
    'renders gasoline recommendation when recommended fuel is gasoline',
    (WidgetTester tester) async {
      await _pumpResultView(
        tester,
        _result(recommendedFuel: FuelType.gasoline),
      );

      expect(find.text('Abasteça com gasolina'), findsOneWidget);
    },
  );

  testWidgets(
    'shows standard threshold source label when source is standard',
    (WidgetTester tester) async {
      await _pumpResultView(tester, _result());

      expect(find.text('Limiar padrão (0,70)'), findsOneWidget);
    },
  );

  testWidgets(
    'shows custom threshold source label with custom threshold value',
    (WidgetTester tester) async {
      await _pumpResultView(
        tester,
        _result(
          appliedThreshold: Decimal.parse('0.750'),
          thresholdSource: ThresholdSource.custom,
        ),
      );

      expect(find.text('Limiar personalizado (consumo)'), findsOneWidget);
      expect(find.text('0,750'), findsOneWidget);
    },
  );

  testWidgets(
    'shows unavailable state for null cost per kilometer values',
    (WidgetTester tester) async {
      await _pumpResultView(tester, _result());

      expect(
        find.text('Indisponível — informe os dois consumos'),
        findsNWidgets(2),
      );
    },
  );

  testWidgets(
    'formats ratio with comma decimal separator',
    (WidgetTester tester) async {
      await _pumpResultView(tester, _result(ratio: Decimal.parse('0.680')));

      expect(find.text('0,680'), findsOneWidget);
    },
  );

  testWidgets(
    'shows the max-price insight sentence',
    (WidgetTester tester) async {
      await _pumpResultView(
        tester,
        _result(maximumEthanolPrice: Decimal.parse('4.50')),
      );

      expect(
        find.textContaining('o etanol compensa até R\$ 4,50 por litro'),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'shows cost per kilometer values when consumption data is complete',
    (WidgetTester tester) async {
      await _pumpResultView(
        tester,
        _result(
          gasolineCostPerKilometer: Decimal.parse('0.45'),
          ethanolCostPerKilometer: Decimal.parse('0.375'),
        ),
      );

      expect(find.text('R\$ 0,45'), findsOneWidget);
      expect(find.text('R\$ 0,38'), findsOneWidget);
      expect(
        find.text('Indisponível — informe os dois consumos'),
        findsNothing,
      );
    },
  );
}
