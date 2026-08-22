import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';

import '../../domain/fuel_calculation_input.dart';
import '../../domain/fuel_calculator.dart';
import '../../domain/fuel_calculation_result.dart';
import '../../domain/fuel_input_parser.dart';
import '../../domain/fuel_price.dart';
import '../../domain/fuel_type.dart';
import '../../domain/vehicle_efficiency.dart';
import '../widgets/fuel_input_field.dart';
import '../widgets/result_view.dart';

enum ComparisonRule { standard, custom }

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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

  @override
  void dispose() {
    _gasolinePriceController.dispose();
    _ethanolPriceController.dispose();
    _gasolineConsumptionController.dispose();
    _ethanolConsumptionController.dispose();
    super.dispose();
  }

  void _selectRule(Set<ComparisonRule> selection) {
    setState(() {
      _rule = selection.first;
    });
  }

  void _submit() {
    final FuelInputParseResult gasolinePriceResult =
        parseRequiredPositiveDecimal(_gasolinePriceController.text);
    final FuelInputParseResult ethanolPriceResult =
        parseRequiredPositiveDecimal(_ethanolPriceController.text);
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
        ),
      );
    });
  }

  VehicleEfficiency? _buildEfficiency(
    FuelInputParseResult gasolineConsumptionResult,
    FuelInputParseResult ethanolConsumptionResult,
  ) {
    if (_rule != ComparisonRule.custom) {
      return null;
    }

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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 16,
          children: <Widget>[
            FuelInputField(
              label: 'Preço da gasolina',
              controller: _gasolinePriceController,
              errorText: _gasolinePriceError,
            ),
            FuelInputField(
              label: 'Preço do etanol',
              controller: _ethanolPriceController,
              errorText: _ethanolPriceError,
            ),
            FuelInputField(
              label: 'Consumo de gasolina (km/l)',
              controller: _gasolineConsumptionController,
              errorText: _gasolineConsumptionError,
            ),
            FuelInputField(
              label: 'Consumo de etanol (km/l)',
              controller: _ethanolConsumptionController,
              errorText: _ethanolConsumptionError,
            ),
            SegmentedButton<ComparisonRule>(
              segments: const <ButtonSegment<ComparisonRule>>[
                ButtonSegment<ComparisonRule>(
                  value: ComparisonRule.standard,
                  label: Text('Padrão (0,70)'),
                ),
                ButtonSegment<ComparisonRule>(
                  value: ComparisonRule.custom,
                  label: Text('Personalizada'),
                ),
              ],
              selected: <ComparisonRule>{_rule},
              onSelectionChanged: _selectRule,
            ),
            FilledButton(
              onPressed: _submit,
              child: const Text('Calcular'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResult() {
    final FuelCalculationResult result = _result!;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(child: ResultView(result: result)),
          FilledButton(
            onPressed: _startNewCalculation,
            child: const Text('Novo cálculo'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final FuelCalculationResult? result = _result;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fuelwise'),
      ),
      body: result == null ? _buildForm() : _buildResult(),
    );
  }
}
