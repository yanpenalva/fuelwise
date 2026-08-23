import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/calculation_history_entry.dart';
import 'history_export_service.dart';

sealed class HistoryExportStatus {
  const HistoryExportStatus();
}

final class HistoryExportIdle extends HistoryExportStatus {
  const HistoryExportIdle();
}

final class HistoryExporting extends HistoryExportStatus {
  const HistoryExporting({required this.exportId});

  final int exportId;
}

final class HistoryExportReady extends HistoryExportStatus {
  const HistoryExportReady({required this.exportId, required this.filePath});

  final int exportId;
  final String filePath;
}

final class HistoryExportFailure extends HistoryExportStatus {
  const HistoryExportFailure({required this.exportId, required this.message});

  final int exportId;
  final String message;
}

final Provider<HistoryExportService> historyExportServiceProvider =
    Provider<HistoryExportService>((Ref ref) => throw UnimplementedError());

final NotifierProvider<HistoryExportController, HistoryExportStatus>
historyExportProvider =
    NotifierProvider<HistoryExportController, HistoryExportStatus>(
      HistoryExportController.new,
    );

class HistoryExportController extends Notifier<HistoryExportStatus> {
  int _nextExportId = 1;

  @override
  HistoryExportStatus build() {
    return const HistoryExportIdle();
  }

  Future<void> export({
    required List<CalculationHistoryEntry> entries,
    required String? vehicleName,
  }) async {
    if (state is HistoryExporting) {
      return;
    }

    final int exportId = _nextExportId++;
    state = HistoryExporting(exportId: exportId);

    try {
      final HistoryExportService service = ref.read(
        historyExportServiceProvider,
      );
      final String filePath = await service.exportCsv(
        entries: entries,
        vehicleName: vehicleName,
      );
      state = HistoryExportReady(exportId: exportId, filePath: filePath);
    } catch (_) {
      state = HistoryExportFailure(
        exportId: exportId,
        message: 'Não foi possível exportar o histórico.',
      );
    }
  }

  Future<void> reset() async {
    state = const HistoryExportIdle();
  }
}
