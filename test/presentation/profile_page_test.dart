import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fuelwise/application/profile/vehicle_profile_controller.dart';
import 'package:fuelwise/application/profile/vehicle_profile_repository.dart';
import 'package:fuelwise/domain/vehicle_profile.dart';
import 'package:fuelwise/presentation/pages/profile_page.dart';

final class _FakeVehicleProfileRepository implements VehicleProfileRepository {
  _FakeVehicleProfileRepository({this.initial});

  final VehicleProfile? initial;
  VehicleProfile? saved;
  int saveCount = 0;

  @override
  Future<VehicleProfile?> load() async => initial;

  @override
  Future<VehicleProfile> save(VehicleProfile profile) async {
    saveCount++;
    saved = profile;
    return profile;
  }
}

Future<void> _pumpProfilePage(
  WidgetTester tester,
  VehicleProfileRepository repository,
) {
  return tester.pumpWidget(
    ProviderScope(
      overrides: [
        vehicleProfileRepositoryProvider.overrideWithValue(repository),
      ],
      child: const MaterialApp(home: ProfilePage()),
    ),
  );
}

void main() {
  testWidgets('saves valid profile', (tester) async {
    final _FakeVehicleProfileRepository repository =
        _FakeVehicleProfileRepository();

    await _pumpProfilePage(tester, repository);
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'Meu carro',
    );
    await tester.enterText(find.byType(TextFormField).at(1), '10,5');
    await tester.enterText(find.byType(TextFormField).at(2), '7');

    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    expect(repository.saveCount, 1);
    expect(repository.saved?.name, 'Meu carro');
    expect(
      repository.saved?.gasolineKmPerLiter,
      Decimal.parse('10.5'),
    );
    expect(repository.saved?.ethanolKmPerLiter, Decimal.parse('7'));
  });

  testWidgets('blank name shows inline error and does not save',
      (tester) async {
    final _FakeVehicleProfileRepository repository =
        _FakeVehicleProfileRepository();

    await _pumpProfilePage(tester, repository);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    expect(find.text('Informe o nome do veículo.'), findsOneWidget);
    expect(repository.saveCount, 0);
  });

  testWidgets('strips invalid characters from consumption while typing',
      (tester) async {
    final _FakeVehicleProfileRepository repository =
        _FakeVehicleProfileRepository();

    await _pumpProfilePage(tester, repository);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'Meu carro');
    await tester.enterText(find.byType(TextFormField).at(1), '-1a.5');

    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    expect(repository.saveCount, 1);
    expect(repository.saved?.gasolineKmPerLiter, Decimal.parse('1.5'));
  });

  testWidgets('prefills fields from loaded profile', (tester) async {
    final _FakeVehicleProfileRepository repository =
        _FakeVehicleProfileRepository(
      initial: VehicleProfile(
        name: 'Fusca',
        gasolineKmPerLiter: Decimal.parse('10.5'),
        ethanolKmPerLiter: Decimal.parse('7'),
      ),
    );

    await _pumpProfilePage(tester, repository);
    await tester.pumpAndSettle();

    expect(find.text('Fusca'), findsOneWidget);
    expect(find.text('10,5'), findsOneWidget);
    expect(find.text('7'), findsOneWidget);
  });
}
