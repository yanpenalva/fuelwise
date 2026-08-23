import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fuelwise/application/profile/vehicle_profile_storage_exception.dart';
import 'package:fuelwise/infrastructure/database/app_database.dart';
import 'package:fuelwise/infrastructure/database/vehicle_profile_mapper.dart';

void main() {
  const VehicleProfileMapper mapper = VehicleProfileMapper();

  VehicleProfileRow row({String? gasoline, String? ethanol}) {
    return VehicleProfileRow(
      id: 1,
      name: 'City car',
      gasolineKmPerLiter: gasoline,
      ethanolKmPerLiter: ethanol,
      updatedAt: DateTime.utc(2026, 8, 22),
    );
  }

  test('maps null consumption columns to null domain values', () {
    final profile = mapper.toDomain(row());

    expect(profile.gasolineKmPerLiter, isNull);
    expect(profile.ethanolKmPerLiter, isNull);
    expect(profile.hasConsumption, isFalse);
  });

  test('normalizes comma decimal separator stored as text', () {
    final profile = mapper.toDomain(row(gasoline: '12,5', ethanol: '8,4'));

    expect(profile.gasolineKmPerLiter, Decimal.parse('12.5'));
    expect(profile.ethanolKmPerLiter, Decimal.parse('8.4'));
  });

  test('treats a single comma as decimal separator in ambiguous text', () {
    final profile = mapper.toDomain(row(gasoline: '1,234'));

    expect(profile.gasolineKmPerLiter, Decimal.parse('1.234'));
  });

  test('maps stored dot-decimal text to an equal decimal value', () {
    final profile = mapper.toDomain(row(gasoline: '12.50'));

    expect(profile.gasolineKmPerLiter, Decimal.parse('12.5'));
  });

  test('throws typed storage exception for malformed stored value', () {
    expect(
      () => mapper.toDomain(row(gasoline: 'abc')),
      throwsA(isA<VehicleProfileStorageException>()),
    );
  });
}
