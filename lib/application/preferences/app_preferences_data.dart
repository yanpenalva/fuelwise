import 'package:decimal/decimal.dart';

import 'rule_mode.dart';
import 'theme_mode_preference.dart';

final class AppPreferencesData {
  const AppPreferencesData({
    required this.hasSeenWelcome,
    required this.ruleMode,
    this.customThreshold,
    this.themeMode = ThemeModePreference.system,
  });

  const AppPreferencesData.defaults()
      : hasSeenWelcome = false,
        ruleMode = RuleMode.standard,
        customThreshold = null,
        themeMode = ThemeModePreference.system;

  final bool hasSeenWelcome;
  final RuleMode ruleMode;
  final Decimal? customThreshold;
  final ThemeModePreference themeMode;

  AppPreferencesData copyWith({
    bool? hasSeenWelcome,
    RuleMode? ruleMode,
    Decimal? customThreshold,
    bool setCustomThreshold = false,
    ThemeModePreference? themeMode,
  }) {
    return AppPreferencesData(
      hasSeenWelcome: hasSeenWelcome ?? this.hasSeenWelcome,
      ruleMode: ruleMode ?? this.ruleMode,
      customThreshold:
          setCustomThreshold ? customThreshold : this.customThreshold,
      themeMode: themeMode ?? this.themeMode,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is AppPreferencesData &&
        other.hasSeenWelcome == hasSeenWelcome &&
        other.ruleMode == ruleMode &&
        other.customThreshold == customThreshold &&
        other.themeMode == themeMode;
  }

  @override
  int get hashCode =>
      Object.hash(hasSeenWelcome, ruleMode, customThreshold, themeMode);
}
