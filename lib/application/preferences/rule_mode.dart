enum RuleMode { standard, custom }

RuleMode ruleModeFromName(String? value) {
  if (value == null) {
    return RuleMode.standard;
  }
  for (final RuleMode mode in RuleMode.values) {
    if (mode.name == value) {
      return mode;
    }
  }
  return RuleMode.standard;
}
