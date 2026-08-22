import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fuelwise/domain/fuel_input_parser.dart';

void main() {
  group('parseRequiredPositiveDecimal', () {
    test('parses period separator', () {
      final result = parseRequiredPositiveDecimal('6.19');

      expect(result, FuelInputParseSuccess(Decimal.parse('6.19')));
    });

    test('parses comma separator', () {
      final result = parseRequiredPositiveDecimal('6,19');

      expect(result, FuelInputParseSuccess(Decimal.parse('6.19')));
    });

    test('fails on empty input with required message', () {
      final result = parseRequiredPositiveDecimal('');

      expect(result, const FuelInputParseFailure(FuelInputMessages.required));
    });

    test('treats whitespace-only input as empty', () {
      final optionalResult = parseOptionalPositiveDecimal('   ');
      final requiredResult = parseRequiredPositiveDecimal(' \t ');

      expect(optionalResult, const FuelInputParseSuccess(null));
      expect(
        requiredResult,
        const FuelInputParseFailure(FuelInputMessages.required),
      );
    });

    test('fails on non-numeric text with invalid-number message', () {
      final result = parseRequiredPositiveDecimal('abc');

      expect(
        result,
        const FuelInputParseFailure(FuelInputMessages.invalidNumber),
      );
    });

    test('fails on zero and negative values with greater-than-zero message', () {
      final zeroResult = parseRequiredPositiveDecimal('0');
      final negativeResult = parseRequiredPositiveDecimal('-1');

      expect(
        zeroResult,
        const FuelInputParseFailure(FuelInputMessages.greaterThanZero),
      );
      expect(
        negativeResult,
        const FuelInputParseFailure(FuelInputMessages.greaterThanZero),
      );
    });
  });

  group('parseOptionalPositiveDecimal', () {
    test('returns null success on empty input', () {
      final result = parseOptionalPositiveDecimal('');

      expect(result, const FuelInputParseSuccess(null));
    });

    test('parses valid value', () {
      final result = parseOptionalPositiveDecimal('10,5');

      expect(result, FuelInputParseSuccess(Decimal.parse('10.5')));
    });

    test('rejects invalid values like required parser', () {
      expect(
        parseOptionalPositiveDecimal('-3'),
        const FuelInputParseFailure(FuelInputMessages.greaterThanZero),
      );
      expect(
        parseOptionalPositiveDecimal('x'),
        const FuelInputParseFailure(FuelInputMessages.invalidNumber),
      );
    });
  });

  group('FuelInputParseResult types', () {
    test('success supports equality and distinguishes null from zero-like values',
        () {
      expect(
        const FuelInputParseSuccess(null),
        const FuelInputParseSuccess(null),
      );
      expect(
        const FuelInputParseSuccess(null),
        isNot(FuelInputParseSuccess(Decimal.zero)),
      );
    });

    test('failure supports equality by message', () {
      expect(
        const FuelInputParseFailure(FuelInputMessages.required),
        const FuelInputParseFailure(FuelInputMessages.required),
      );
      expect(
        const FuelInputParseFailure(FuelInputMessages.required),
        isNot(const FuelInputParseFailure(FuelInputMessages.invalidNumber)),
      );
    });

    test('failure is not equal to success carrying same content', () {
      expect(
        const FuelInputParseFailure(FuelInputMessages.required),
        isNot(const FuelInputParseSuccess(null) as Object),
      );
    });

    test('exhaustive switch over result subtypes compiles', () {
      final FuelInputParseResult result =
          parseRequiredPositiveDecimal('6,19');
      String describe(FuelInputParseResult value) => switch (value) {
            FuelInputParseSuccess(:final value) => value.toString(),
            FuelInputParseFailure(:final userMessage) => userMessage,
          };

      expect(describe(result), Decimal.parse('6.19').toString());
    });
  });
}
