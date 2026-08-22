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
                    _formatRatio(result.ratio),
                  ),
                  _metricTile(
                    'Limiar aplicado',
                    _formatRatio(result.appliedThreshold),
                  ),
                  _metricTile(
                    'Fonte da regra',
                    _thresholdLabel(result.thresholdSource),
                  ),
                  _metricTile(
                    'Diferença',
                    _formatRatio(result.difference),
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
                  ),
                  _costPerKmTile(
                    'Custo por km — etanol',
                    result.ethanolCostPerKilometer,
                  ),
                  _metricTile(
                    'Preço máximo recomendado do etanol',
                    'R\$ ${_formatMoney(result.maximumEthanolPrice)}',
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
        'R\$ ${_formatMoney(costPerKilometer)}',
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }

  String _formatMoney(Decimal value) {
    return _formatScaled(value, 2);
  }

  String _formatRatio(Decimal value) {
    return _formatScaled(value, 3);
  }

  String _formatScaled(Decimal value, int scale) {
    final bool isNegative = value < Decimal.zero;
    final Decimal absolute = isNegative ? -value : value;
    final BigInt smallestUnits =
        (absolute * Decimal.fromInt(_pow10(scale))).round().toBigInt();
    final String digits = smallestUnits.toString().padLeft(scale + 1, '0');
    final String intPart = digits.substring(0, digits.length - scale);
    final String fracPart = digits.substring(digits.length - scale);
    final NumberFormat integerFormat = NumberFormat('#,##0', 'pt_BR');
    final String sign = isNegative ? '-' : '';

    return '$sign${integerFormat.format(int.parse(intPart))},$fracPart';
  }

  static int _pow10(int exponent) {
    var result = 1;

    for (var i = 0; i < exponent; i++) {
      result *= 10;
    }

    return result;
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
