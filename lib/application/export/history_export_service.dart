import '../../domain/calculation_history_entry.dart';

abstract interface class HistoryExportService {
  Future<String> exportCsv({
    required List<CalculationHistoryEntry> entries,
    required String? vehicleName,
  });
}