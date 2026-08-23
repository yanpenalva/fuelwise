import 'package:decimal/decimal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fuelwise/application/history/calculation_history_repository.dart';
import 'package:fuelwise/application/history/history_controller.dart';
import 'package:fuelwise/domain/calculation_history_entry.dart';
import 'package:fuelwise/domain/fuel_calculation_input.dart';
import 'package:fuelwise/domain/fuel_calculation_result.dart';
import 'package:fuelwise/domain/fuel_price.dart';
import 'package:fuelwise/domain/fuel_type.dart';
import 'package:fuelwise/domain/threshold_source.dart';

final class _InMemoryCalculationHistory implements CalculationHistoryRepository {
  final List<CalculationHistoryEntry> _entries;
  int _nextId;

  _InMemoryCalculationHistory([List<CalculationHistoryEntry>? initial])
      : _entries = List<CalculationHistoryEntry>.from(initial ?? const <CalculationHistoryEntry>[]),
        _nextId = (initial ?? const <CalculationHistoryEntry>[])
                .fold<int>(0, (int max, CalculationHistoryEntry e) => e.id > max ? e.id : max) +
            1;

  List<CalculationHistoryEntry> get stored => _entries.toList()
    ..sort(
      (CalculationHistoryEntry a, CalculationHistoryEntry b) =>
          b.createdAt.compareTo(a.createdAt),
    );

  @override
  Future<List<CalculationHistoryEntry>> loadAll() async => stored;

  @override
  Future<CalculationHistoryEntry> record({
    required FuelCalculationInput input,
    required FuelCalculationResult result,
  }) async {
    final CalculationHistoryEntry entry = CalculationHistoryEntry(
      id: _nextId++,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        1000 * _nextId,
        isUtc: true,
      ),
      gasolinePrice: input.gasolinePrice.value,
      ethanolPrice: input.ethanolPrice.value,
      gasolineConsumption: input.efficiency?.gasolineKmPerLiter,
      ethanolConsumption: input.efficiency?.ethanolKmPerLiter,
      recommendedFuel: result.recommendedFuel,
      ratio: result.ratio,
      appliedThreshold: result.appliedThreshold,
      thresholdSource: result.thresholdSource,
      gasolineCostPerKilometer: result.gasolineCostPerKilometer,
      ethanolCostPerKilometer: result.ethanolCostPerKilometer,
      maximumEthanolPrice: result.maximumEthanolPrice,
      difference: result.difference,
    );
    _entries.add(entry);
    return entry;
  }

  @override
  Future<void> deleteById(int id) async {
    _entries.removeWhere((CalculationHistoryEntry entry) => entry.id == id);
  }
}

final class _ThrowingCalculationHistory implements CalculationHistoryRepository {
  @override
  Future<List<CalculationHistoryEntry>> loadAll() async =>
      throw Exception('load failed');

  @override
  Future<CalculationHistoryEntry> record({
    required FuelCalculationInput input,
    required FuelCalculationResult result,
  }) async =>
      throw Exception('record failed');

  @override
  Future<void> deleteById(int id) async {}
}

CalculationHistoryEntry _entry(int id, DateTime createdAt) =>
    CalculationHistoryEntry(
      id: id,
      createdAt: createdAt,
      gasolinePrice: Decimal.parse('4.00'),
      ethanolPrice: Decimal.parse('3.00'),
      gasolineConsumption: null,
      ethanolConsumption: null,
      recommendedFuel: FuelType.ethanol,
      ratio: Decimal.parse('0.75'),
      appliedThreshold: Decimal.parse('0.70'),
      thresholdSource: ThresholdSource.standard,
      gasolineCostPerKilometer: null,
      ethanolCostPerKilometer: null,
      maximumEthanolPrice: Decimal.parse('2.80'),
      difference: Decimal.parse('-0.20'),
    );

FuelCalculationInput _input() => FuelCalculationInput(
      gasolinePrice: FuelPrice(type: FuelType.gasoline, value: Decimal.parse('4.00')),
      ethanolPrice: FuelPrice(type: FuelType.ethanol, value: Decimal.parse('3.00')),
    );

