import 'dart:io';

import 'package:flutter/foundation.dart';

import 'package:fuelwise/application/export/history_export_service.dart';
import 'package:fuelwise/domain/calculation_history_entry.dart';

import 'csv_history_exporter.dart';

final class DartHistoryExportService implements HistoryExportService {
  @override
  Future<String> exportCsv({
    required List<CalculationHistoryEntry> entries,
    required String? vehicleName,
  }) async {
    final String csv = await compute(
      buildHistoryCsv,
      CsvHistoryJob(entries: entries, vehicleName: vehicleName),
    );
    final Directory directory = await Directory.systemTemp.createTemp(
      'fuelwise',
    );
    final DateTime now = DateTime.now();
    final String stamp =
        '${now.year}${_pad(now.month)}${_pad(now.day)}_'
        '${_pad(now.hour)}${_pad(now.minute)}${_pad(now.second)}';
    final File file = File('${directory.path}/fuelwise_historico_$stamp.csv');
    await file.writeAsString('\uFEFF$csv', flush: true);

    return file.path;
  }

  static String _pad(int digit) {
    return digit < 10 ? '0$digit' : '$digit';
  }
}
