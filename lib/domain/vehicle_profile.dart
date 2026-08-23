import 'package:decimal/decimal.dart';

final class VehicleProfile {
  final String name;
  final Decimal? gasolineKmPerLiter;
  final Decimal? ethanolKmPerLiter;

  const VehicleProfile._(
    this.name,
    this.gasolineKmPerLiter,
    this.ethanolKmPerLiter,
  );

  factory VehicleProfile({
    required String name,
    Decimal? gasolineKmPerLiter,
    Decimal? ethanolKmPerLiter,
  }) {
    final trimmedName = name.trim();

    if (trimmedName.isEmpty) {
      throw ArgumentError.value(name, 'name', 'must not be empty');
    }

    _validate(gasolineKmPerLiter, 'gasolineKmPerLiter');
    _validate(ethanolKmPerLiter, 'ethanolKmPerLiter');

    return VehicleProfile._(trimmedName, gasolineKmPerLiter, ethanolKmPerLiter);
  }

  static void _validate(Decimal? value, String name) {
    if (value == null) {
      return;
    }

    if (value <= Decimal.zero) {
      throw ArgumentError.value(value, name, 'must be greater than zero');
    }
  }

  bool get hasConsumption =>
      gasolineKmPerLiter != null || ethanolKmPerLiter != null;

  VehicleProfile copyWith({
    String? name,
    Decimal? gasolineKmPerLiter,
    Decimal? ethanolKmPerLiter,
    bool setGasoline = false,
    bool setEthanol = false,
  }) {
    return VehicleProfile(
      name: name?.trim() ?? this.name,
      gasolineKmPerLiter: setGasoline
          ? gasolineKmPerLiter
          : this.gasolineKmPerLiter,
      ethanolKmPerLiter: setEthanol
          ? ethanolKmPerLiter
          : this.ethanolKmPerLiter,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is VehicleProfile &&
        other.name == name &&
        other.gasolineKmPerLiter == gasolineKmPerLiter &&
        other.ethanolKmPerLiter == ethanolKmPerLiter;
  }

  @override
  int get hashCode => Object.hash(name, gasolineKmPerLiter, ethanolKmPerLiter);
}
