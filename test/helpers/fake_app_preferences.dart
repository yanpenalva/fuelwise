import 'package:decimal/decimal.dart';
import 'package:fuelwise/application/preferences/app_preferences.dart';
import 'package:fuelwise/application/preferences/app_preferences_data.dart';
import 'package:fuelwise/application/preferences/rule_mode.dart';
import 'package:fuelwise/application/preferences/theme_mode_preference.dart';

final class FakeAppPreferences implements AppPreferences {
  FakeAppPreferences({AppPreferencesData? initial})
      : _data = initial ?? const AppPreferencesData.defaults();

  AppPreferencesData _data;
  int welcomeSeenSaveCount = 0;

  ThemeModePreference get themeMode => _data.themeMode;

  @override
  Future<AppPreferencesData> load() async => _data;

  @override
  Future<void> saveHasSeenWelcome({required bool value}) async {
    _data = _data.copyWith(hasSeenWelcome: value);
    if (value) {
      welcomeSeenSaveCount++;
    }
  }

  @override
  Future<void> saveRuleMode({required RuleMode mode}) async {
    _data = _data.copyWith(ruleMode: mode);
  }

  @override
  Future<void> saveCustomThreshold({required Decimal? value}) async {
    _data = _data.copyWith(customThreshold: value, setCustomThreshold: true);
  }

  @override
  Future<void> saveThemeMode({required ThemeModePreference mode}) async {
    _data = _data.copyWith(themeMode: mode);
  }
}
