import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fuelwise/application/preferences/app_preferences.dart';
import 'package:fuelwise/application/preferences/app_preferences_controller.dart';
import 'package:fuelwise/application/preferences/app_preferences_data.dart';
import 'package:fuelwise/application/preferences/rule_mode.dart';
import 'package:fuelwise/application/preferences/theme_mode_preference.dart';
import 'package:fuelwise/presentation/pages/home_page.dart';

final class _InMemoryAppPreferences implements AppPreferences {
  _InMemoryAppPreferences(this._data);

  AppPreferencesData _data;
  bool? savedWelcomeSeen;

  @override
  Future<AppPreferencesData> load() async => _data;

  @override
  Future<void> saveCustomThreshold({required Decimal? value}) async {}

  @override
  Future<void> saveHasSeenWelcome({required bool value}) async {
    savedWelcomeSeen = value;
    _data = _data.copyWith(hasSeenWelcome: value);
  }

  @override
  Future<void> saveRuleMode({required RuleMode mode}) async {}

  @override
  Future<void> saveThemeMode({required ThemeModePreference mode}) async {}
}

Future<void> _pumpHome(WidgetTester tester, AppPreferences repository) {
  return tester.pumpWidget(
    ProviderScope(
      overrides: [
        appPreferencesRepositoryProvider.overrideWithValue(repository),
      ],
      child: const MaterialApp(home: HomePage()),
    ),
  );
}

void main() {
  testWidgets('shows welcome dialog once on first run', (tester) async {
    final _InMemoryAppPreferences repository = _InMemoryAppPreferences(
      const AppPreferencesData.defaults(),
    );
    await _pumpHome(tester, repository);
    await tester.pumpAndSettle();

    expect(find.text('Bem-vindo ao Fuelwise'), findsOneWidget);
    expect(find.text('Entendi'), findsOneWidget);

    await tester.tap(find.text('Entendi'));
    await tester.pumpAndSettle();

    expect(find.text('Bem-vindo ao Fuelwise'), findsNothing);
    expect(repository.savedWelcomeSeen, isTrue);
  });

  testWidgets('does not show welcome dialog when already seen', (tester) async {
    await _pumpHome(
      tester,
      _InMemoryAppPreferences(
        const AppPreferencesData(
          hasSeenWelcome: true,
          ruleMode: RuleMode.standard,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Bem-vindo ao Fuelwise'), findsNothing);
  });

  testWidgets(
    'shows branded loading instead of form while preferences loading',
    (tester) async {
      await _pumpHome(
        tester,
        _InMemoryAppPreferences(const AppPreferencesData.defaults()),
      );
      await tester.pump();

      expect(find.text('Combustível certo, custo consciente.'), findsOneWidget);
      expect(find.text('Bem-vindo ao Fuelwise'), findsNothing);

      await tester.pumpAndSettle();
      expect(find.text('Bem-vindo ao Fuelwise'), findsOneWidget);
    },
  );
}
