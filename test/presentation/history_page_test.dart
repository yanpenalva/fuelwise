import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fuelwise/application/history/calculation_history_repository.dart';
import 'package:fuelwise/application/history/history_controller.dart';
import 'package:fuelwise/domain/calculation_history_entry.dart';
import 'package:fuelwise/domain/fuel_calculation_input.dart';
import 'package:fuelwise/domain/fuel_calculation_result.dart';
import 'package:fuelwise/domain/fuel_type.dart';
import 'package:fuelwise/domain/threshold_source.dart';
import 'package:fuelwise/presentation/pages/history_page.dart';
import 'package:intl/date_symbol_data_local.dart';

final class _FakeCalculationHistoryRepository
    implements CalculationHistoryRepository {
  _FakeCalculationHistoryRepository({this.failDelete = false});

  List<CalculationHistoryEntry> entries = <CalculationHistoryEntry>[];
  final bool failDelete;

  @override
  Future<List<CalculationHistoryEntry>> loadAll() async => List.of(entries);

  @override
  Future<CalculationHistoryEntry> record({
    required FuelCalculationInput input,
    required FuelCalculationResult result,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteById(int id) async {
    if (failDelete) {
      throw Exception('Falha ao excluir o registro.');
    }
    entries.removeWhere((CalculationHistoryEntry entry) => entry.id == id);
  }
}

CalculationHistoryEntry _buildEntry({
  int id = 1,
  DateTime? createdAt,
  Decimal? gasolinePrice,
  Decimal? ethanolPrice,
}) {
  final DateTime resolvedCreatedAt = createdAt ?? DateTime(2026, 8, 20, 14, 30);
  return CalculationHistoryEntry(
    id: id,
    createdAt: resolvedCreatedAt,
    gasolinePrice: gasolinePrice ?? Decimal.parse('6.29'),
    ethanolPrice: ethanolPrice ?? Decimal.parse('4.39'),
    gasolineConsumption: null,
    ethanolConsumption: null,
    recommendedFuel: FuelType.ethanol,
    ratio: Decimal.parse('0.69'),
    appliedThreshold: FuelThreshold.standard,
    thresholdSource: ThresholdSource.standard,
    gasolineCostPerKilometer: null,
    ethanolCostPerKilometer: null,
    maximumEthanolPrice: Decimal.parse('4.40'),
    difference: Decimal.parse('0.01'),
  );
}

Future<void> _pumpHistoryPage(
  WidgetTester tester,
  CalculationHistoryRepository repository,
) {
  return tester.pumpWidget(
    ProviderScope(
      overrides: [
        calculationHistoryRepositoryProvider.overrideWithValue(repository),
      ],
      child: const MaterialApp(home: HistoryPage()),
    ),
  );
}

void main() {
 setUpAll(() {
    initializeDateFormatting('pt_BR');
  });

  testWidgets('shows empty message when no entries exist', (tester) async {
    final _FakeCalculationHistoryRepository repository =
        _FakeCalculationHistoryRepository();

    await _pumpHistoryPage(tester, repository);
    await tester.pumpAndSettle();

    expect(find.text('Nenhum cálculo salvo ainda.'), findsOneWidget);
  });

  testWidgets('renders entries newest first with date and prices',
      (tester) async {
    final _FakeCalculationHistoryRepository repository =
        _FakeCalculationHistoryRepository()
          ..entries = <CalculationHistoryEntry>[
            _buildEntry(
              id: 2,
              createdAt: DateTime(2026, 8, 21, 9, 15),
              gasolinePrice: Decimal.parse('5.99'),
              ethanolPrice: Decimal.parse('4.19'),
            ),
            _buildEntry(
              id: 1,
              createdAt: DateTime(2026, 8, 20, 14, 30),
            ),
          ];

    await _pumpHistoryPage(tester, repository);
    await tester.pumpAndSettle();

    expect(find.text('21/08/2026 09:15'), findsOneWidget);
    expect(find.text('20/08/2026 14:30'), findsOneWidget);
    expect(find.text('Gasolina: R\$ 6,29'), findsOneWidget);
    expect(find.text('Etanol: R\$ 4,39'), findsOneWidget);
    expect(find.text('Gasolina: R\$ 5,99'), findsOneWidget);
    expect(find.text('Etanol: R\$ 4,19'), findsOneWidget);
    expect(find.textContaining('Abasteça com etanol'), findsNWidgets(2));
    expect(find.textContaining('Proporção: 0,69'), findsNWidgets(2));
    expect(find.textContaining('Limiar padrão'), findsNWidgets(2));

    final double newerDy =
        tester.getTopLeft(find.text('21/08/2026 09:15')).dy;
    final double olderDy =
        tester.getTopLeft(find.text('20/08/2026 14:30')).dy;
    expect(newerDy, lessThan(olderDy));
  });

  testWidgets('deletes entry after confirmation', (tester) async {
    final _FakeCalculationHistoryRepository repository =
        _FakeCalculationHistoryRepository()
          ..entries = <CalculationHistoryEntry>[
            _buildEntry(id: 2, createdAt: DateTime(2026, 8, 21, 9, 15)),
            _buildEntry(id: 1),
          ];

    await _pumpHistoryPage(tester, repository);
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.delete_outline).first);
    await tester.pumpAndSettle();

    expect(find.text('Excluir este registro?'), findsOneWidget);
    expect(find.text('Esta ação não pode ser desfeita.'), findsOneWidget);

    await tester.tap(find.text('Excluir'));
    await tester.pumpAndSettle();

    expect(
      repository.entries.where((CalculationHistoryEntry entry) => entry.id == 2),
      isEmpty,
    );
    expect(repository.entries.length, 1);
    expect(find.text('21/08/2026 09:15'), findsNothing);
    expect(find.text('20/08/2026 14:30'), findsOneWidget);
    expect(find.byIcon(Icons.delete_outline), findsOneWidget);
  });

  testWidgets('cancel keeps entry', (tester) async {
    final _FakeCalculationHistoryRepository repository =
        _FakeCalculationHistoryRepository()
          ..entries = <CalculationHistoryEntry>[_buildEntry(id: 1)];

    await _pumpHistoryPage(tester, repository);
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();

    expect(repository.entries.length, 1);
    expect(find.byIcon(Icons.delete_outline), findsOneWidget);
  });

  testWidgets('delete failure shows error SnackBar and keeps tile',
      (tester) async {
    final _FakeCalculationHistoryRepository repository =
        _FakeCalculationHistoryRepository(failDelete: true)
          ..entries = <CalculationHistoryEntry>[_buildEntry(id: 1)];

    await _pumpHistoryPage(tester, repository);
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Excluir'));
    await tester.pumpAndSettle();

    expect(
      find.text('Não foi possível excluir o registro.'),
      findsOneWidget,
    );
    expect(repository.entries.length, 1);
    expect(find.byIcon(Icons.delete_outline), findsOneWidget);
  });
}
