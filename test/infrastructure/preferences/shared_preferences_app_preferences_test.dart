import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fuelwise/application/preferences/app_preferences_data.dart';
import 'package:fuelwise/application/preferences/rule_mode.dart';
import 'package:fuelwise/infrastructure/preferences/preference_keys.dart';
import 'package:fuelwise/infrastructure/preferences/shared_preferences_app_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

final class _InMemorySharedPreferencesAsync implements SharedPreferencesAsync {
  final Map<String, Object> values = <String, Object>{};

  @override
  Future<void> clear({Set<String>? allowList}) async {
    values.clear();
  }

  @override
  Future<bool> containsKey(String key) async => values.containsKey(key);

  @override
  Future<bool?> getBool(String key) async => values[key] as bool?;

  @override
  Future<double?> getDouble(String key) async => values[key] as double?;

  @override
  Future<int?> getInt(String key) async => values[key] as int?;

  @override
  Future<Set<String>> getKeys({Set<String>? allowList}) async =>
      Set<String>.from(values.keys);

  @override
  Future<Map<String, Object?>> getAll({Set<String>? allowList}) async =>
      Map<String, Object?>.from(values);

  @override
  Future<String?> getString(String key) async => values[key] as String?;

  @override
  Future<List<String>?> getStringList(String key) async =>
      values[key] as List<String>?;

  @override
  Future<void> setBool(String key, bool value) async {
    values[key] = value;
  }

  @override
  Future<void> setDouble(String key, double value) async {
    values[key] = value;
  }

  @override
  Future<void> setInt(String key, int value) async {
    values[key] = value;
  }

  @override
  Future<void> setString(String key, String value) async {
    values[key] = value;
  }

  @override
  Future<void> setStringList(String key, List<String> value) async {
    values[key] = value;
  }

  @override
  Future<void> remove(String key) async {
    values.remove(key);
  }
}

void main() {
  late _InMemorySharedPreferencesAsync store;

  setUp(() {
    store = _InMemorySharedPreferencesAsync();
  });

  test('returns defaults when store empty', () async {
    final SharedPreferencesAppPreferences repository =
        SharedPreferencesAppPreferences(store);

    final AppPreferencesData result = await repository.load();

    expect(result.hasSeenWelcome, isFalse);
    expect(result.ruleMode, RuleMode.standard);
    expect(result.customThreshold, isNull);
  });

  test('round-trips hasSeenWelcome write and read', () async {
    final SharedPreferencesAppPreferences repository =
        SharedPreferencesAppPreferences(store);

    await repository.saveHasSeenWelcome(value: true);

    final AppPreferencesData loaded = await repository.load();

    expect(loaded.hasSeenWelcome, isTrue);
  });

  test('round-trips custom rule mode', () async {
    final SharedPreferencesAppPreferences repository =
        SharedPreferencesAppPreferences(store);

    await repository.saveRuleMode(mode: RuleMode.custom);

    final AppPreferencesData loaded = await repository.load();

    expect(loaded.ruleMode, RuleMode.custom);
  });

  test('falls back to standard when stored mode string unknown', () async {
    store.values[PreferenceKeys.ruleMode] = 'nonsense';
    final SharedPreferencesAppPreferences repository =
        SharedPreferencesAppPreferences(store);

    final AppPreferencesData loaded = await repository.load();

    expect(loaded.ruleMode, RuleMode.standard);
  });

  test('parses custom threshold written with comma decimal separator',
      () async {
    store.values[PreferenceKeys.customThreshold] = '4,59';
    final SharedPreferencesAppPreferences repository =
        SharedPreferencesAppPreferences(store);

    final AppPreferencesData loaded = await repository.load();

    expect(loaded.customThreshold, Decimal.parse('4.59'));
  });

  test('parses custom threshold written with dot decimal separator', () async {
    store.values[PreferenceKeys.customThreshold] = '4.59';
    final SharedPreferencesAppPreferences repository =
        SharedPreferencesAppPreferences(store);

    final AppPreferencesData loaded = await repository.load();

    expect(loaded.customThreshold, Decimal.parse('4.59'));
  });

  test('yields null custom threshold without throwing when stored malformed',
      () async {
    store.values[PreferenceKeys.customThreshold] = 'not-a-number';
    final SharedPreferencesAppPreferences repository =
        SharedPreferencesAppPreferences(store);

    final AppPreferencesData loaded = await repository.load();

    expect(loaded.customThreshold, isNull);
  });

  test('removes stored key when saving null custom threshold', () async {
    final SharedPreferencesAppPreferences repository =
        SharedPreferencesAppPreferences(store);
    await repository.saveCustomThreshold(value: Decimal.parse('0.72'));

    await repository.saveCustomThreshold(value: null);

    expect(store.values.containsKey(PreferenceKeys.customThreshold), isFalse);
  });
}
