import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fuelwise/application/export/history_export_controller.dart';
import 'package:fuelwise/application/export/history_export_service.dart';
import 'package:fuelwise/domain/calculation_history_entry.dart';

final class _FakeExportService implements HistoryExportService {
  _FakeExportService({this.fail = false});

  final bool fail;
  List<CalculationHistoryEntry>? exportedEntries;
  String? exportedVehicleName;

  @override
  Future<String> exportCsv({
    required List<CalculationHistoryEntry> entries,
    required String? vehicleName,
  }) async {
    if (fail) {
      throw Exception('export failed');
    }
    exportedEntries = entries;
    exportedVehicleName = vehicleName;
    return '/tmp/fuelwise_export.csv';
  }
}

void main() {
  test('export transitions idle to exporting to ready with file path',
      () async {
    final _FakeExportService service = _FakeExportService();
    final ProviderContainer container = ProviderContainer(
      overrides: [historyExportServiceProvider.overrideWithValue(service)],
    );
    addTearDown(container.dispose);

    expect(container.read(historyExportProvider), isA<HistoryExportIdle>());

    final Future<void> exportingFuture =
        container.read(historyExportProvider.notifier).export(
              entries: const <CalculationHistoryEntry>[],
              vehicleName: 'Meu carro',
            );

    expect(container.read(historyExportProvider), isA<HistoryExporting>());

    await exportingFuture;

    final HistoryExportStatus state = container.read(historyExportProvider);
    expect(state, isA<HistoryExportReady>());
    expect((state as HistoryExportReady).filePath, '/tmp/fuelwise_export.csv');
    expect(service.exportedVehicleName, 'Meu carro');
  });

  test('export failure surfaces explicit failure state', () async {
    final _FakeExportService service = _FakeExportService(fail: true);
    final ProviderContainer container = ProviderContainer(
      overrides: [historyExportServiceProvider.overrideWithValue(service)],
    );
    addTearDown(container.dispose);

    await container.read(historyExportProvider.notifier).export(
          entries: const <CalculationHistoryEntry>[],
          vehicleName: null,
        );

    final HistoryExportStatus state = container.read(historyExportProvider);
    expect(state, isA<HistoryExportFailure>());
    expect((state as HistoryExportFailure).message,
        'Não foi possível exportar o histórico.');
  });

  test('reset returns to idle', () async {
    final ProviderContainer container = ProviderContainer(
      overrides: [
        historyExportServiceProvider.overrideWithValue(_FakeExportService()),
      ],
    );
    addTearDown(container.dispose);

    await container.read(historyExportProvider.notifier).export(
          entries: const <CalculationHistoryEntry>[],
          vehicleName: null,
        );

    await container.read(historyExportProvider.notifier).reset();

    expect(container.read(historyExportProvider), isA<HistoryExportIdle>());
  });
}