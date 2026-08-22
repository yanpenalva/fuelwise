import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fuelwise/application/preferences/app_preferences_controller.dart';
import 'package:fuelwise/application/preferences/app_preferences_data.dart';
import 'package:fuelwise/application/preferences/rule_mode.dart';
import 'package:fuelwise/main.dart';

import 'helpers/fake_app_preferences.dart';

Future<void> _pumpApp(WidgetTester tester) async {
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
      child: const FuelwiseApp(),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('renders the Fuelwise comparison form', (tester) async {
    await _pumpApp(tester);

    expect(find.text('Fuelwise'), findsOneWidget);
    expect(find.text('Padrão (0,70)'), findsOneWidget);
    expect(find.text('Personalizada'), findsOneWidget);
    expect(find.text('Calcular'), findsOneWidget);
  });
}
