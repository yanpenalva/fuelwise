import 'package:decimal/decimal.dart';

import 'package:fuelwise/application/profile/vehicle_profile_storage_exception.dart';
import 'package:fuelwise/domain/vehicle_profile.dart';
import 'package:fuelwise/infrastructure/database/app_database.dart';

final class VehicleProfileMapper {
  const VehicleProfileMapper();

  VehicleProfile toDomain(VehicleProfileRow row) {
    return VehicleProfile(
      name: row.name,
      gasolineKmPerLiter:
          _toDecimal(row.gasolineKmPerLiter, 'gasolineKmPerLiter'),
      ethanolKmPerLiter: _toDecimal(row.ethanolKmPerLiter, 'ethanolKmPerLiter'),
    );
  }

  Decimal? _toDecimal(String? raw, String fieldName) {
    if (raw == null) {
      return null;
    }

    final normalized = raw.trim().replaceAll(',', '.');
    final value = Decimal.tryParse(normalized);

    if (value == null || value <= Decimal.zero) {
      throw VehicleProfileStorageException(fieldName, raw);
    }

    return value;
  }
}
