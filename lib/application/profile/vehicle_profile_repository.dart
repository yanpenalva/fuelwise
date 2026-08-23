import 'package:fuelwise/domain/vehicle_profile.dart';

abstract interface class VehicleProfileRepository {
  Future<VehicleProfile?> load();
  Future<VehicleProfile> save(VehicleProfile profile);
}
