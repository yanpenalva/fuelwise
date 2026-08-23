import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fuelwise/application/profile/vehicle_profile_controller.dart';
import 'package:fuelwise/application/profile/vehicle_profile_repository.dart';
import 'package:fuelwise/domain/vehicle_profile.dart';

final class _InMemoryVehicleProfileRepository
    implements VehicleProfileRepository {
  VehicleProfile? _stored;

  @override
  Future<VehicleProfile?> load() async => _stored;

  @override
  Future<VehicleProfile> save(VehicleProfile profile) async {
    _stored = profile;
    return _stored!;
  }
}

void main() {
  test('initial build is null when repository empty', () async {
    final ProviderContainer container = ProviderContainer(
      overrides: [
        vehicleProfileRepositoryProvider.overrideWithValue(
          _InMemoryVehicleProfileRepository(),
        ),
      ],
    );
    addTearDown(container.dispose);

    final VehicleProfile? profile = await container.read(
      vehicleProfileProvider.future,
    );

    expect(profile, isNull);
  });

  test('save persists and exposes profile', () async {
    final _InMemoryVehicleProfileRepository repository =
        _InMemoryVehicleProfileRepository();
    final ProviderContainer container = ProviderContainer(
      overrides: [
        vehicleProfileRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);
    await container.read(vehicleProfileProvider.future);
    final VehicleProfileController controller = container.read(
      vehicleProfileProvider.notifier,
    );

    final VehicleProfile profile = VehicleProfile(name: 'Car');
    await controller.save(profile);

    expect(repository._stored, profile);
    expect(container.read(vehicleProfileProvider).requireValue, profile);
  });

  test('save twice updates same single stored profile', () async {
    final _InMemoryVehicleProfileRepository repository =
        _InMemoryVehicleProfileRepository();
    final ProviderContainer container = ProviderContainer(
      overrides: [
        vehicleProfileRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);
    await container.read(vehicleProfileProvider.future);
    final VehicleProfileController controller = container.read(
      vehicleProfileProvider.notifier,
    );

    await controller.save(VehicleProfile(name: 'Car'));
    await controller.save(VehicleProfile(name: 'Bike'));

    expect(repository._stored, VehicleProfile(name: 'Bike'));
    expect(
      container.read(vehicleProfileProvider).requireValue,
      VehicleProfile(name: 'Bike'),
    );
  });
}
