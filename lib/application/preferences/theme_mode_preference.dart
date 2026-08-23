enum ThemeModePreference { system, light, dark }

ThemeModePreference themeModePreferenceFromName(String? value) {
  if (value == null) {
    return ThemeModePreference.system;
  }
  for (final ThemeModePreference preference in ThemeModePreference.values) {
    if (preference.name == value) {
      return preference;
    }
  }
  return ThemeModePreference.system;
}
