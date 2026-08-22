import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CurrencyInputFormatter extends TextInputFormatter {
  static final RegExp _digitsOnly = RegExp(r'[0-9]');
  static const int _maxDigits = 9;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final String digits = newValue.text
        .split('')
        .where(_digitsOnly.hasMatch)
        .join();

    if (digits.isEmpty || digits == '00') {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    final String trimmed = digits.length > _maxDigits
        ? digits.substring(digits.length - _maxDigits)
        : digits;
    final String formatted = _formatCents(trimmed);
    final int offset = formatted.length;

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: offset),
    );
  }

  static String _formatCents(String digits) {
    final String padded = digits.padLeft(3, '0');
    final String cents = padded.substring(padded.length - 2);
    final String integerPart = padded.substring(0, padded.length - 2);
    final StringBuffer grouped = StringBuffer();
    var count = 0;

    for (var i = integerPart.length - 1; i >= 0; i--) {
      grouped.write(integerPart[i]);
      count++;

      if (count % 3 == 0 && i != 0) {
        grouped.write('.');
      }
    }

    return '${grouped.toString().split('').reversed.join()},$cents';
  }

  static String toParserInput(String formatted) {
    return formatted.replaceAll('.', '').replaceAll(',', '.');
  }
}

class FuelInputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? errorText;
  final String? prefixText;
  final String? suffixText;
  final String? hintText;
  final String? helperText;
  final bool useCurrencyMask;

  const FuelInputField({
    super.key,
    required this.label,
    required this.controller,
    this.errorText,
    this.prefixText,
    this.suffixText,
    this.hintText,
    this.helperText,
    this.useCurrencyMask = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: <TextInputFormatter>[
        if (useCurrencyMask)
          CurrencyInputFormatter()
        else
          FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
      ],
      decoration: InputDecoration(
        labelText: label,
        errorText: errorText,
        prefixText: prefixText,
        suffixText: suffixText,
        hintText: hintText,
        helperText: helperText,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
