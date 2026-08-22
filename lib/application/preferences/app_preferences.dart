import 'package:decimal/decimal.dart';

import 'app_preferences_data.dart';
import 'rule_mode.dart';

abstract interface class AppPreferences {
  Future<AppPreferencesData> load();

  Future<void> saveHasSeenWelcome({required bool value});

  Future<void> saveRuleMode({required RuleMode mode});

  Future<void> saveCustomThreshold({required Decimal? value});
}
