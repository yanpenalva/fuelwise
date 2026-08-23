import 'package:fuelwise/domain/calculation_history_entry.dart';
import 'package:fuelwise/domain/fuel_calculation_input.dart';
import 'package:fuelwise/domain/fuel_calculation_result.dart';

abstract interface class CalculationHistoryRepository {
  Future<List<CalculationHistoryEntry>> loadAll();

  Future<CalculationHistoryEntry> record({
    required FuelCalculationInput input,
    required FuelCalculationResult result,
  });

  Future<void> deleteById(int id);
}
