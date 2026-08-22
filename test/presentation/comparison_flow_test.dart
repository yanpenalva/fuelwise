import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fuelwise/domain/fuel_input_parser.dart';
import 'package:fuelwise/main.dart';
import 'package:fuelwise/presentation/widgets/fuel_input_field.dart';
import 'package:fuelwise/presentation/widgets/result_view.dart';

const String _gasolinePriceLabel = 'Preço da gasolina';
const String _ethanolPriceLabel = 'Preço do etanol';
const String _gasolineConsumptionLabel = 'Consumo de gasolina';
const String _ethanolConsumptionLabel = 'Consumo de etanol';
const String _submitButton = 'Calcular';
const String _newCalculationButton = 'Novo cálculo';
const String _standardRuleSegment = 'Padrão (0,70)';
const String _customRuleSegment = 'Personalizada';

Future<void> _pumpApp(WidgetTester tester) async {
  await tester.pumpWidget(const FuelwiseApp());
  await tester.pump();

  if (find.byType(AlertDialog).evaluate().isNotEmpty) {
    await tester.tap(find.text('Entendi'));
    await tester.pump();
  }
}

Future<void> _enterPrice(
  WidgetTester tester,
  String label,
  String value,
) async {
  await tester.enterText(find.widgetWithText(FuelInputField, label), value);
}

Future<void> _submit(WidgetTester tester) async {
  await tester.ensureVisible(find.text(_submitButton));
  await tester.pump();
  await tester.tap(find.text(_submitButton), warnIfMissed: false);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 600));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'recommends ethanol with standard threshold on happy path submission',
    (WidgetTester tester) async {
      await _pumpApp(tester);

      await _enterPrice(tester, _gasolinePriceLabel, '6,00');
      await _enterPrice(tester, _ethanolPriceLabel, '4,19');
      await _submit(tester);

      expect(find.byType(ResultView), findsOneWidget);
      expect(find.text('Abasteça com etanol'), findsOneWidget);
      expect(find.text('Limiar padrão (0,70)'), findsOneWidget);
    },
  );

  testWidgets(
    'recommends ethanol with custom consumption threshold above standard limit',
    (WidgetTester tester) async {
      await _pumpApp(tester);

      await _enterPrice(tester, _gasolinePriceLabel, '6,00');
      await _enterPrice(tester, _ethanolPriceLabel, '4,50');
      await tester.tap(find.text(_customRuleSegment));
      await tester.pump();
      await _enterPrice(tester, _gasolineConsumptionLabel, '10');
      await _enterPrice(tester, _ethanolConsumptionLabel, '8');
      await _submit(tester);

      expect(find.byType(ResultView), findsOneWidget);
      expect(find.text('Abasteça com etanol'), findsOneWidget);
      expect(find.text('Limiar personalizado (consumo)'), findsOneWidget);
      expect(find.text('Limiar padrão (0,70)'), findsNothing);
    },
  );

  testWidgets(
    'falls back to standard threshold when only gasoline consumption is filled',
    (WidgetTester tester) async {
      await _pumpApp(tester);

      await _enterPrice(tester, _gasolinePriceLabel, '6,00');
      await _enterPrice(tester, _ethanolPriceLabel, '4,19');
      await tester.tap(find.text(_customRuleSegment));
      await tester.pump();
      await _enterPrice(tester, _gasolineConsumptionLabel, '10');
      await _submit(tester);

      expect(find.byType(ResultView), findsOneWidget);
      expect(find.text('Limiar padrão (0,70)'), findsOneWidget);
      expect(find.text('Limiar personalizado (consumo)'), findsNothing);
    },
  );

  testWidgets(
    'shows required error and keeps form when submitting empty prices',
    (WidgetTester tester) async {
      await _pumpApp(tester);

      await tester.tap(find.text(_submitButton), warnIfMissed: false);
      await tester.pump();

      expect(find.text(FuelInputMessages.required), findsNWidgets(2));
      expect(find.byType(ResultView), findsNothing);
      expect(find.byType(FuelInputField), findsNWidgets(4));
    },
  );

  testWidgets(
    'shows greater-than-zero error when a price is zero',
    (WidgetTester tester) async {
      await _pumpApp(tester);

      await _enterPrice(tester, _gasolinePriceLabel, '0');
      await tester.tap(find.text(_submitButton), warnIfMissed: false);
      await tester.pump();

      expect(find.text(FuelInputMessages.greaterThanZero), findsOneWidget);
      expect(find.byType(ResultView), findsNothing);
    },
  );

  testWidgets(
    'returns to cleared form after new calculation from result',
    (WidgetTester tester) async {
      await _pumpApp(tester);

      await _enterPrice(tester, _gasolinePriceLabel, '6,00');
      await _enterPrice(tester, _ethanolPriceLabel, '4,19');
      await _submit(tester);

      await tester.tap(find.text(_newCalculationButton));
      await tester.pump();

      expect(find.byType(ResultView), findsNothing);
      final FuelInputField gasolinePriceField = tester
          .widget<FuelInputField>(find.widgetWithText(FuelInputField, _gasolinePriceLabel));
      final FuelInputField ethanolPriceField =
          tester.widget<FuelInputField>(
        find.widgetWithText(FuelInputField, _ethanolPriceLabel),
      );
      expect(gasolinePriceField.controller.text, isEmpty);
      expect(ethanolPriceField.controller.text, isEmpty);
      expect(find.text(_standardRuleSegment), findsOneWidget);
    },
  );

  testWidgets(
    'completes the happy path without layout exceptions on a 320px screen',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await _pumpApp(tester);

      await _enterPrice(tester, _gasolinePriceLabel, '6,00');
      await _enterPrice(tester, _ethanolPriceLabel, '4,19');
      await _submit(tester);
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.byType(ResultView), findsOneWidget);
      expect(find.text('Abasteça com etanol'), findsOneWidget);
    },
  );
}
