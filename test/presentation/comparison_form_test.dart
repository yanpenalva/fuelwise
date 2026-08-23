import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fuelwise/application/preferences/app_preferences_controller.dart';
import 'package:fuelwise/application/preferences/app_preferences_data.dart';
import 'package:fuelwise/application/preferences/rule_mode.dart';
import 'package:fuelwise/domain/fuel_input_parser.dart';
import 'package:fuelwise/presentation/pages/home_page.dart';
import 'package:fuelwise/presentation/widgets/fuel_input_field.dart';
import 'package:fuelwise/presentation/widgets/result_view.dart';

import '../helpers/fake_app_preferences.dart';

Future<void> _pumpHomePage(WidgetTester tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appPreferencesRepositoryProvider.overrideWithValue(
          FakeAppPreferences(
            initial: const AppPreferencesData(
              hasSeenWelcome: true,
              ruleMode: RuleMode.standard,
            ),
          ),
        ),
      ],
      child: const MaterialApp(home: HomePage()),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _submit(WidgetTester tester) async {
  await tester.ensureVisible(find.text('Calcular'));
  await tester.pump();
  await tester.tap(find.text('Calcular'), warnIfMissed: false);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 600));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('shows required error when submitting masked-empty price field', (
    WidgetTester tester,
  ) async {
    await _pumpHomePage(tester);

    await tester.enterText(
      find.widgetWithText(FuelInputField, 'Preço da gasolina'),
      ',',
    );
    await _submit(tester);

    expect(find.text(FuelInputMessages.required), findsNWidgets(2));
  });

  testWidgets('shows greater-than-zero error when submitting a zero price', (
    WidgetTester tester,
  ) async {
    await _pumpHomePage(tester);

    await tester.enterText(
      find.widgetWithText(FuelInputField, 'Preço da gasolina'),
      '0',
    );
    await _submit(tester);

    expect(find.text(FuelInputMessages.greaterThanZero), findsOneWidget);
  });

  testWidgets('shows required error when submitting empty required field', (
    WidgetTester tester,
  ) async {
    await _pumpHomePage(tester);

    await tester.enterText(
      find.widgetWithText(FuelInputField, 'Preço da gasolina'),
      '4,50',
    );
    await _submit(tester);

    expect(find.text(FuelInputMessages.required), findsOneWidget);
  });

  testWidgets('shows ResultView after valid submission with only prices', (
    WidgetTester tester,
  ) async {
    await _pumpHomePage(tester);

    await tester.enterText(
      find.widgetWithText(FuelInputField, 'Preço da gasolina'),
      '4,50',
    );
    await tester.enterText(
      find.widgetWithText(FuelInputField, 'Preço do etanol'),
      '3,00',
    );
    await _submit(tester);

    expect(find.byType(ResultView), findsOneWidget);
  });

  testWidgets(
    'shows ResultView after valid submission with both consumptions',
    (WidgetTester tester) async {
      await _pumpHomePage(tester);

      await tester.enterText(
        find.widgetWithText(FuelInputField, 'Preço da gasolina'),
        '4,50',
      );
      await tester.enterText(
        find.widgetWithText(FuelInputField, 'Preço do etanol'),
        '3,00',
      );
      await tester.tap(find.text('Personalizada'));
      await tester.pump();
      await tester.enterText(
        find.widgetWithText(FuelInputField, 'Consumo de gasolina'),
        '10',
      );
      await tester.enterText(
        find.widgetWithText(FuelInputField, 'Consumo de etanol'),
        '8',
      );
      await _submit(tester);

      expect(find.byType(ResultView), findsOneWidget);
    },
  );

  testWidgets('accepts comma decimal separator on submission', (
    WidgetTester tester,
  ) async {
    await _pumpHomePage(tester);

    await tester.enterText(
      find.widgetWithText(FuelInputField, 'Preço da gasolina'),
      '4,20',
    );
    await tester.enterText(
      find.widgetWithText(FuelInputField, 'Preço do etanol'),
      '2,80',
    );
    await _submit(tester);

    expect(find.byType(ResultView), findsOneWidget);
  });

  testWidgets('formats currency input while typing', (
    WidgetTester tester,
  ) async {
    await _pumpHomePage(tester);

    await tester.enterText(
      find.widgetWithText(FuelInputField, 'Preço da gasolina'),
      '123456',
    );

    final FuelInputField field = tester.widget<FuelInputField>(
      find.widgetWithText(FuelInputField, 'Preço da gasolina'),
    );

    expect(field.controller.text, '1.234,56');
  });

  testWidgets('renders form without overflow on narrow surface', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await _pumpHomePage(tester);
    expect(tester.takeException(), isNull);
  });

  testWidgets('returns to empty form when tapping new calculation', (
    WidgetTester tester,
  ) async {
    await _pumpHomePage(tester);

    await tester.enterText(
      find.widgetWithText(FuelInputField, 'Preço da gasolina'),
      '4,50',
    );
    await tester.enterText(
      find.widgetWithText(FuelInputField, 'Preço do etanol'),
      '3,00',
    );
    await _submit(tester);

    await tester.tap(find.text('Novo cálculo'));
    await tester.pump();

    expect(find.byType(ResultView), findsNothing);
    final FuelInputField gasolinePriceField = tester.widget<FuelInputField>(
      find.widgetWithText(FuelInputField, 'Preço da gasolina'),
    );
    expect(gasolinePriceField.controller.text, isEmpty);
  });
}
