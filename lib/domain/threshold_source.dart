import 'package:decimal/decimal.dart';

enum ThresholdSource { standard, custom }

abstract final class FuelThreshold {
  static final Decimal standard = Decimal.parse('0.70');
}
