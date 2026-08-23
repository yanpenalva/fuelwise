import 'package:decimal/decimal.dart';
import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fuelwise/application/profile/vehicle_profile_repository.dart';
import 'package:fuelwise/application/profile/vehicle_profile_storage_exception.dart';
import 'package:fuelwise/domain/vehicle_profile.dart';
import 'package:fuelwise/infrastructure/database/app_database.dart';
import 'package:fuelwise/infrastructure/database/drift_vehicle_profile_repository.dart';

void main() {
  late AppDatabase database;
  late VehicleProfileRepository repository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    repository = DriftVehicleProfileRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  VehicleProfile profile({
    String name = 'City car',
    Decimal? gasoline,
    Decimal? ethanol,
  }) {
    return VehicleProfile(
      name: name,
      gasolineKmPerLiter: gasoline,
      ethanolKmPerLiter: ethanol,
    );
  }

  test('load returns null when table empty', () async {
    final loaded = await repository.load();

    expect(loaded, isNull);
  });

  test('save and load round-trip decimals exactly', () async {
    final saved = await repository.save(
      profile(gasoline: Decimal.parse('12.50'), ethanol: Decimal.parse('8.4')),
    );

    final loaded = await repository.load();

    expect(saved.gasolineKmPerLiter, Decimal.parse('12.50'));
    expect(saved.ethanolKmPerLiter, Decimal.parse('8.4'));
    expect(loaded, saved);
    expect(loaded!.gasolineKmPerLiter, Decimal.parse('12.50'));
    expect(loaded.ethanolKmPerLiter, Decimal.parse('8.4'));
  });

  test('second save updates the single row', () async {
    await repository.save(profile(name: 'First'));
    await repository.save(profile(name: 'Second'));

    final rows = await database.select(database.vehicleProfiles).get();

    expect(rows, hasLength(1));
    expect(rows.single.name, 'Second');
    expect((await repository.load())!.name, 'Second');
  });

  test('null consumptions round-trip', () async {
    final saved = await repository.save(profile());

    final loaded = await repository.load();

    expect(saved.gasolineKmPerLiter, isNull);
    expect(saved.ethanolKmPerLiter, isNull);
    expect(loaded, saved);
  });

  test("stored 'abc' consumption throws on load", () async {
    await database.insertVehicleProfile(
      VehicleProfilesCompanion.insert(
        name: 'Broken',
        gasolineKmPerLiter: const Value('abc'),
        updatedAt: DateTime.utc(2026, 1, 1),
      ),
    );

    expect(repository.load, throwsA(isA<VehicleProfileStorageException>()));
  });

  test('stored zero consumption throws on load', () async {
    await database.insertVehicleProfile(
      VehicleProfilesCompanion.insert(
        name: 'Zero',
        ethanolKmPerLiter: const Value('0'),
        updatedAt: DateTime.utc(2026, 1, 1),
      ),
    );

    expect(repository.load, throwsA(isA<VehicleProfileStorageException>()));
  });

  test('stored negative consumption throws on load', () async {
    await database.insertVehicleProfile(
      VehicleProfilesCompanion.insert(
        name: 'Negative',
        gasolineKmPerLiter: const Value('-3'),
        updatedAt: DateTime.utc(2026, 1, 1),
      ),
    );

    expect(repository.load, throwsA(isA<VehicleProfileStorageException>()));
  });
}
