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
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 16,
          children: <Widget>[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[
                    _recommendationColor(result.recommendedFuel),
                    Color.lerp(
                      _recommendationColor(result.recommendedFuel),
                      Colors.black,
                      0.25,
                    )!,
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color:
                        _recommendationColor(result.recommendedFuel).withAlpha(70),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: <Widget>[
                  Icon(
                    result.recommendedFuel == FuelType.ethanol
                        ? Icons.eco
                        : Icons.local_gas_station,
                    color: Colors.white,
                    size: 40,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _fuelName(result.recommendedFuel),
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white70,
                      letterSpacing: 2,
                    ),
                  ),
                  Text(
                    _recommendationText(result.recommendedFuel),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: Text(
                      'Comparação',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _metricTile(
                    icon: Icons.percent,
                    label: 'Proporção etanol/gasolina',
                    value: _formatRatio(result.ratio),
                  ),
                  _metricTile(
                    icon: Icons.rule,
                    label: 'Limiar aplicado',
                    value: _formatRatio(result.appliedThreshold),
                  ),
                  _metricTile(
                    icon: Icons.source_outlined,
                    label: 'Fonte da regra',
                    value: _thresholdLabel(result.thresholdSource),
                  ),
                  _metricTile(
                    icon: result.difference >= Decimal.zero
                        ? Icons.trending_up
                        : Icons.trending_down,
                    label: 'Diferença',
                    value: _formatRatio(result.difference),
                    valueColor: _differenceColor(context, result.difference),
                  ),
                ],
              ),
            ),
            Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: Text(
                      'Custos',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _costPerKmTile(
                    label: 'Custo por km — gasolina',
                    costPerKilometer: result.gasolineCostPerKilometer,
                  ),
                  _costPerKmTile(
                    label: 'Custo por km — etanol',
                    costPerKilometer: result.ethanolCostPerKilometer,
                  ),
                ],
              ),
            ),
            Card(
              elevation: 0,
              color: colorScheme.secondaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Icon(Icons.lightbulb_outline, color: colorScheme.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Com o preço atual da gasolina, o etanol compensa '
                        'até R\$ ${_formatMoney(result.maximumEthanolPrice)} '
                        'por litro.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _metricTile({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      subtitle: Text(
        value,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
          color: valueColor,
        ),
      ),
    );
  }

  Widget _costPerKmTile({
    required String label,
    required Decimal? costPerKilometer,
  }) {
    if (costPerKilometer == null) {
      return ListTile(
        leading: const Icon(Icons.info_outline),
        title: Text(label),
        subtitle: const Text('Indisponível — informe os dois consumos'),
      );
    }

    return ListTile(
      leading: const Icon(Icons.savings_outlined),
      title: Text(label),
      subtitle: Text(
        'R\$ ${_formatMoney(costPerKilometer)}',
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
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

  String _fuelName(FuelType fuel) {
    return switch (fuel) {
      FuelType.ethanol => 'ETANOL',
      FuelType.gasoline => 'GASOLINA',
    };
  }

  Color _differenceColor(BuildContext context, Decimal difference) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    if (difference >= Decimal.zero) {
      return isDark ? Colors.green.shade400 : Colors.green.shade700;
    }

    return isDark ? Colors.deepOrange.shade300 : Colors.deepOrange.shade700;
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
