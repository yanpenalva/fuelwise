import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fuelwise/presentation/widgets/fuel_input_field.dart';

TextEditingValue _format(String raw) {
  final DecimalInputFormatter formatter = DecimalInputFormatter();

  return formatter.formatEditUpdate(
    const TextEditingValue(text: ''),
    TextEditingValue(
      text: raw,
      selection: TextSelection.collapsed(offset: raw.length),
    ),
  );
}

void main() {
  test('keeps comma decimal separator as typed', () {
    expect(_format('10,6').text, '10,6');
  });

  test('normalizes dot decimal separator to comma', () {
    expect(_format('10.6').text, '10,6');
    expect(_format('9.8').text, '9,8');
  });

  test('keeps only the first separator', () {
    expect(_format('10,6.5').text, '10,65');
    expect(_format('1.2,3').text, '1,23');
  });

  test('prefixes zero when text starts with a separator', () {
    expect(_format(',5').text, '0,5');
    expect(_format('.5').text, '0,5');
  });

  test('strips characters other than digits and separators', () {
    expect(_format('1a2b3').text, '123');
    expect(_format('-10').text, '10');
  });

  test('formats empty input to empty text', () {
    expect(_format('').text, '');
  });
}
