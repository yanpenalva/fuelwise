import 'package:decimal/decimal.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fuelwise/domain/fuel_calculation_input.dart';
import 'package:fuelwise/domain/fuel_calculation_result.dart';
import 'package:fuelwise/domain/fuel_price.dart';
import 'package:fuelwise/domain/fuel_type.dart';
import 'package:fuelwise/domain/threshold_source.dart';
import 'package:fuelwise/domain/vehicle_efficiency.dart';
import 'package:fuelwise/infrastructure/database/app_database.dart';
import 'package:fuelwise/infrastructure/database/calculation_history_storage_exception.dart';
import 'package:fuelwise/infrastructure/database/drift_calculation_history_repository.dart';

void main() {
  late AppDatabase database;
  late DriftCalculationHistoryRepository repository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    repository = DriftCalculationHistoryRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  FuelCalculationInput input({
    String gasolinePrice = '4.50',
    String ethanolPrice = '3.10',
    VehicleEfficiency? efficiency,
  }) {
    return FuelCalculationInput(
      gasolinePrice: FuelPrice(
        type: FuelType.gasoline,
        value: Decimal.parse(gasolinePrice),
      ),
      ethanolPrice: FuelPrice(
        type: FuelType.ethanol,
        value: Decimal.parse(ethanolPrice),
      ),
      efficiency: efficiency,
    );
  }

  FuelCalculationResult result({
    FuelType recommendedFuel = FuelType.ethanol,
    Decimal? ratio,
    Decimal? appliedThreshold,
    ThresholdSource thresholdSource = ThresholdSource.standard,
    Decimal? gasolineCostPerKilometer,
    Decimal? ethanolCostPerKilometer,
    Decimal? maximumEthanolPrice,
    Decimal? difference,
  }) {
    return FuelCalculationResult(
      recommendedFuel: recommendedFuel,
      ratio: ratio ?? Decimal.parse('0.6888'),
      appliedThreshold: appliedThreshold ?? Decimal.parse('0.70'),
      thresholdSource: thresholdSource,
      gasolineCostPerKilometer:
          gasolineCostPerKilometer ?? Decimal.parse('0.36'),
      ethanolCostPerKilometer:
          ethanolCostPerKilometer ?? Decimal.parse('0.31'),
      maximumEthanolPrice:
          maximumEthanolPrice ?? Decimal.parse('3.15'),
      difference: difference ?? Decimal.parse('0.05'),
    );
  }

  test('record round-trips every field with exact decimal equality',
      () async {
    final recorded = await repository.record(
      input: input(
        gasolinePrice: '4.555',
        ethanolPrice: '3.101',
        efficiency: VehicleEfficiency(
          gasolineKmPerLiter: Decimal.parse('12.5'),
          ethanolKmPerLiter: Decimal.parse('8.4'),
        ),
      ),
      result: result(
        recommendedFuel: FuelType.ethanol,
        ratio: Decimal.parse('0.6815384615'),
        appliedThreshold: Decimal.parse('0.70'),
        thresholdSource: ThresholdSource.custom,
        gasolineCostPerKilometer: Decimal.parse('0.36440'),
        ethanolCostPerKilometer: Decimal.parse('0.369166'),
        maximumEthanolPrice: Decimal.parse('3.1884615385'),
        difference: Decimal.parse('-0.0047'),
      ),
    );

    expect(recorded.id, greaterThan(0));

    final loaded = await repository.loadAll();

    expect(loaded, hasLength(1));
    final entry = loaded.single;
    expect(entry.id, recorded.id);
    expect(entry.createdAt, recorded.createdAt);
    expect(entry.gasolinePrice, Decimal.parse('4.555'));
    expect(entry.ethanolPrice, Decimal.parse('3.101'));
    expect(entry.gasolineConsumption, Decimal.parse('12.5'));
    expect(entry.ethanolConsumption, Decimal.parse('8.4'));
    expect(entry.recommendedFuel, FuelType.ethanol);
    expect(entry.ratio, Decimal.parse('0.6815384615'));
    expect(entry.appliedThreshold, Decimal.parse('0.70'));
    expect(entry.thresholdSource, ThresholdSource.custom);
    expect(entry.gasolineCostPerKilometer, Decimal.parse('0.36440'));
    expect(entry.ethanolCostPerKilometer, Decimal.parse('0.369166'));
    expect(entry.maximumEthanolPrice, Decimal.parse('3.1884615385'));
    expect(entry.difference, Decimal.parse('-0.0047'));
  });

  test('consumption-less input stores null consumptions', () async {
        await repository.record(input: input(), result: result());

    final rows = await database.select(database.historyEntries).get();

    expect(rows, hasLength(1));
    expect(rows.single.gasolineConsumption, isNull);
    expect(rows.single.ethanolConsumption, isNull);

    final loaded = await repository.loadAll();
    expect(loaded.single.gasolineConsumption, isNull);
    expect(loaded.single.ethanolConsumption, isNull);
  });

  test('loadAll returns newest-first for sequentially inserted entries',
      () async {
    await repository.record(
      input: input(gasolinePrice: '4.00', ethanolPrice: '2.90'),
      result: result(ratio: Decimal.parse('0.72')),
    );
    await repository.record(
      input: input(gasolinePrice: '4.10', ethanolPrice: '3.00'),
      result: result(ratio: Decimal.parse('0.73')),
    );
    await repository.record(
      input: input(gasolinePrice: '4.20', ethanolPrice: '3.05'),
      result: result(ratio: Decimal.parse('0.74')),
    );

    final loaded = await repository.loadAll();

    expect(loaded.map((entry) => entry.gasolinePrice).toList(), [
      Decimal.parse('4.20'),
      Decimal.parse('4.10'),
      Decimal.parse('4.00'),
    ]);
    expect(loaded.first.id, greaterThan(loaded.last.id));
  });

  test('deleteById removes exactly one row and keeps others', () async {
    final first =
        await repository.record(input: input(), result: result());
    await repository.record(
      input: input(gasolinePrice: '5.00'),
      result: result(),
    );
    await repository.record(
      input: input(gasolinePrice: '6.00'),
      result: result(),
    );

    await repository.deleteById(first.id);

    final rows = await database.select(database.historyEntries).get();

    expect(rows, hasLength(2));
    expect(rows.map((row) => row.id), isNot(contains(first.id)));
    expect(
      await repository.loadAll(),
      hasLength(2),
    );
  });

  test("stored 'abc' ratio throws CalculationHistoryStorageException on load",
      () async {
    await database.insertHistoryEntry(
      HistoryEntriesCompanion.insert(
        createdAt: DateTime.utc(2026, 1, 1),
        gasolinePrice: '4.50',
        ethanolPrice: '3.10',
        recommendedFuel: 'ethanol',
        ratio: 'abc',
        appliedThreshold: '0.70',
        thresholdSource: 'standard',
        maximumEthanolPrice: '3.15',
        difference: '0.05',
      ),
    );

    expect(
      repository.loadAll,
      throwsA(isA<CalculationHistoryStorageException>()),
    );
  });

  test('unknown threshold_source text throws storage exception on load',
      () async {
    await database.insertHistoryEntry(
      HistoryEntriesCompanion.insert(
        createdAt: DateTime.utc(2026, 1, 1),
        gasolinePrice: '4.50',
        ethanolPrice: '3.10',
        recommendedFuel: 'ethanol',
        ratio: '0.70',
        appliedThreshold: '0.70',
        thresholdSource: 'weird',
        maximumEthanolPrice: '3.15',
        difference: '0.05',
      ),
    );

    expect(
      repository.loadAll,
      throwsA(isA<CalculationHistoryStorageException>()),
    );
  });
}
