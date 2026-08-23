import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fuelwise/domain/calculation_history_entry.dart';
import 'package:fuelwise/domain/fuel_type.dart';
import 'package:fuelwise/domain/threshold_source.dart';
import 'package:fuelwise/infrastructure/export/csv_history_exporter.dart';

CalculationHistoryEntry _entry({
  required int id,
  DateTime? createdAt,
  Decimal? gasolinePrice,
  Decimal? ethanolPrice,
  Decimal? gasolineConsumption,
  FuelType recommendedFuel = FuelType.ethanol,
  Decimal? ratio,
  Decimal? appliedThreshold,
  ThresholdSource thresholdSource = ThresholdSource.standard,
}) {
  return CalculationHistoryEntry(
    id: id,
    createdAt: createdAt ?? DateTime(2026, 8, 20, 14, 30),
    gasolinePrice: gasolinePrice ?? Decimal.parse('6.29'),
    ethanolPrice: ethanolPrice ?? Decimal.parse('4.39'),
    gasolineConsumption: gasolineConsumption,
    ethanolConsumption: null,
    recommendedFuel: recommendedFuel,
    ratio: ratio ?? Decimal.parse('0.69'),
    appliedThreshold: appliedThreshold ?? Decimal.parse('0.70'),
    thresholdSource: thresholdSource,
    gasolineCostPerKilometer: Decimal.parse('0.599'),
    ethanolCostPerKilometer: null,
    maximumEthanolPrice: Decimal.parse('4.40'),
    difference: Decimal.parse('0.01'),
  );
}

void main() {
  test('builds header row with useful columns only', () {
    const CsvHistoryJob job = CsvHistoryJob(
      entries: <CalculationHistoryEntry>[],
      vehicleName: null,
    );

    final String csv = buildHistoryCsv(job);
    final List<String> lines = csv.trim().split('\n');

    expect(lines.length, 1);
    expect(lines.first, contains('Data;Recomendação'));
    expect(lines.first, contains('Preço gasolina'));
    expect(lines.first, contains('Preço etanol'));
    expect(lines.first, contains('Consumo gasolina'));
    expect(lines.first, contains('Proporção'));
    expect(lines.first, contains('Limiar'));
  });

  test('writes vehicle context line when name provided', () {
    final String csv = buildHistoryCsv(
      const CsvHistoryJob(
        entries: <CalculationHistoryEntry>[],
        vehicleName: 'Meu carro',
      ),
    );

    expect(csv, contains('Veículo;Meu carro'));
  });

  test('formats pt-BR decimals with comma separators', () {
    final String csv = buildHistoryCsv(
      CsvHistoryJob(
        entries: <CalculationHistoryEntry>[_entry(id: 1)],
        vehicleName: null,
      ),
    );
    final List<String> lines = csv.trim().split('\n');

    expect(lines.length, 2);
    expect(lines[0], contains('Data;Recomendação'));
    expect(lines[1], contains('Abasteça com etanol'));
    expect(lines[1], contains('6,29'));
    expect(lines[1], contains('4,39'));
    expect(lines[1], contains('0,69'));
    expect(lines[1], contains('0,7'));
    expect(lines[1], contains('Padrão'));
    expect(lines[1], contains('20/08/2026 14:30'));
  });

  test('leaves optional absent consumptions empty', () {
    final String csv = buildHistoryCsv(
      CsvHistoryJob(
        entries: <CalculationHistoryEntry>[
          _entry(id: 1, gasolineConsumption: Decimal.parse('10.5')),
        ],
        vehicleName: null,
      ),
    );
    final List<String> fields = csv.trim().split('\n').last.split(';');

    expect(fields[4], '10,5');
    expect(fields[5], isEmpty);
    expect(fields[9], '0,599');
    expect(fields[10], isEmpty);
  });
}
