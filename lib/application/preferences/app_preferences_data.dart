import 'package:decimal/decimal.dart';

import 'rule_mode.dart';

final class AppPreferencesData {
  const AppPreferencesData({
    required this.hasSeenWelcome,
    required this.ruleMode,
    this.customThreshold,
  });

  const AppPreferencesData.defaults()
      : hasSeenWelcome = false,
        ruleMode = RuleMode.standard,
        customThreshold = null;

  final bool hasSeenWelcome;
  final RuleMode ruleMode;
  final Decimal? customThreshold;

  AppPreferencesData copyWith({
    bool? hasSeenWelcome,
    RuleMode? ruleMode,
    Decimal? customThreshold,
    bool setCustomThreshold = false,
  }) {
    return AppPreferencesData(
      hasSeenWelcome: hasSeenWelcome ?? this.hasSeenWelcome,
      ruleMode: ruleMode ?? this.ruleMode,
      customThreshold:
          setCustomThreshold ? customThreshold : this.customThreshold,
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
        other.customThreshold == customThreshold;
  }

  @override
  int get hashCode =>
      Object.hash(hasSeenWelcome, ruleMode, customThreshold);
}
