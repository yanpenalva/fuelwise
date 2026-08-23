import 'package:decimal/decimal.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../application/preferences/app_preferences.dart';
import '../../application/preferences/app_preferences_data.dart';
import '../../application/preferences/rule_mode.dart';
import '../../application/preferences/theme_mode_preference.dart';
import 'preference_keys.dart';

class SharedPreferencesAppPreferences implements AppPreferences {
  SharedPreferencesAppPreferences([SharedPreferencesAsync? preferences])
      : preferences = preferences ?? SharedPreferencesAsync();

  final SharedPreferencesAsync preferences;

  @override
  Future<AppPreferencesData> load() async {
    final bool welcomeSeen =
        await preferences.getBool(PreferenceKeys.welcomeSeen) ?? false;
    final String? modeName =
        await preferences.getString(PreferenceKeys.ruleMode);
    final String? themeModeName =
        await preferences.getString(PreferenceKeys.themeMode);
    return AppPreferencesData(
      hasSeenWelcome: welcomeSeen,
      ruleMode: ruleModeFromName(modeName),
      customThreshold: await _readCustomThreshold(),
      themeMode: themeModePreferenceFromName(themeModeName),
    );
  }

  @override
  Future<void> saveHasSeenWelcome({required bool value}) {
    return preferences.setBool(PreferenceKeys.welcomeSeen, value);
  }

  @override
  Future<void> saveRuleMode({required RuleMode mode}) {
    return preferences.setString(PreferenceKeys.ruleMode, mode.name);
  }

  @override
  Future<void> saveCustomThreshold({required Decimal? value}) {
    if (value == null) {
      return preferences.remove(PreferenceKeys.customThreshold);
    }
    return preferences.setString(
      PreferenceKeys.customThreshold,
      value.toString(),
    );
  }

  @override
  Future<void> saveThemeMode({required ThemeModePreference mode}) {
    return preferences.setString(PreferenceKeys.themeMode, mode.name);
  }

  Future<Decimal?> _readCustomThreshold() async {
    final String stored =
        await preferences.getString(PreferenceKeys.customThreshold) ?? '';
    if (stored.isEmpty) {
      return null;
    }
    final Decimal? parsed =
        Decimal.tryParse(stored.replaceAll(',', '.'));
    if (parsed == null || parsed <= Decimal.zero) {
      return null;
    }
    return parsed;
  }
}
