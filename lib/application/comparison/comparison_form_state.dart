import '../../domain/fuel_calculation_result.dart';

sealed class HistorySaveStatus {
  const HistorySaveStatus();
}

final class HistorySaveIdle extends HistorySaveStatus {
  const HistorySaveIdle();

  @override
  bool operator ==(Object other) =>
      other is HistorySaveIdle && other.runtimeType == runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;
}

final class HistorySaveSaving extends HistorySaveStatus {
  const HistorySaveSaving();

  @override
  bool operator ==(Object other) =>
      other is HistorySaveSaving && other.runtimeType == runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;
}

final class HistorySaveSuccess extends HistorySaveStatus {
  const HistorySaveSuccess();

  @override
  bool operator ==(Object other) =>
      other is HistorySaveSuccess && other.runtimeType == runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;
}

final class HistorySaveFailure extends HistorySaveStatus {
  final String message;

  const HistorySaveFailure(this.message);

  @override
  bool operator ==(Object other) =>
      other is HistorySaveFailure && other.message == message;

  @override
  int get hashCode => message.hashCode;
}

final class ComparisonFormState {
  const ComparisonFormState({
    required this.isSubmitting,
    required this.gasolinePriceError,
    required this.ethanolPriceError,
    required this.gasolineConsumptionError,
    required this.ethanolConsumptionError,
    required this.result,
    required this.historySave,
  });

  const ComparisonFormState.initial()
    : isSubmitting = false,
      gasolinePriceError = null,
      ethanolPriceError = null,
      gasolineConsumptionError = null,
      ethanolConsumptionError = null,
      result = null,
      historySave = const HistorySaveIdle();

  final bool isSubmitting;
  final String? gasolinePriceError;
  final String? ethanolPriceError;
  final String? gasolineConsumptionError;
  final String? ethanolConsumptionError;
  final FuelCalculationResult? result;
  final HistorySaveStatus historySave;

  ComparisonFormState copyWith({
    bool? isSubmitting,
    FuelCalculationResult? result,
    HistorySaveStatus? historySave,
  }) {
    return ComparisonFormState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      gasolinePriceError: gasolinePriceError,
      ethanolPriceError: ethanolPriceError,
      gasolineConsumptionError: gasolineConsumptionError,
      ethanolConsumptionError: ethanolConsumptionError,
      result: result ?? this.result,
      historySave: historySave ?? this.historySave,
    );
  }

  ComparisonFormState withErrors({
    required String? gasolinePriceError,
    required String? ethanolPriceError,
    required String? gasolineConsumptionError,
    required String? ethanolConsumptionError,
  }) {
    return ComparisonFormState(
      isSubmitting: isSubmitting,
      gasolinePriceError: gasolinePriceError,
      ethanolPriceError: ethanolPriceError,
      gasolineConsumptionError: gasolineConsumptionError,
      ethanolConsumptionError: ethanolConsumptionError,
      result: result,
      historySave: historySave,
    );
  }

  ComparisonFormState withoutErrors() {
    return ComparisonFormState(
      isSubmitting: isSubmitting,
      gasolinePriceError: null,
      ethanolPriceError: null,
      gasolineConsumptionError: null,
      ethanolConsumptionError: null,
      result: result,
      historySave: historySave,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is ComparisonFormState &&
        other.isSubmitting == isSubmitting &&
        other.gasolinePriceError == gasolinePriceError &&
        other.ethanolPriceError == ethanolPriceError &&
        other.gasolineConsumptionError == gasolineConsumptionError &&
        other.ethanolConsumptionError == ethanolConsumptionError &&
        other.result == result &&
        other.historySave == historySave;
  }

  @override
  int get hashCode => Object.hash(
    isSubmitting,
    gasolinePriceError,
    ethanolPriceError,
    gasolineConsumptionError,
    ethanolConsumptionError,
    result,
    historySave,
  );
}
