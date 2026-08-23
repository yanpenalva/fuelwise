import 'package:decimal/decimal.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fuelwise/application/history/history_controller.dart';
import 'package:fuelwise/application/preferences/app_preferences_controller.dart';
import 'package:fuelwise/application/preferences/app_preferences_data.dart';
import 'package:fuelwise/application/preferences/rule_mode.dart';
import 'package:fuelwise/application/profile/vehicle_profile_controller.dart';
import 'package:fuelwise/domain/fuel_type.dart';
import 'package:fuelwise/domain/threshold_source.dart';
import 'package:fuelwise/domain/vehicle_profile.dart';
import 'package:fuelwise/infrastructure/database/app_database.dart';
import 'package:fuelwise/infrastructure/database/drift_calculation_history_repository.dart';
import 'package:fuelwise/infrastructure/database/drift_vehicle_profile_repository.dart';
import 'package:fuelwise/main.dart';
import 'package:fuelwise/presentation/pages/profile_page.dart';
import 'package:fuelwise/presentation/widgets/fuel_input_field.dart';
import 'package:fuelwise/presentation/widgets/result_view.dart';

import '../helpers/fake_app_preferences.dart';

Future<void> _pumpApp(
  WidgetTester tester, {
  required AppDatabase database,
  required FakeAppPreferences preferences,
}) {
  final container = ProviderContainer(
    overrides: [
      appPreferencesRepositoryProvider.overrideWithValue(preferences),
      vehicleProfileRepositoryProvider.overrideWithValue(
        DriftVehicleProfileRepository(database),
      ),
      calculationHistoryRepositoryProvider.overrideWithValue(
        DriftCalculationHistoryRepository(database),
      ),
    ],
  );
  addTearDown(container.dispose);

  return tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const FuelwiseApp(),
    ),
  ).then((_) => tester.pumpAndSettle());
}

Future<void> _calculate(
  WidgetTester tester, {
  required String gasolinePrice,
  required String ethanolPrice,
}) async {
  await tester.enterText(
    find.widgetWithText(FuelInputField, 'Preço da gasolina'),
    gasolinePrice,
  );
  await tester.enterText(
    find.widgetWithText(FuelInputField, 'Preço do etanol'),
    ethanolPrice,
  );
  await tester.ensureVisible(find.text('Calcular'));
  await tester.pump();
  await tester.tap(find.text('Calcular'), warnIfMissed: false);
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase database;
  late FakeAppPreferences preferences;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    preferences = FakeAppPreferences(
      initial: const AppPreferencesData(
        hasSeenWelcome: true,
        ruleMode: RuleMode.standard,
      ),
    );
  });

  tearDown(() async {
    await database.close();
  });

  testWidgets(
    'records exactly one history entry per valid calculation',
    (tester) async {
      await _pumpApp(tester, database: database, preferences: preferences);

      await _calculate(tester, gasolinePrice: '6,00', ethanolPrice: '4,19');
      expect(find.text('Abasteça com etanol'), findsOneWidget);
      expect(find.text('Salvo no histórico.'), findsOneWidget);

      await tester.tap(find.text('Novo cálculo'));
      await tester.pumpAndSettle();

      await _calculate(tester, gasolinePrice: '6,00', ethanolPrice: '4,50');
      expect(find.text('Salvo no histórico.'), findsOneWidget);

      final historyRepository = DriftCalculationHistoryRepository(database);
      final entries = await historyRepository.loadAll();

      expect(entries.length, 2);
      expect(entries[0].ethanolPrice.toString(), '4.5');
      expect(entries[1].ethanolPrice.toString(), '4.19');
      expect(entries[0].recommendedFuel, FuelType.gasoline);
      expect(entries[1].recommendedFuel, FuelType.ethanol);
      expect(entries[1].thresholdSource, ThresholdSource.standard);
    },
  );

  testWidgets(
    'prefills consumption fields from persisted profile after restart',
    (tester) async {
      final profileRepository = DriftVehicleProfileRepository(database);
      await profileRepository.save(
        VehicleProfile(
          name: 'Meu carro',
          gasolineKmPerLiter: Decimal.parse('10.5'),
          ethanolKmPerLiter: Decimal.parse('7'),
        ),
      );

      await _pumpApp(tester, database: database, preferences: preferences);

      final FuelInputField gasolineField = tester.widget<FuelInputField>(
        find.widgetWithText(FuelInputField, 'Consumo de gasolina'),
      );
      final FuelInputField ethanolField = tester.widget<FuelInputField>(
        find.widgetWithText(FuelInputField, 'Consumo de etanol'),
      );

      expect(gasolineField.controller.text, '10,5');
      expect(ethanolField.controller.text, '7');

      await _calculate(tester, gasolinePrice: '6,00', ethanolPrice: '4,19');
      expect(find.byType(ResultView), findsOneWidget);
    },
  );

  testWidgets(
    'saves profile explicitly through the profile page and never blocks calculation',
    (tester) async {
      await _pumpApp(tester, database: database, preferences: preferences);

      await tester.tap(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.byIcon(Icons.directions_car),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).at(0), 'Meu carro');
      await tester.enterText(find.byType(TextFormField).at(1), '10,5');
      await tester.enterText(find.byType(TextFormField).at(2), '7');

      await tester.tap(find.text('Salvar'));
      await tester.pumpAndSettle();

      expect(find.text('Perfil salvo.'), findsOneWidget);
      expect(find.byType(ProfilePage), findsNothing);

      final profileRepository = DriftVehicleProfileRepository(database);
      final stored = await profileRepository.load();

      expect(stored?.name, 'Meu carro');
      expect(stored?.gasolineKmPerLiter, Decimal.parse('10.5'));
      expect(stored?.ethanolKmPerLiter, Decimal.parse('7'));

      await _calculate(tester, gasolinePrice: '6,00', ethanolPrice: '4,19');
      expect(find.byType(ResultView), findsOneWidget);
    },
  );
}
