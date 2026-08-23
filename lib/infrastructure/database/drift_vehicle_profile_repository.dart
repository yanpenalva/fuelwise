import 'package:drift/drift.dart' show Value;

import 'package:fuelwise/application/profile/vehicle_profile_repository.dart';
import 'package:fuelwise/application/profile/vehicle_profile_storage_exception.dart';
import 'package:fuelwise/domain/vehicle_profile.dart';
import 'package:fuelwise/infrastructure/database/app_database.dart';
import 'package:fuelwise/infrastructure/database/vehicle_profile_mapper.dart';

final class DriftVehicleProfileRepository implements VehicleProfileRepository {
  final AppDatabase _database;
  final VehicleProfileMapper _mapper;

  DriftVehicleProfileRepository(this._database)
    : _mapper = const VehicleProfileMapper();

  @override
  Future<VehicleProfile?> load() async {
    final row = await _database.getVehicleProfile();

    if (row == null) {
      return null;
    }

    return _mapper.toDomain(row);
  }

  @override
  Future<VehicleProfile> save(VehicleProfile profile) {
    return _database.transaction(() async {
      final existing = await _database.getVehicleProfile();
      final updatedAt = DateTime.now().toUtc();

      if (existing == null) {
        final stored = await _database.insertVehicleProfile(
          VehicleProfilesCompanion.insert(
            name: profile.name,
            gasolineKmPerLiter: Value(profile.gasolineKmPerLiter?.toString()),
            ethanolKmPerLiter: Value(profile.ethanolKmPerLiter?.toString()),
            updatedAt: updatedAt,
          ),
        );
        return _mapper.toDomain(stored);
      }

      await _database.updateVehicleProfile(
        existing.copyWith(
          name: profile.name,
          gasolineKmPerLiter: Value(profile.gasolineKmPerLiter?.toString()),
          ethanolKmPerLiter: Value(profile.ethanolKmPerLiter?.toString()),
          updatedAt: updatedAt,
        ),
      );

      final stored = await _database.getVehicleProfile();

      if (stored == null) {
        throw VehicleProfileStorageException('id', existing.id.toString());
      }

      return _mapper.toDomain(stored);
    });
  }
}
