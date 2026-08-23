import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'application/history/history_controller.dart';
import 'application/preferences/app_preferences_controller.dart';
import 'application/preferences/theme_mode_preference.dart';
import 'application/profile/vehicle_profile_controller.dart';
import 'infrastructure/database/app_database.dart';
import 'infrastructure/database/drift_calculation_history_repository.dart';
import 'infrastructure/database/drift_vehicle_profile_repository.dart';
import 'infrastructure/preferences/shared_preferences_app_preferences.dart';
import 'presentation/pages/home_page.dart';
import 'presentation/theme/app_theme.dart';

void main() {
  final AppDatabase database = AppDatabase();

  runApp(
    ProviderScope(
      overrides: [
        appPreferencesRepositoryProvider.overrideWithValue(
          SharedPreferencesAppPreferences(),
        ),
        vehicleProfileRepositoryProvider.overrideWithValue(
          DriftVehicleProfileRepository(database),
        ),
        calculationHistoryRepositoryProvider.overrideWithValue(
          DriftCalculationHistoryRepository(database),
        ),
      ],
      child: const FuelwiseApp(),
    ),
  );
}

class FuelwiseApp extends ConsumerWidget {
  const FuelwiseApp({super.key});

  static ThemeMode _toThemeMode(ThemeModePreference preference) {
    return switch (preference) {
      ThemeModePreference.system => ThemeMode.system,
      ThemeModePreference.light => ThemeMode.light,
      ThemeModePreference.dark => ThemeMode.dark,
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeModePreference preference =
        ref.watch(appPreferencesProvider).value?.themeMode ??
            ThemeModePreference.system;

    return MaterialApp(
      title: 'Fuelwise',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: _toThemeMode(preference),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('pt', 'BR'),
      ],
      localeResolutionCallback: (
        Locale? deviceLocale,
        Iterable<Locale> supportedLocales,
      ) {
        if (deviceLocale != null && supportedLocales.contains(deviceLocale)) {
          return deviceLocale;
        }

        return const Locale('pt', 'BR');
      },
      home: const HomePage(),
    );
  }
}
