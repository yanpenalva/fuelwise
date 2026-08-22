import 'package:decimal/decimal.dart';

import 'fuel_type.dart';

class FuelPrice {
  final FuelType type;
  final Decimal value;

  const FuelPrice._(this.type, this.value);

  factory FuelPrice({required FuelType type, required Decimal value}) {
    if (value <= Decimal.zero) {
      throw ArgumentError.value(value, 'value', 'must be greater than zero');
    }

    return FuelPrice._(type, value);
  }

  @override
  bool operator ==(Object other) =>
      other is FuelPrice && other.type == type && other.value == value;

  @override
  int get hashCode => Object.hash(type, value);
}
