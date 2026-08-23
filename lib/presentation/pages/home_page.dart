import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/preferences/app_preferences_controller.dart';
import '../../application/preferences/app_preferences_data.dart';
import '../../domain/fuel_calculation_input.dart';
import '../../domain/fuel_calculator.dart';
import '../../domain/fuel_calculation_result.dart';
import '../../domain/fuel_input_parser.dart';
import '../../domain/fuel_price.dart';
import '../../domain/fuel_type.dart';
import '../../domain/vehicle_efficiency.dart';
import '../release/app_release.dart';
import '../widgets/fuel_input_field.dart';
import '../widgets/result_view.dart';

enum ComparisonRule { standard, custom }

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final TextEditingController _gasolinePriceController =
      TextEditingController();
  final TextEditingController _ethanolPriceController =
      TextEditingController();
  final TextEditingController _gasolineConsumptionController =
      TextEditingController();
  final TextEditingController _ethanolConsumptionController =
      TextEditingController();

  ComparisonRule _rule = ComparisonRule.standard;
  String? _gasolinePriceError;
  String? _ethanolPriceError;
  String? _gasolineConsumptionError;
  String? _ethanolConsumptionError;
  FuelCalculationResult? _result;
  bool _isSubmitting = false;
  bool _welcomeDialogShown = false;

  @override
  void dispose() {
    _gasolinePriceController.dispose();
    _ethanolPriceController.dispose();
    _gasolineConsumptionController.dispose();
    _ethanolConsumptionController.dispose();
    super.dispose();
  }

  void _maybeShowWelcomeDialog() {
    final AsyncValue<AppPreferencesData> preferences =
        ref.watch(appPreferencesProvider);

    final AppPreferencesData? data = preferences.value;
    if (data == null || data.hasSeenWelcome || _welcomeDialogShown) {
      return;
    }

    _welcomeDialogShown = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _showWelcomeDialog();
    });
  }

  Future<void> _showWelcomeDialog() async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Bem-vindo ao Fuelwise'),
          content: const SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8,
              children: <Widget>[
                Text(
                  'Descubra qual combustível compensa mais abastecer hoje.',
                ),
                Text('1. Informe o preço do litro da gasolina e do etanol.'),
                Text(
                  '2. Opcionalmente, informe quantos km seu carro anda por litro com cada combustível.',
                ),
                Text(
                  '3. Toque em Calcular e veja a recomendação, os custos por km e até quanto o etanol pode custar para valer a pena.',
                ),
              ],
            ),
          ),
          actions: <Widget>[
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Entendi'),
            ),
          ],
        );
      },
    );

    await ref.read(appPreferencesProvider.notifier).markWelcomeSeen();
  }

  void _selectRule(Set<ComparisonRule> selection) {
    setState(() {
      _rule = selection.first;
    });
  }

  String _parserInput(TextEditingController controller) {
    return CurrencyInputFormatter.toParserInput(controller.text);
  }

  Future<void> _submit() async {
    if (_isSubmitting) {
      return;
    }

    final FuelInputParseResult gasolinePriceResult =
        parseRequiredPositiveDecimal(_parserInput(_gasolinePriceController));
    final FuelInputParseResult ethanolPriceResult =
        parseRequiredPositiveDecimal(_parserInput(_ethanolPriceController));
    final FuelInputParseResult gasolineConsumptionResult =
        parseOptionalPositiveDecimal(_gasolineConsumptionController.text);
    final FuelInputParseResult ethanolConsumptionResult =
        parseOptionalPositiveDecimal(_ethanolConsumptionController.text);

    final String? gasolinePriceError = _errorMessage(gasolinePriceResult);
    final String? ethanolPriceError = _errorMessage(ethanolPriceResult);
    final String? gasolineConsumptionError =
        _errorMessage(gasolineConsumptionResult);
    final String? ethanolConsumptionError =
        _errorMessage(ethanolConsumptionResult);

    if (gasolinePriceError != null ||
        ethanolPriceError != null ||
        gasolineConsumptionError != null ||
        ethanolConsumptionError != null) {
      setState(() {
        _gasolinePriceError = gasolinePriceError;
        _ethanolPriceError = ethanolPriceError;
        _gasolineConsumptionError = gasolineConsumptionError;
        _ethanolConsumptionError = ethanolConsumptionError;
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    await Future<void>.delayed(const Duration(milliseconds: 500));

    if (!mounted) {
      return;
    }

    setState(() {
      _isSubmitting = false;
      _gasolinePriceError = null;
      _ethanolPriceError = null;
      _gasolineConsumptionError = null;
      _ethanolConsumptionError = null;
      _result = const FuelCalculator().calculate(
        FuelCalculationInput(
          gasolinePrice: FuelPrice(
            type: FuelType.gasoline,
            value: _successValue(gasolinePriceResult)!,
          ),
          ethanolPrice: FuelPrice(
            type: FuelType.ethanol,
            value: _successValue(ethanolPriceResult)!,
          ),
          efficiency: _buildEfficiency(
            gasolineConsumptionResult,
            ethanolConsumptionResult,
          ),
          applyCustomThreshold: _rule == ComparisonRule.custom,
        ),
      );
    });
  }

  VehicleEfficiency? _buildEfficiency(
    FuelInputParseResult gasolineConsumptionResult,
    FuelInputParseResult ethanolConsumptionResult,
  ) {
    final Decimal? gasolineConsumption = _successValue(gasolineConsumptionResult);
    final Decimal? ethanolConsumption = _successValue(ethanolConsumptionResult);

    if (gasolineConsumption == null && ethanolConsumption == null) {
      return null;
    }

    return VehicleEfficiency(
      gasolineKmPerLiter: gasolineConsumption,
      ethanolKmPerLiter: ethanolConsumption,
    );
  }

  static String? _errorMessage(FuelInputParseResult parseResult) {
    return switch (parseResult) {
      FuelInputParseFailure(userMessage: final String message) => message,
      FuelInputParseSuccess() => null,
    };
  }

  static Decimal? _successValue(FuelInputParseResult parseResult) {
    return switch (parseResult) {
      FuelInputParseSuccess(value: final Decimal? value) => value,
      FuelInputParseFailure() => null,
    };
  }

  void _startNewCalculation() {
    setState(() {
      _gasolinePriceController.clear();
      _ethanolPriceController.clear();
      _gasolineConsumptionController.clear();
      _ethanolConsumptionController.clear();
      _rule = ComparisonRule.standard;
      _gasolinePriceError = null;
      _ethanolPriceError = null;
      _gasolineConsumptionError = null;
      _ethanolConsumptionError = null;
      _result = null;
    });
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 16,
            children: <Widget>[
              Card(
                elevation: 0,
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.local_gas_station,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Compare os preços e descubra qual combustível '
                          'rende mais para o seu bolso.',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              FuelInputField(
                label: 'Preço da gasolina',
                controller: _gasolinePriceController,
                errorText: _gasolinePriceError,
                prefixText: 'R\$ ',
                hintText: '6,29',
                useCurrencyMask: true,
              ),
              FuelInputField(
                label: 'Preço do etanol',
                controller: _ethanolPriceController,
                errorText: _ethanolPriceError,
                prefixText: 'R\$ ',
                hintText: '4,59',
                useCurrencyMask: true,
              ),
              FuelInputField(
                label: 'Consumo de gasolina',
                controller: _gasolineConsumptionController,
                errorText: _gasolineConsumptionError,
                suffixText: 'L',
                hintText: 'Ex: 10',
                helperText: 'Quantos km por litro na gasolina (opcional)',
              ),
              FuelInputField(
                label: 'Consumo de etanol',
                controller: _ethanolConsumptionController,
                errorText: _ethanolConsumptionError,
                suffixText: 'L',
                hintText: 'Ex: 7',
                helperText: 'Quantos km por litro no etanol (opcional)',
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 8,
                children: <Widget>[
                  SegmentedButton<ComparisonRule>(
                    segments: const <ButtonSegment<ComparisonRule>>[
                      ButtonSegment<ComparisonRule>(
                        value: ComparisonRule.standard,
                        label: Text('Padrão (0,70)'),
                      ),
                      ButtonSegment<ComparisonRule>(
                        value: ComparisonRule.custom,
                        icon: Icon(Icons.directions_car),
                        label: Text('Personalizada'),
                      ),
                    ],
                    selected: <ComparisonRule>{_rule},
                    onSelectionChanged: _selectRule,
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: _rule == ComparisonRule.custom
                        ? Text(
                            'O limiar será calculado pela divisão do consumo '
                            'do etanol pelo da gasolina informados acima.',
                            key: const ValueKey<String>('custom-helper'),
                            style: Theme.of(context).textTheme.bodySmall,
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
              FilledButton.icon(
                onPressed: _isSubmitting ? null : _submit,
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.calculate),
                label: Text(_isSubmitting ? 'Calculando...' : 'Calcular'),
              ),
              Center(
                child: Text(
                  AppRelease.label,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResult() {
    final FuelCalculationResult result = _result!;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(child: ResultView(result: result)),
            const SizedBox(height: 8),
            FilledButton.tonalIcon(
              onPressed: _startNewCalculation,
              icon: const Icon(Icons.refresh),
              label: const Text('Novo cálculo'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _maybeShowWelcomeDialog();
    final FuelCalculationResult? result = _result;
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: <Widget>[
            Icon(
              Icons.local_gas_station,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            const Text('Fuelwise'),
          ],
        ),
      ),
      body: result == null ? _buildForm() : _buildResult(),
    );
  }
}
