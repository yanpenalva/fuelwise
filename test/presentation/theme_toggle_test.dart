import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fuelwise/application/preferences/app_preferences_controller.dart';
import 'package:fuelwise/application/preferences/app_preferences_data.dart';
import 'package:fuelwise/application/preferences/rule_mode.dart';
import 'package:fuelwise/application/preferences/theme_mode_preference.dart';
import 'package:fuelwise/main.dart';

import '../helpers/fake_app_preferences.dart';

void main() {
  testWidgets('theme icon cycles system to light to dark and persists',
      (tester) async {
    final FakeAppPreferences preferences = FakeAppPreferences(
      initial: const AppPreferencesData(
        hasSeenWelcome: true,
        ruleMode: RuleMode.standard,
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appPreferencesRepositoryProvider.overrideWithValue(preferences),
        ],
        child: const FuelwiseApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.brightness_auto), findsOneWidget);
    expect(preferences.themeMode, ThemeModePreference.system);

    await tester.tap(find.byIcon(Icons.brightness_auto));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.light_mode), findsOneWidget);
    expect(preferences.themeMode, ThemeModePreference.light);

    await tester.tap(find.byIcon(Icons.light_mode));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.dark_mode), findsOneWidget);
    expect(preferences.themeMode, ThemeModePreference.dark);

    await tester.tap(find.byIcon(Icons.dark_mode));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.brightness_auto), findsOneWidget);
    expect(preferences.themeMode, ThemeModePreference.system);
  });

  testWidgets('starts on persisted dark preference with dark icon',
      (tester) async {
    final FakeAppPreferences preferences = FakeAppPreferences(
      initial: const AppPreferencesData(
        hasSeenWelcome: true,
        ruleMode: RuleMode.standard,
        themeMode: ThemeModePreference.dark,
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appPreferencesRepositoryProvider.overrideWithValue(preferences),
        ],
        child: const FuelwiseApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.dark_mode), findsOneWidget);
  });
}