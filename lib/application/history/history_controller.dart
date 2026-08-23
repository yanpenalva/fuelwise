import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/calculation_history_entry.dart';
import '../../domain/fuel_calculation_input.dart';
import '../../domain/fuel_calculation_result.dart';
import 'calculation_history_repository.dart';

final Provider<CalculationHistoryRepository> calculationHistoryRepositoryProvider =
    Provider<CalculationHistoryRepository>(
  (Ref ref) => throw UnimplementedError(),
);

final AsyncNotifierProvider<HistoryController, List<CalculationHistoryEntry>>
    historyProvider =
    AsyncNotifierProvider<HistoryController, List<CalculationHistoryEntry>>(
  HistoryController.new,
);

class HistoryController extends AsyncNotifier<List<CalculationHistoryEntry>> {
  static const int maxHistoryEntries = 500;

  @override
  Future<List<CalculationHistoryEntry>> build() async {
    return ref.read(calculationHistoryRepositoryProvider).loadAll();
  }

  Future<void> record({
    required FuelCalculationInput input,
    required FuelCalculationResult result,
  }) async {
    final CalculationHistoryRepository repository =
        ref.read(calculationHistoryRepositoryProvider);
    final CalculationHistoryEntry entry =
        await repository.record(input: input, result: result);
    final List<CalculationHistoryEntry>? current = state.value;

    if (current == null) {
      state = AsyncData(await repository.loadAll());
      return;
    }

    final List<CalculationHistoryEntry> updated = [entry, ...current];

    if (updated.length > maxHistoryEntries) {
      final List<CalculationHistoryEntry> evicted =
          updated.sublist(maxHistoryEntries);
      for (final CalculationHistoryEntry old in evicted) {
        await repository.deleteById(old.id);
      }
      updated.removeRange(maxHistoryEntries, updated.length);
    }

    state = AsyncData(updated);
  }

  Future<void> deleteById(int id) async {
    final CalculationHistoryRepository repository =
        ref.read(calculationHistoryRepositoryProvider);
    await repository.deleteById(id);
    final List<CalculationHistoryEntry>? current = state.value;
    if (current == null) {
      return;
    }

    state = AsyncData(
      current.where((CalculationHistoryEntry entry) => entry.id != id).toList(),
    );
  }
}
