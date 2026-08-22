import 'package:decimal/decimal.dart';

class VehicleEfficiency {
  final Decimal? gasolineKmPerLiter;
  final Decimal? ethanolKmPerLiter;

  const VehicleEfficiency._(this.gasolineKmPerLiter, this.ethanolKmPerLiter);

  factory VehicleEfficiency({
    Decimal? gasolineKmPerLiter,
    Decimal? ethanolKmPerLiter,
  }) {
    _validate(gasolineKmPerLiter, 'gasolineKmPerLiter');
    _validate(ethanolKmPerLiter, 'ethanolKmPerLiter');

    if (gasolineKmPerLiter == null && ethanolKmPerLiter == null) {
      throw ArgumentError(
        'at least one consumption value must be provided',
      );
    }

    return VehicleEfficiency._(gasolineKmPerLiter, ethanolKmPerLiter);
  }

  static void _validate(Decimal? value, String name) {
    if (value == null) {
      return;
    }

    if (value <= Decimal.zero) {
      throw ArgumentError.value(value, name, 'must be greater than zero');
    }
  }

  bool get isComplete =>
      gasolineKmPerLiter != null && ethanolKmPerLiter != null;

  @override
  bool operator ==(Object other) =>
      other is VehicleEfficiency &&
      other.gasolineKmPerLiter == gasolineKmPerLiter &&
      other.ethanolKmPerLiter == ethanolKmPerLiter;

  @override
  int get hashCode => Object.hash(gasolineKmPerLiter, ethanolKmPerLiter);
}
