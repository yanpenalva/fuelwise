import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fuelwise/domain/vehicle_profile.dart';

void main() {
  Decimal consumption(String value) => Decimal.parse(value);

  group('VehicleProfile', () {
    group('creation', () {
      test('creates with name only and no consumption values', () {
        final profile = VehicleProfile(name: 'My Car');

        expect(profile.name, 'My Car');
        expect(profile.gasolineKmPerLiter, isNull);
        expect(profile.ethanolKmPerLiter, isNull);
      });

      test('accepts positive consumption values', () {
        final profile = VehicleProfile(
          name: 'My Car',
          gasolineKmPerLiter: consumption('10.5'),
          ethanolKmPerLiter: consumption('7.3'),
        );

        expect(profile.gasolineKmPerLiter, consumption('10.5'));
        expect(profile.ethanolKmPerLiter, consumption('7.3'));
      });

      test('accepts consumption of exactly 0.01', () {
        final profile = VehicleProfile(
          name: 'My Car',
          gasolineKmPerLiter: consumption('0.01'),
          ethanolKmPerLiter: consumption('0.01'),
        );

        expect(profile.gasolineKmPerLiter, consumption('0.01'));
        expect(profile.ethanolKmPerLiter, consumption('0.01'));
      });
    });

    group('name validation', () {
      test('rejects blank name', () {
        expect(
          () => VehicleProfile(name: ''),
          throwsArgumentError,
        );
      });

      test('rejects whitespace-only name', () {
        expect(
          () => VehicleProfile(name: '   '),
          throwsArgumentError,
        );
      });
    });

    group('gasoline consumption validation', () {
      test('rejects zero gasoline consumption', () {
        expect(
          () => VehicleProfile(
            name: 'My Car',
            gasolineKmPerLiter: Decimal.zero,
          ),
          throwsArgumentError,
        );
      });

      test('rejects negative gasoline consumption', () {
        expect(
          () => VehicleProfile(
            name: 'My Car',
            gasolineKmPerLiter: consumption('-1.0'),
          ),
          throwsArgumentError,
        );
      });
    });

    group('ethanol consumption validation', () {
      test('rejects zero ethanol consumption', () {
        expect(
          () => VehicleProfile(
            name: 'My Car',
            ethanolKmPerLiter: Decimal.zero,
          ),
          throwsArgumentError,
        );
      });

      test('rejects negative ethanol consumption', () {
        expect(
          () => VehicleProfile(
            name: 'My Car',
            ethanolKmPerLiter: consumption('-1.0'),
          ),
          throwsArgumentError,
        );
      });
    });

    group('hasConsumption', () {
      test('is true when only gasoline is set', () {
        final profile = VehicleProfile(
          name: 'My Car',
          gasolineKmPerLiter: consumption('10.5'),
        );

        expect(profile.hasConsumption, isTrue);
      });

      test('is true when only ethanol is set', () {
        final profile = VehicleProfile(
          name: 'My Car',
          ethanolKmPerLiter: consumption('7.3'),
        );

        expect(profile.hasConsumption, isTrue);
      });

      test('is true when both are set', () {
        final profile = VehicleProfile(
          name: 'My Car',
          gasolineKmPerLiter: consumption('10.5'),
          ethanolKmPerLiter: consumption('7.3'),
        );

        expect(profile.hasConsumption, isTrue);
      });

      test('is false when none is set', () {
        final profile = VehicleProfile(name: 'My Car');

        expect(profile.hasConsumption, isFalse);
      });
    });

    group('copyWith', () {
      test('changes name', () {
        final profile = VehicleProfile(name: 'My Car');

        final updated = profile.copyWith(name: 'New Name');

        expect(updated.name, 'New Name');
      });

      test('sets ethanol value', () {
        final profile = VehicleProfile(name: 'My Car');

        final updated = profile.copyWith(
          ethanolKmPerLiter: consumption('7.3'),
          setEthanol: true,
        );

        expect(updated.ethanolKmPerLiter, consumption('7.3'));
        expect(updated.gasolineKmPerLiter, isNull);
      });

      test('clears ethanol when setEthanol is true and value is null', () {
        final profile = VehicleProfile(
          name: 'My Car',
          ethanolKmPerLiter: consumption('7.3'),
        );

        final updated = profile.copyWith(setEthanol: true);

        expect(updated.ethanolKmPerLiter, isNull);
      });

      test('preserves untouched optional field when flag absent', () {
        final profile = VehicleProfile(
          name: 'My Car',
          gasolineKmPerLiter: consumption('10.5'),
          ethanolKmPerLiter: consumption('7.3'),
        );

        final updated = profile.copyWith(
          gasolineKmPerLiter: consumption('9.0'),
          setGasoline: true,
        );

        expect(updated.gasolineKmPerLiter, consumption('9.0'));
        expect(updated.ethanolKmPerLiter, consumption('7.3'));
      });
    });

    group('equality', () {
      test('equal instances are equal', () {
        final a = VehicleProfile(
          name: 'My Car',
          gasolineKmPerLiter: consumption('10.5'),
          ethanolKmPerLiter: consumption('7.3'),
        );
        final b = VehicleProfile(
          name: 'My Car',
          gasolineKmPerLiter: consumption('10.5'),
          ethanolKmPerLiter: consumption('7.3'),
        );

        expect(a, equals(b));
        expect(a.hashCode, b.hashCode);
      });

      test('instances with different names are not equal', () {
        final a = VehicleProfile(name: 'Car A');
        final b = VehicleProfile(name: 'Car B');

        expect(a, isNot(equals(b)));
      });

      test('instances with different consumption are not equal', () {
        final a = VehicleProfile(
          name: 'My Car',
          gasolineKmPerLiter: consumption('10.5'),
        );
        final b = VehicleProfile(
          name: 'My Car',
          gasolineKmPerLiter: consumption('9.0'),
        );

        expect(a, isNot(equals(b)));
      });
    });
  });
}
