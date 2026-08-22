import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fuelwise/main.dart';

Future<void> _pumpAndDismissWelcome(WidgetTester tester) async {
  await tester.pumpWidget(const FuelwiseApp());
  await tester.pump();

  if (find.byType(AlertDialog).evaluate().isNotEmpty) {
    await tester.tap(find.text('Entendi'));
    await tester.pump();
  }
}

void main() {
  testWidgets('shows the welcome dialog on first render', (tester) async {
    await tester.pumpWidget(const FuelwiseApp());
    await tester.pump();

    expect(find.text('Bem-vindo ao Fuelwise'), findsOneWidget);

    await tester.tap(find.text('Entendi'));
    await tester.pump();

    expect(find.text('Bem-vindo ao Fuelwise'), findsNothing);
  });

  testWidgets('renders the Fuelwise comparison form', (tester) async {
    await _pumpAndDismissWelcome(tester);

    expect(find.text('Fuelwise'), findsOneWidget);
    expect(find.text('Padrão (0,70)'), findsOneWidget);
    expect(find.text('Personalizada'), findsOneWidget);
    expect(find.text('Calcular'), findsOneWidget);
  });
}
