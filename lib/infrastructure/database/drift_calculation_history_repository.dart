import 'package:drift/drift.dart' show Value;

import 'package:fuelwise/application/history/calculation_history_repository.dart';
import 'package:fuelwise/domain/calculation_history_entry.dart';
import 'package:fuelwise/domain/fuel_calculation_input.dart';
import 'package:fuelwise/domain/fuel_calculation_result.dart';
import 'package:fuelwise/infrastructure/database/app_database.dart';
import 'package:fuelwise/infrastructure/database/calculation_history_mapper.dart';

final class DriftCalculationHistoryRepository
    implements CalculationHistoryRepository {
  final AppDatabase _database;
  final CalculationHistoryMapper _mapper;

  DriftCalculationHistoryRepository(this._database)
      : _mapper = const CalculationHistoryMapper();

  @override
  Future<List<CalculationHistoryEntry>> loadAll() async {
    final rows = await _database.getAllHistoryEntries();

    return [for (final row in rows) _mapper.toDomain(row)];
  }

  @override
  Future<CalculationHistoryEntry> record({
    required FuelCalculationInput input,
    required FuelCalculationResult result,
  }) async {
    final stored = await _database.insertHistoryEntry(
      HistoryEntriesCompanion.insert(
        createdAt: DateTime.now().toUtc(),
        gasolinePrice: input.gasolinePrice.value.toString(),
        ethanolPrice: input.ethanolPrice.value.toString(),
        gasolineConsumption:
            Value(input.efficiency?.gasolineKmPerLiter?.toString()),
        ethanolConsumption:
            Value(input.efficiency?.ethanolKmPerLiter?.toString()),
        recommendedFuel: result.recommendedFuel.name,
        ratio: result.ratio.toString(),
        appliedThreshold: result.appliedThreshold.toString(),
        thresholdSource: result.thresholdSource.name,
        gasolineCostPerKm:
            Value(result.gasolineCostPerKilometer?.toString()),
        ethanolCostPerKm:
            Value(result.ethanolCostPerKilometer?.toString()),
        maximumEthanolPrice: result.maximumEthanolPrice.toString(),
        difference: result.difference.toString(),
      ),
    );

    return _mapper.toDomain(stored);
  }

  @override
  Future<void> deleteById(int id) async {
    await _database.deleteHistoryEntry(id);
  }
}
