import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fuelwise/infrastructure/database/app_database.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  test('pins schema version to 1', () {
    expect(database.schemaVersion, 1);
  });

  test('creates both tables on open', () async {
    final vehicles = await database
        .customSelect(
          'SELECT name FROM sqlite_master WHERE type = ?',
          variables: [Variable.withString('table')],
        )
        .get();

    final names = vehicles.map((row) => row.read<String>('name')).toSet();

    expect(names, containsAll(['vehicle_profiles', 'history_entries']));
  });

  test('inserts vehicle profile and reads back all columns', () async {
    final inserted = await database.insertVehicleProfile(
      VehicleProfilesCompanion.insert(
        name: 'City car',
        gasolineKmPerLiter: const Value('12.5'),
        ethanolKmPerLiter: const Value('8.4'),
        updatedAt: DateTime.utc(2026, 1, 2, 3, 4, 5),
      ),
    );

    final loaded = await database.getVehicleProfile();

    expect(loaded, isNotNull);
    expect(loaded!.id, inserted.id);
    expect(loaded.name, 'City car');
    expect(loaded.gasolineKmPerLiter, '12.5');
    expect(loaded.ethanolKmPerLiter, '8.4');
    expect(
      loaded.updatedAt.isAtSameMomentAs(DateTime.utc(2026, 1, 2, 3, 4, 5)),
      isTrue,
    );
  });

  test('updates profile name and reads it back', () async {
    final inserted = await database.insertVehicleProfile(
      VehicleProfilesCompanion.insert(
        name: 'Old name',
        updatedAt: DateTime.utc(2026, 2, 1),
      ),
    );

    await database.updateVehicleProfile(inserted.copyWith(name: 'New name'));

    final loaded = await database.getVehicleProfile();

    expect(loaded!.name, 'New name');
    expect(loaded.id, inserted.id);
  });

  test('getVehicleProfile returns null when table empty', () async {
    final loaded = await database.getVehicleProfile();

    expect(loaded, isNull);
  });

  test('inserts history entry and reads it back', () async {
    final createdAt = DateTime.utc(2026, 3, 10, 12, 0);

    final inserted = await database.insertHistoryEntry(
      HistoryEntriesCompanion.insert(
        createdAt: createdAt,
        gasolinePrice: '6.09',
        ethanolPrice: '4.49',
        recommendedFuel: 'ethanol',
        ratio: '0.737',
        appliedThreshold: '0.75',
        thresholdSource: 'profile',
        maximumEthanolPrice: '4.57',
        difference: '-0.08',
        gasolineConsumption: const Value('12.5'),
        ethanolConsumption: const Value('8.4'),
        gasolineCostPerKm: const Value('0.487'),
        ethanolCostPerKm: const Value('0.534'),
      ),
    );

    final loaded = await (database.select(
      database.historyEntries,
    )..where((t) => t.id.equals(inserted.id))).getSingle();

    expect(loaded.createdAt.isAtSameMomentAs(createdAt), isTrue);
    expect(loaded.gasolinePrice, '6.09');
    expect(loaded.ethanolPrice, '4.49');
    expect(loaded.gasolineConsumption, '12.5');
    expect(loaded.ethanolConsumption, '8.4');
    expect(loaded.recommendedFuel, 'ethanol');
    expect(loaded.ratio, '0.737');
    expect(loaded.appliedThreshold, '0.75');
    expect(loaded.thresholdSource, 'profile');
    expect(loaded.gasolineCostPerKm, '0.487');
    expect(loaded.ethanolCostPerKm, '0.534');
    expect(loaded.maximumEthanolPrice, '4.57');
    expect(loaded.difference, '-0.08');
  });
}
