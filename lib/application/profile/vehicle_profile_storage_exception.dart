final class VehicleProfileStorageException implements Exception {
  final String fieldName;
  final String rawValue;

  const VehicleProfileStorageException(this.fieldName, this.rawValue);

  @override
  String toString() =>
      'VehicleProfileStorageException: invalid value "$rawValue" for field "$fieldName"';
}
