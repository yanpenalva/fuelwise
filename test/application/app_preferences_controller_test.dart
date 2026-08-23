import 'package:decimal/decimal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fuelwise/application/preferences/app_preferences.dart';
import 'package:fuelwise/application/preferences/app_preferences_controller.dart';
import 'package:fuelwise/application/preferences/app_preferences_data.dart';
import 'package:fuelwise/application/preferences/rule_mode.dart';
import 'package:fuelwise/application/preferences/theme_mode_preference.dart';

final class _InMemoryAppPreferences implements AppPreferences {
  _InMemoryAppPreferences(this._data);

  AppPreferencesData _data;
  bool? savedWelcomeSeen;
  RuleMode? savedRuleMode;
  Decimal? savedCustomThreshold;
  ThemeModePreference? savedThemeMode;

  @override
  Future<AppPreferencesData> load() async => _data;

  @override
  Future<void> saveCustomThreshold({required Decimal? value}) async {
    savedCustomThreshold = value;
    _data = AppPreferencesData(
      hasSeenWelcome: _data.hasSeenWelcome,
      ruleMode: _data.ruleMode,
      customThreshold: value,
    );
  }

  @override
  Future<void> saveHasSeenWelcome({required bool value}) async {
    savedWelcomeSeen = value;
    _data = _data.copyWith(hasSeenWelcome: value);
  }

  @override
  Future<void> saveRuleMode({required RuleMode mode}) async {
    savedRuleMode = mode;
    _data = _data.copyWith(ruleMode: mode);
  }

  @override
  Future<void> saveThemeMode({required ThemeModePreference mode}) async {
    savedThemeMode = mode;
    _data = _data.copyWith(themeMode: mode);
  }
}

final class _ThrowingAppPreferences implements AppPreferences {
  @override
  Future<AppPreferencesData> load() async => throw Exception('load failed');

  @override
  Future<void> saveCustomThreshold({required Decimal? value}) async {}

  @override
  Future<void> saveHasSeenWelcome({required bool value}) async {}

  @override
  Future<void> saveRuleMode({required RuleMode mode}) async {}

  @override
  Future<void> saveThemeMode({required ThemeModePreference mode}) async {}
}

void main() {
  test('starts loading then exposes loaded data', () async {
    final _InMemoryAppPreferences repository = _InMemoryAppPreferences(
      const AppPreferencesData(hasSeenWelcome: true, ruleMode: RuleMode.custom),
    );
    final ProviderContainer container = ProviderContainer(
      overrides: [
        appPreferencesRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);

    expect(
      container.read(appPreferencesProvider),
      isA<AsyncLoading<AppPreferencesData>>(),
    );

    final AppPreferencesData data = await container.read(
      appPreferencesProvider.future,
    );

    expect(data.hasSeenWelcome, isTrue);
    expect(data.ruleMode, RuleMode.custom);
  });

  test('markWelcomeSeen persists true and updates state', () async {
    final _InMemoryAppPreferences repository = _InMemoryAppPreferences(
      const AppPreferencesData.defaults(),
    );
    final ProviderContainer container = ProviderContainer(
      overrides: [
        appPreferencesRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);
    await container.read(appPreferencesProvider.future);

    await container.read(appPreferencesProvider.notifier).markWelcomeSeen();

    expect(repository.savedWelcomeSeen, isTrue);
    final AppPreferencesData state = container
        .read(appPreferencesProvider)
        .requireValue;
    expect(state.hasSeenWelcome, isTrue);
  });

  test('selectRule persists custom mode and updates state', () async {
    final _InMemoryAppPreferences repository = _InMemoryAppPreferences(
      const AppPreferencesData.defaults(),
    );
    final ProviderContainer container = ProviderContainer(
      overrides: [
        appPreferencesRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);
    await container.read(appPreferencesProvider.future);

    await container
        .read(appPreferencesProvider.notifier)
        .selectRule(RuleMode.custom);

    expect(repository.savedRuleMode, RuleMode.custom);
    final AppPreferencesData state = container
        .read(appPreferencesProvider)
        .requireValue;
    expect(state.ruleMode, RuleMode.custom);
  });

  test('setCustomThreshold persists value and updates state', () async {
    final _InMemoryAppPreferences repository = _InMemoryAppPreferences(
      const AppPreferencesData.defaults(),
    );
    final ProviderContainer container = ProviderContainer(
      overrides: [
        appPreferencesRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);
    await container.read(appPreferencesProvider.future);

    await container
        .read(appPreferencesProvider.notifier)
        .setCustomThreshold(Decimal.parse('0.75'));

    expect(repository.savedCustomThreshold, Decimal.parse('0.75'));
    final AppPreferencesData state = container
        .read(appPreferencesProvider)
        .requireValue;
    expect(state.customThreshold, Decimal.parse('0.75'));
  });

  test('setCustomThreshold with null clears stored threshold', () async {
    final _InMemoryAppPreferences repository = _InMemoryAppPreferences(
      const AppPreferencesData.defaults(),
    );
    final ProviderContainer container = ProviderContainer(
      overrides: [
        appPreferencesRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);
    await container.read(appPreferencesProvider.future);
    final AppPreferencesController controller = container.read(
      appPreferencesProvider.notifier,
    );
    await controller.setCustomThreshold(Decimal.parse('0.75'));

    await controller.setCustomThreshold(null);

    expect(repository.savedCustomThreshold, isNull);
    expect(
      container.read(appPreferencesProvider).requireValue.customThreshold,
      isNull,
    );
  });

  test('selectThemeMode persists and updates state', () async {
    final _InMemoryAppPreferences repository = _InMemoryAppPreferences(
      const AppPreferencesData.defaults(),
    );
    final ProviderContainer container = ProviderContainer(
      overrides: [
        appPreferencesRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);
    await container.read(appPreferencesProvider.future);

    await container
        .read(appPreferencesProvider.notifier)
        .selectThemeMode(ThemeModePreference.dark);

    expect(repository.savedThemeMode, ThemeModePreference.dark);
    final AppPreferencesData state = container
        .read(appPreferencesProvider)
        .requireValue;
    expect(state.themeMode, ThemeModePreference.dark);
  });

  test('exposes error state when repository load throws', () async {
    final ProviderContainer container = ProviderContainer(
      overrides: [
        appPreferencesRepositoryProvider.overrideWithValue(
          _ThrowingAppPreferences(),
        ),
      ],
    );
    addTearDown(container.dispose);

    container.read(appPreferencesProvider);
    await Future<void>.delayed(Duration.zero);

    final AsyncValue<AppPreferencesData> state = container.read(
      appPreferencesProvider,
    );
    expect(state.hasError, isTrue);
    expect(state.error, isException);
  });
}
