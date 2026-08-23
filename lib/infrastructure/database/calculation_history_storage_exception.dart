final class CalculationHistoryStorageException implements Exception {
  final String fieldName;
  final String rawValue;

  const CalculationHistoryStorageException(this.fieldName, this.rawValue);

  @override
  String toString() =>
      'CalculationHistoryStorageException: invalid value "$rawValue" for field "$fieldName"';
}