FuelCalculationResult _result() => FuelCalculationResult(
      recommendedFuel: FuelType.ethanol,
      ratio: Decimal.parse('0.75'),
      appliedThreshold: Decimal.parse('0.70'),
      thresholdSource: ThresholdSource.standard,
      gasolineCostPerKilometer: null,
      ethanolCostPerKilometer: null,
      maximumEthanolPrice: Decimal.parse('2.80'),
      difference: Decimal.parse('-0.20'),
    );

void main() {
  test('initial build loads entries newest first', () async {
    final _InMemoryCalculationHistory repository =
        _InMemoryCalculationHistory(<CalculationHistoryEntry>[
      _entry(1, DateTime.fromMillisecondsSinceEpoch(1000, isUtc: true)),
      _entry(2, DateTime.fromMillisecondsSinceEpoch(2000, isUtc: true)),
    ]);
    final ProviderContainer container = ProviderContainer(
      overrides: [
        calculationHistoryRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);

    final List<CalculationHistoryEntry> entries =
        await container.read(historyProvider.future);

    expect(entries.map((CalculationHistoryEntry e) => e.id), [2, 1]);
  });

  test('record prepends entry and persists exactly one new entry per call',
      () async {
    final _InMemoryCalculationHistory repository = _InMemoryCalculationHistory();
    final ProviderContainer container = ProviderContainer(
      overrides: [
        calculationHistoryRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);
    await container.read(historyProvider.future);
    final HistoryController controller =
        container.read(historyProvider.notifier);

    await controller.record(input: _input(), result: _result());

    expect(container.read(historyProvider).requireValue.length, 1);
    expect(repository.stored.length, 1);

    await controller.record(input: _input(), result: _result());

    final List<CalculationHistoryEntry> state =
        container.read(historyProvider).requireValue;
    expect(state.length, 2);
    expect(state.first.id, greaterThan(state.last.id));
    expect(repository.stored.length, 2);
  });

  test('deleteById removes only that entry from state', () async {
    final _InMemoryCalculationHistory repository =
        _InMemoryCalculationHistory(<CalculationHistoryEntry>[
      _entry(1, DateTime.fromMillisecondsSinceEpoch(1000, isUtc: true)),
      _entry(2, DateTime.fromMillisecondsSinceEpoch(2000, isUtc: true)),
      _entry(3, DateTime.fromMillisecondsSinceEpoch(3000, isUtc: true)),
    ]);
    final ProviderContainer container = ProviderContainer(
      overrides: [
        calculationHistoryRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);
    await container.read(historyProvider.future);
    final HistoryController controller =
        container.read(historyProvider.notifier);

    await controller.deleteById(2);

    final List<CalculationHistoryEntry> state =
        container.read(historyProvider).requireValue;
    expect(state.map((CalculationHistoryEntry e) => e.id), unorderedEquals([1, 3]));
    expect(repository.stored.map((CalculationHistoryEntry e) => e.id),
        unorderedEquals([1, 3]));
  });

  test('repository failure during build yields async error', () async {
    final ProviderContainer container = ProviderContainer(
      overrides: [
        calculationHistoryRepositoryProvider
            .overrideWithValue(_ThrowingCalculationHistory()),
      ],
    );
    addTearDown(container.dispose);

    container.read(historyProvider);
    await Future<void>.delayed(Duration.zero);

    final AsyncValue<List<CalculationHistoryEntry>> state =
        container.read(historyProvider);
    expect(state.hasError, isTrue);
    expect(state.error, isException);
  });

  test('keeps entries within the cap and evicts the oldest on record',
      () async {
    final _InMemoryCalculationHistory repository =
        _InMemoryCalculationHistory(<CalculationHistoryEntry>[
      for (var id = 1; id <= HistoryController.maxHistoryEntries; id++)
        _entry(
          id,
          DateTime.fromMillisecondsSinceEpoch(1000 * id, isUtc: true),
        ),
    ]);
    final ProviderContainer container = ProviderContainer(
      overrides: [
        calculationHistoryRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);
    await container.read(historyProvider.future);
    final HistoryController controller =
        container.read(historyProvider.notifier);

    await controller.record(input: _input(), result: _result());

    final List<CalculationHistoryEntry> state =
        container.read(historyProvider).requireValue;
    expect(state.length, HistoryController.maxHistoryEntries);
    expect(
      state.first.id,
      HistoryController.maxHistoryEntries + 1,
    );
    expect(
      repository.stored.any(
        (CalculationHistoryEntry entry) => entry.id == 1,
      ),
      isFalse,
    );
  });
}
