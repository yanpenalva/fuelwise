import 'dart:async';

import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../application/history/history_controller.dart';
import '../../domain/calculation_history_entry.dart';
import '../../domain/fuel_type.dart';
import '../../domain/threshold_source.dart';

class HistoryPage extends ConsumerWidget {
  const HistoryPage({super.key});

  static final DateFormat _dateFormat =
      DateFormat('dd/MM/yyyy HH:mm', 'pt_BR');

  static String _formatMoney(Decimal value) {
    return 'R\$ ${_formatScaled(value, 2)}';
  }

  static String _formatRatio(Decimal value) {
    return _formatScaled(value, 2);
  }

  static String _formatScaled(Decimal value, int scale) {
    final bool isNegative = value < Decimal.zero;
    final Decimal absolute = isNegative ? -value : value;
    final BigInt smallestUnits =
        (absolute * Decimal.fromInt(_pow10(scale))).round().toBigInt();
    final String digits = smallestUnits.toString().padLeft(scale + 1, '0');
    final String intPart = digits.substring(0, digits.length - scale);
    final String fracPart = digits.substring(digits.length - scale);
    final NumberFormat integerFormat = NumberFormat('#,##0', 'pt_BR');
    final String sign = isNegative ? '-' : '';

    return '$sign${integerFormat.format(int.parse(intPart))},$fracPart';
  }

  static int _pow10(int exponent) {
    var result = 1;

    for (var i = 0; i < exponent; i++) {
      result *= 10;
    }

    return result;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<CalculationHistoryEntry>> history =
        ref.watch(historyProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico'),
      ),
      body: history.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object error, StackTrace stackTrace) =>
            _buildError(context, ref),
        data: (List<CalculationHistoryEntry> entries) => entries.isEmpty
            ? _buildEmpty(context)
            : _buildList(context, ref, entries),
      ),
    );
  }

  Widget _buildError(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 16,
        children: <Widget>[
          const Text('Não foi possível carregar o histórico.'),
          FilledButton(
            onPressed: () => ref.invalidate(historyProvider),
            child: const Text('Tentar novamente'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Text(
        'Nenhum cálculo salvo ainda.',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
      ),
    );
  }

  Widget _buildList(
    BuildContext context,
    WidgetRef ref,
    List<CalculationHistoryEntry> entries,
  ) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: entries.length,
      separatorBuilder: (BuildContext context, int index) =>
          const SizedBox(height: 8),
      itemBuilder: (BuildContext context, int index) {
        final CalculationHistoryEntry entry = entries[index];
        return Card(
          elevation: 0,
          margin: EdgeInsets.zero,
          child: ListTile(
            title: Text(_dateFormat.format(entry.createdAt.toLocal())),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 4,
              children: <Widget>[
                Text(
                  _recommendationLabel(entry.recommendedFuel),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                Text('Gasolina: ${_formatMoney(entry.gasolinePrice)}'),
                Text('Etanol: ${_formatMoney(entry.ethanolPrice)}'),
                Text(
                  'Proporção: ${_formatRatio(entry.ratio)}'
                  ' · ${_thresholdLabel(entry.thresholdSource)}',
                ),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => unawaited(_confirmDelete(context, ref, entry)),
            ),
          ),
        );
      },
    );
  }

  static String _recommendationLabel(FuelType type) {
    return switch (type) {
      FuelType.ethanol => 'Abasteça com etanol',
      FuelType.gasoline => 'Abasteça com gasolina',
    };
  }

  static String _thresholdLabel(ThresholdSource source) {
    return switch (source) {
      ThresholdSource.standard => 'Limiar padrão',
      ThresholdSource.custom => 'Limiar personalizada',
    };
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    CalculationHistoryEntry entry,
  ) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Excluir este registro?'),
          content: const Text('Esta ação não pode ser desfeita.'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    try {
      await ref.read(historyProvider.notifier).deleteById(entry.id);
    } catch (_) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível excluir o registro.'),
        ),
      );
    }
  }
}
