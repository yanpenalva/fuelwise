import 'dart:async';

import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fuelwise/application/preferences/app_preferences.dart';
import 'package:fuelwise/application/preferences/app_preferences_controller.dart';
import 'package:fuelwise/application/preferences/app_preferences_data.dart';
import 'package:fuelwise/application/preferences/rule_mode.dart';
import 'package:fuelwise/application/preferences/theme_mode_preference.dart';
import 'package:fuelwise/main.dart';
import 'package:fuelwise/presentation/widgets/fuel_input_field.dart';

final class _BlockingAppPreferences implements AppPreferences {
  final Completer<AppPreferencesData> _loadCompleter =
      Completer<AppPreferencesData>();

  void complete() {
    _loadCompleter.complete(const AppPreferencesData.defaults());
  }

  @override
  Future<AppPreferencesData> load() => _loadCompleter.future;

  @override
  Future<void> saveHasSeenWelcome({required bool value}) async {}

  @override
  Future<void> saveRuleMode({required RuleMode mode}) async {}

  @override
  Future<void> saveCustomThreshold({required Decimal? value}) async {}

  @override
  Future<void> saveThemeMode({required ThemeModePreference mode}) async {}
}

void main() {
  testWidgets(
    'shows slogan while initial preferences load and form afterwards',
    (tester) async {
      final _BlockingAppPreferences preferences = _BlockingAppPreferences();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appPreferencesRepositoryProvider.overrideWithValue(preferences),
          ],
          child: const FuelwiseApp(),
        ),
      );
      await tester.pump();

      expect(find.text('Combustível certo, custo consciente.'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(FuelInputField), findsNothing);

      preferences.complete();
      await tester.pump(const Duration(milliseconds: 600));

      expect(find.text('Combustível certo, custo consciente.'), findsOneWidget);
      expect(find.byType(FuelInputField), findsNothing);

      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();

      expect(find.byType(FuelInputField), findsNWidgets(4));
      expect(find.text('Combustível certo, custo consciente.'), findsNothing);
    },
  );
}
