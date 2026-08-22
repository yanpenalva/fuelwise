import 'package:flutter_test/flutter_test.dart';

import 'package:workdir/main.dart';

void main() {
  testWidgets('renders the Fuelwise home page', (WidgetTester tester) async {
    await tester.pumpWidget(const FuelwiseApp());

    expect(find.text('Fuelwise'), findsOneWidget);
    expect(
      find.text(
        'Compare etanol e gasolina e descubra qual vale mais a pena abastecer.',
      ),
      findsOneWidget,
    );
  });
}
