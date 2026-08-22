import 'package:decimal/decimal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_preferences.dart';
import 'app_preferences_data.dart';
import 'rule_mode.dart';

final Provider<AppPreferences> appPreferencesRepositoryProvider =
    Provider<AppPreferences>(
  (Ref ref) => throw UnimplementedError(),
);

final AsyncNotifierProvider<AppPreferencesController, AppPreferencesData>
    appPreferencesProvider =
    AsyncNotifierProvider<AppPreferencesController, AppPreferencesData>(
  AppPreferencesController.new,
);

class AppPreferencesController extends AsyncNotifier<AppPreferencesData> {
  @override
  Future<AppPreferencesData> build() async {
    return ref.read(appPreferencesRepositoryProvider).load();
  }

  Future<void> markWelcomeSeen() async {
    final AppPreferences repository =
        ref.read(appPreferencesRepositoryProvider);
    await repository.saveHasSeenWelcome(value: true);
    state = AsyncData(
      state.requireValue.copyWith(hasSeenWelcome: true),
    );
  }

  Future<void> selectRule(RuleMode mode) async {
    final AppPreferences repository =
        ref.read(appPreferencesRepositoryProvider);
    await repository.saveRuleMode(mode: mode);
    state = AsyncData(
      state.requireValue.copyWith(ruleMode: mode),
    );
  }

  Future<void> setCustomThreshold(Decimal? value) async {
    final AppPreferences repository =
        ref.read(appPreferencesRepositoryProvider);
    await repository.saveCustomThreshold(value: value);
    state = AsyncData(
      state.requireValue.copyWith(
        customThreshold: value,
        setCustomThreshold: true,
      ),
    );
  }
}
