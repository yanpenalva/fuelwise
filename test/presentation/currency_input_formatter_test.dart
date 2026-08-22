import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fuelwise/presentation/widgets/fuel_input_field.dart';

void main() {
  final CurrencyInputFormatter formatter = CurrencyInputFormatter();

  TextEditingValue type(TextEditingValue current, String insertion) {
    final String text = current.text + insertion;
    return formatter.formatEditUpdate(
      current,
      TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      ),
    );
  }

  group('CurrencyInputFormatter', () {
    test('typing 6, 2, 9 produces 6,29 without leading zeros', () {
      var value = const TextEditingValue(text: '');

      value = type(value, '6');
      expect(value.text, '0,06');

      value = type(value, '2');
      expect(value.text, '0,62');

      value = type(value, '9');
      expect(value.text, '6,29');
    });

    test('typing past 99 cents rolls into integer part', () {
      var value = const TextEditingValue(text: '');

      for (final String digit in <String>['1', '2', '3', '4', '5']) {
        value = type(value, digit);
      }

      expect(value.text, '123,45');
    });

    test('formats thousands grouping', () {
      var value = const TextEditingValue(text: '');

      for (final String digit in <String>['1', '2', '3', '4', '5', '6', '7']) {
        value = type(value, digit);
      }

      expect(value.text, '12.345,67');
    });

    test('empty and zero-only input clears the field', () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(text: ''),
        const TextEditingValue(text: ','),
      );

      expect(result.text, isEmpty);
    });
  });
}
