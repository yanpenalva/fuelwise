import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/vehicle_profile.dart';
import 'vehicle_profile_repository.dart';

final Provider<VehicleProfileRepository> vehicleProfileRepositoryProvider =
    Provider<VehicleProfileRepository>(
  (Ref ref) => throw UnimplementedError(),
);

final AsyncNotifierProvider<VehicleProfileController, VehicleProfile?>
    vehicleProfileProvider = AsyncNotifierProvider<VehicleProfileController,
        VehicleProfile?>(VehicleProfileController.new);

class VehicleProfileController extends AsyncNotifier<VehicleProfile?> {
  @override
  Future<VehicleProfile?> build() async {
    return ref.read(vehicleProfileRepositoryProvider).load();
  }

  Future<void> save(VehicleProfile profile) async {
    final VehicleProfileRepository repository =
        ref.read(vehicleProfileRepositoryProvider);
    final VehicleProfile stored = await repository.save(profile);
    state = AsyncData(stored);
  }
}
