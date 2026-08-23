import 'package:decimal/decimal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/fuel_calculation_input.dart';
import '../../domain/fuel_calculator.dart';
import '../../domain/fuel_calculation_result.dart';
import '../../domain/fuel_input_parser.dart';
import '../../domain/fuel_price.dart';
import '../../domain/fuel_type.dart';
import '../../domain/vehicle_efficiency.dart';
import '../history/history_controller.dart';
import '../preferences/app_preferences_controller.dart';
import '../preferences/rule_mode.dart';
import 'comparison_form_state.dart';

final NotifierProvider<ComparisonFormController, ComparisonFormState>
    comparisonFormProvider =
    NotifierProvider<ComparisonFormController, ComparisonFormState>(
  ComparisonFormController.new,
);

class ComparisonFormController extends Notifier<ComparisonFormState> {
  @override
  ComparisonFormState build() => const ComparisonFormState.initial();

  Future<void> submit({
    required String gasolinePriceText,
    required String ethanolPriceText,
    required String gasolineConsumptionText,
    required String ethanolConsumptionText,
  }) async {
    if (state.isSubmitting) {
      return;
    }

    final FuelInputParseResult gasolinePriceResult =
        parseRequiredPositiveDecimal(gasolinePriceText);
    final FuelInputParseResult ethanolPriceResult =
        parseRequiredPositiveDecimal(ethanolPriceText);
    final FuelInputParseResult gasolineConsumptionResult =
        parseOptionalPositiveDecimal(gasolineConsumptionText);
    final FuelInputParseResult ethanolConsumptionResult =
        parseOptionalPositiveDecimal(ethanolConsumptionText);

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
      state = state.withErrors(
        gasolinePriceError: gasolinePriceError,
        ethanolPriceError: ethanolPriceError,
        gasolineConsumptionError: gasolineConsumptionError,
        ethanolConsumptionError: ethanolConsumptionError,
      );
      return;
    }

    state = state.withoutErrors().copyWith(isSubmitting: true);

    try {
      final bool applyCustomThreshold =
          ref.read(appPreferencesProvider).value?.ruleMode == RuleMode.custom;

      final FuelCalculationInput input = FuelCalculationInput(
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
        applyCustomThreshold: applyCustomThreshold,
      );

      final FuelCalculationResult result =
          const FuelCalculator().calculate(input);

      state = state.copyWith(result: result);

      state = state.copyWith(historySave: const HistorySaveSaving());

      try {
        await ref
            .read(historyProvider.notifier)
            .record(input: input, result: result);
        state = state.copyWith(historySave: const HistorySaveSuccess());
      } catch (_) {
        state = state.copyWith(
          historySave:
              const HistorySaveFailure('Não foi possível salvar no histórico.'),
        );
      }
    } finally {
      state = state.copyWith(isSubmitting: false);
    }
  }

  void reset() {
    state = const ComparisonFormState.initial();
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
}
