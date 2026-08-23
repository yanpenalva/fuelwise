import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fuelwise/application/preferences/app_preferences_controller.dart';
import 'package:fuelwise/application/preferences/app_preferences_data.dart';
import 'package:fuelwise/application/preferences/rule_mode.dart';
import 'package:fuelwise/main.dart';
import 'package:fuelwise/presentation/release/app_release.dart';

import '../helpers/fake_app_preferences.dart';

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
  test('builds the release label', () {
    expect(
      AppRelease.label,
      equals('v1.0.0 · 22/08/2026 · yanpenalva'),
    );
  });

  testWidgets('shows release info at the bottom of the home form',
      (tester) async {
    await _pumpApp(tester);

    expect(
      find.text('v1.0.0 · 22/08/2026 · yanpenalva'),
      findsOneWidget,
    );
  });
}
