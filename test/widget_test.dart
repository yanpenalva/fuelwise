import 'package:flutter_test/flutter_test.dart';

import 'package:fuelwise/main.dart';

void main() {
  testWidgets('renders the Fuelwise comparison form', (tester) async {
    await tester.pumpWidget(const FuelwiseApp());

    expect(find.text('Fuelwise'), findsOneWidget);
    expect(find.text('Padrão (0,70)'), findsOneWidget);
    expect(find.text('Personalizada'), findsOneWidget);
    expect(find.text('Calcular'), findsOneWidget);
  });
}
