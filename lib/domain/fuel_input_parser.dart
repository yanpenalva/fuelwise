import 'package:decimal/decimal.dart';

abstract final class FuelInputMessages {
  static const String required = 'Valor obrigatório';
  static const String greaterThanZero = 'Informe um valor maior que zero';
  static const String invalidNumber =
      'Digite um número válido (use vírgula ou ponto decimal)';
}

sealed class FuelInputParseResult {
  const FuelInputParseResult();
}

class FuelInputParseSuccess extends FuelInputParseResult {
  final Decimal? value;

  const FuelInputParseSuccess(this.value);

  @override
  bool operator ==(Object other) =>
      other is FuelInputParseSuccess && other.value == value;

  @override
  int get hashCode => value.hashCode;
}

class FuelInputParseFailure extends FuelInputParseResult {
  final String userMessage;

  const FuelInputParseFailure(this.userMessage);

  @override
  bool operator ==(Object other) =>
      other is FuelInputParseFailure && other.userMessage == userMessage;

  @override
  int get hashCode => userMessage.hashCode;
}

FuelInputParseResult parseOptionalPositiveDecimal(String input) {
  final String trimmed = input.trim();

  if (trimmed.isEmpty) {
    return const FuelInputParseSuccess(null);
  }

  return _parsePositive(trimmed);
}

FuelInputParseResult parseRequiredPositiveDecimal(String input) {
  final String trimmed = input.trim();

  if (trimmed.isEmpty) {
    return const FuelInputParseFailure(FuelInputMessages.required);
  }

  return _parsePositive(trimmed);
}

FuelInputParseResult _parsePositive(String trimmed) {
  final String normalized = trimmed.replaceAll(',', '.');
  final Decimal? value = Decimal.tryParse(normalized);

  if (value == null) {
    return const FuelInputParseFailure(FuelInputMessages.invalidNumber);
  }

  if (value <= Decimal.zero) {
    return const FuelInputParseFailure(FuelInputMessages.greaterThanZero);
  }

  return FuelInputParseSuccess(value);
}
