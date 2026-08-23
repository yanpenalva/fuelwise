import 'package:decimal/decimal.dart';

import 'package:fuelwise/domain/calculation_history_entry.dart';
import 'package:fuelwise/domain/fuel_type.dart';
import 'package:fuelwise/domain/threshold_source.dart';

final class CsvHistoryJob {
  const CsvHistoryJob({required this.entries, required this.vehicleName});

  final List<CalculationHistoryEntry> entries;
  final String? vehicleName;
}

String buildHistoryCsv(CsvHistoryJob job) {
  final StringBuffer buffer = StringBuffer(
    'Data;Recomendação;'
    'Preço gasolina (R\$/L);Preço etanol (R\$/L);'
    'Consumo gasolina (km/L);Consumo etanol (km/L);'
    'Proporção;Limiar;Fonte do limiar;'
    'Custo/km gasolina (R\$);Custo/km etanol (R\$);'
    'Etanol máximo (R\$/L);Diferença (R\$)\n',
  );

  if (job.vehicleName != null && job.vehicleName!.trim().isNotEmpty) {
    buffer.writeln('Veículo;${_cell(job.vehicleName!)}');
  }

  for (final CalculationHistoryEntry entry in job.entries) {
    final DateTime local = entry.createdAt.toLocal();
    final String date =
        '${_pad(local.day)}/${_pad(local.month)}/'
        '${local.year} ${_pad(local.hour)}:${_pad(local.minute)}';

    buffer.writeln(
      '${_cell(date)};'
      '${_cell(_recommendationLabel(entry.recommendedFuel))};'
      '${_decimal(entry.gasolinePrice)};${_decimal(entry.ethanolPrice)};'
      '${_optional(entry.gasolineConsumption)};'
      '${_optional(entry.ethanolConsumption)};'
      '${_decimal(entry.ratio)};${_decimal(entry.appliedThreshold)};'
      '${_cell(_thresholdLabel(entry.thresholdSource))};'
      '${_optional(entry.gasolineCostPerKilometer)};'
      '${_optional(entry.ethanolCostPerKilometer)};'
      '${_decimal(entry.maximumEthanolPrice)};'
      '${_decimal(entry.difference)}',
    );
  }

  return buffer.toString();
}

String _recommendationLabel(FuelType type) {
  return switch (type) {
    FuelType.ethanol => 'Abasteça com etanol',
    FuelType.gasoline => 'Abasteça com gasolina',
  };
}

String _thresholdLabel(ThresholdSource source) {
  return switch (source) {
    ThresholdSource.standard => 'Padrão',
    ThresholdSource.custom => 'Personalizada',
  };
}

String _optional(Decimal? value) {
  return value == null ? '' : _decimal(value);
}

String _decimal(Decimal value) {
  return value.toString().replaceAll('.', ',');
}

String _cell(String value) {
  final String escaped = value.replaceAll('"', '""');

  if (escaped.contains(';') ||
      escaped.contains('"') ||
      escaped.contains('\n')) {
    return '"$escaped"';
  }

  return escaped;
}

String _pad(int digit) {
  return digit < 10 ? '0$digit' : '$digit';
}
