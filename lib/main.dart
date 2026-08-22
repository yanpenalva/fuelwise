import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'application/preferences/app_preferences_controller.dart';
import 'infrastructure/preferences/shared_preferences_app_preferences.dart';
import 'presentation/pages/home_page.dart';
import 'presentation/theme/app_theme.dart';

void main() {
  runApp(
    ProviderScope(
      overrides: [
        appPreferencesRepositoryProvider.overrideWithValue(
          SharedPreferencesAppPreferences(),
        ),
      ],
      child: const FuelwiseApp(),
    ),
  );
}

class FuelwiseApp extends StatelessWidget {
  const FuelwiseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fuelwise',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
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
