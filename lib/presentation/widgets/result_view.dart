import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/fuel_calculation_result.dart';
import '../../domain/fuel_type.dart';
import '../../domain/threshold_source.dart';

class ResultView extends StatelessWidget {
  final FuelCalculationResult result;

  const ResultView({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final NumberFormat moneyFormat = NumberFormat('#,##0.00', 'pt_BR');
    final NumberFormat ratioFormat = NumberFormat('#,##0.000', 'pt_BR');

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              decoration: BoxDecoration(
                color: _recommendationColor(result.recommendedFuel),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _recommendationText(result.recommendedFuel),
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Column(
                children: <Widget>[
                  _metricTile(
                    'Proporção etanol/gasolina',
                    ratioFormat.format(result.ratio.toDouble()),
                  ),
                  _metricTile(
                    'Limiar aplicado',
                    ratioFormat.format(result.appliedThreshold.toDouble()),
                  ),
                  _metricTile(
                    'Fonte da regra',
                    _thresholdLabel(result.thresholdSource),
                  ),
                  _metricTile(
                    'Diferença',
                    ratioFormat.format(result.difference.toDouble()),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Column(
                children: <Widget>[
                  _costPerKmTile(
                    'Custo por km — gasolina',
                    result.gasolineCostPerKilometer,
                    moneyFormat,
                  ),
                  _costPerKmTile(
                    'Custo por km — etanol',
                    result.ethanolCostPerKilometer,
                    moneyFormat,
                  ),
                  _metricTile(
                    'Preço máximo recomendado do etanol',
                    'R\$ ${moneyFormat.format(result.maximumEthanolPrice.toDouble())}',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _metricTile(String label, String value) {
    return ListTile(
      title: Text(label),
      subtitle: Text(
        value,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _costPerKmTile(
    String label,
    Decimal? costPerKilometer,
    NumberFormat moneyFormat,
  ) {
    if (costPerKilometer == null) {
      return ListTile(
        title: Text(label),
        subtitle: const Text('Indisponível — informe os dois consumos'),
      );
    }

    return ListTile(
      title: Text(label),
      subtitle: Text(
        'R\$ ${moneyFormat.format(costPerKilometer.toDouble())}',
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }

  String _recommendationText(FuelType fuel) {
    return switch (fuel) {
      FuelType.ethanol => 'Abasteça com etanol',
      FuelType.gasoline => 'Abasteça com gasolina',
    };
  }

  Color _recommendationColor(FuelType fuel) {
    return switch (fuel) {
      FuelType.ethanol => Colors.green.shade700,
      FuelType.gasoline => Colors.deepOrange.shade700,
    };
  }

  String _thresholdLabel(ThresholdSource source) {
    return switch (source) {
      ThresholdSource.standard => 'Limiar padrão (0,70)',
      ThresholdSource.custom => 'Limiar personalizado (consumo)',
    };
  }
}
