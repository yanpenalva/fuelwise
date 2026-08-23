import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fuelwise/application/comparison/comparison_form_controller.dart';
import 'package:fuelwise/application/comparison/comparison_form_state.dart';
import 'package:fuelwise/application/history/calculation_history_repository.dart';
import 'package:fuelwise/application/history/history_controller.dart';
import 'package:fuelwise/domain/calculation_history_entry.dart';
import 'package:fuelwise/domain/fuel_calculation_input.dart';
import 'package:fuelwise/domain/fuel_calculation_result.dart';

void main() {
  late _RecordingHistoryRepository history;
  late ProviderContainer container;

  setUp(() {
    history = _RecordingHistoryRepository();
    container = ProviderContainer(
      overrides: [
        calculationHistoryRepositoryProvider.overrideWithValue(history),
      ],
    );
    addTearDown(container.dispose);
  });

  ComparisonFormState state() => container.read(comparisonFormProvider);

  test('records exactly one entry per valid submission', () async {
    await container
        .read(comparisonFormProvider.notifier)
        .submit(
          gasolinePriceText: '6,00',
          ethanolPriceText: '4,19',
          gasolineConsumptionText: '',
          ethanolConsumptionText: '',
        );

    expect(state().result, isNotNull);
    expect(state().historySave, isA<HistorySaveSuccess>());
    expect(history.recordedCount, 1);
  });

  test('does not record when validation fails', () async {
    await container
        .read(comparisonFormProvider.notifier)
        .submit(
          gasolinePriceText: 'abc',
          ethanolPriceText: '4,19',
          gasolineConsumptionText: '',
          ethanolConsumptionText: '',
        );

    expect(state().gasolinePriceError, isNotNull);
    expect(state().result, isNull);
    expect(history.recordedCount, 0);
  });

  test(
    'reports failure status without throwing when repository fails',
    () async {
      history.failNext = true;
      await container
          .read(comparisonFormProvider.notifier)
          .submit(
            gasolinePriceText: '6,00',
            ethanolPriceText: '4,19',
            gasolineConsumptionText: '',
            ethanolConsumptionText: '',
          );

      expect(state().result, isNotNull);
      final HistorySaveStatus status = state().historySave;
      expect(status, isA<HistorySaveFailure>());
      expect((status as HistorySaveFailure).message, isNotEmpty);
    },
  );

  test('reset clears result and errors', () async {
    await container
        .read(comparisonFormProvider.notifier)
        .submit(
          gasolinePriceText: '6,00',
          ethanolPriceText: '4,19',
          gasolineConsumptionText: '',
          ethanolConsumptionText: '',
        );

    container.read(comparisonFormProvider.notifier).reset();

    expect(state().result, isNull);
    expect(state().historySave, isA<HistorySaveIdle>());
    expect(state().gasolinePriceError, isNull);
  });

  test('sequential valid submissions each record one entry', () async {
    final ComparisonFormController controller = container.read(
      comparisonFormProvider.notifier,
    );
    await controller.submit(
      gasolinePriceText: '6,00',
      ethanolPriceText: '4,19',
      gasolineConsumptionText: '',
      ethanolConsumptionText: '',
    );
    controller.reset();
    await controller.submit(
      gasolinePriceText: '5,50',
      ethanolPriceText: '3,90',
      gasolineConsumptionText: '',
      ethanolConsumptionText: '',
    );

    expect(history.recordedCount, 2);
  });
}

final class _RecordingHistoryRepository
    implements CalculationHistoryRepository {
  int recordedCount = 0;
  bool failNext = false;

  @override
  Future<List<CalculationHistoryEntry>> loadAll() async => const [];

  @override
  Future<CalculationHistoryEntry> record({
    required FuelCalculationInput input,
    required FuelCalculationResult result,
  }) async {
    if (failNext) {
      failNext = false;
      throw Exception('storage unavailable');
    }
    recordedCount++;
    return CalculationHistoryEntry(
      id: recordedCount,
      createdAt: DateTime.now().toUtc(),
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
  }

  @override
  Future<void> deleteById(int id) async {}
}
