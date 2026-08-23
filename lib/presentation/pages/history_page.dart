import 'dart:async';

import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../application/export/history_export_controller.dart';
import '../../application/history/history_controller.dart';
import '../../application/profile/vehicle_profile_controller.dart';
import '../../domain/calculation_history_entry.dart';
import '../../domain/fuel_type.dart';
import '../../domain/threshold_source.dart';
import '../../infrastructure/export/system_export_notifier.dart';

class HistoryPage extends ConsumerWidget {
  const HistoryPage({super.key});

  static final DateFormat _dateFormat = DateFormat('dd/MM/yyyy HH:mm', 'pt_BR');

  static String _formatMoney(Decimal value) {
    return 'R\$ ${_formatScaled(value, 2)}';
  }

  static String _formatRatio(Decimal value) {
    return _formatScaled(value, 2);
  }

  static String _formatScaled(Decimal value, int scale) {
    final bool isNegative = value < Decimal.zero;
    final Decimal absolute = isNegative ? -value : value;
    final BigInt smallestUnits = (absolute * Decimal.fromInt(_pow10(scale)))
        .round()
        .toBigInt();
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
    final AsyncValue<List<CalculationHistoryEntry>> history = ref.watch(
      historyProvider,
    );
    final bool isExporting =
        ref.watch(historyExportProvider) is HistoryExporting;
    final String? vehicleName = ref.watch(vehicleProfileProvider).value?.name;

    ref.listen<HistoryExportStatus>(historyExportProvider, (
      HistoryExportStatus? previous,
      HistoryExportStatus next,
    ) {
      if (next is HistoryExportReady &&
          (previous is! HistoryExportReady ||
              previous.exportId != next.exportId)) {
        unawaited(_publishExport(context, ref, next));
      }
      if (next is HistoryExportFailure &&
          (previous is! HistoryExportFailure ||
              previous.exportId != next.exportId)) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Não foi possível exportar o histórico.'),
            ),
          );
        }
        unawaited(ref.read(historyExportProvider.notifier).reset());
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Histórico')),
      body: history.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object error, StackTrace stackTrace) =>
            _buildError(context, ref),
        data: (List<CalculationHistoryEntry> entries) => entries.isEmpty
            ? _buildEmpty(context)
            : _buildList(context, ref, entries, vehicleName, isExporting),
      ),
    );
  }

  static Future<void> _publishExport(
    BuildContext context,
    WidgetRef ref,
    HistoryExportReady ready,
  ) async {
    final SystemExportNotifier notifier = SystemExportNotifier();
    final String fileName = ready.filePath.split('/').last;
    String? notificationWarning;

    try {
      final bool permissionGranted = await notifier.ensurePermission();
      if (permissionGranted) {
        await notifier.notifyExportReady(fileName);
      }
      if (!permissionGranted) {
        notificationWarning =
            'Arquivo exportado, mas as notificações estão desativadas.';
      }
    } catch (_) {
      notificationWarning =
          'Arquivo exportado, mas não foi possível exibir a notificação.';
    }

    try {
      await SharePlus.instance.share(
        ShareParams(
          files: <XFile>[XFile(ready.filePath, mimeType: 'text/csv')],
          subject: 'Fuelwise — Exportação do histórico',
        ),
      );
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'O arquivo foi gerado, mas não foi possível abrir o compartilhamento.',
            ),
          ),
        );
        await ref.read(historyExportProvider.notifier).reset();
      }
      return;
    }

    if (context.mounted && notificationWarning != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(notificationWarning)));
    }
    if (context.mounted) {
      await ref.read(historyExportProvider.notifier).reset();
    }
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
        style: Theme.of(context).textTheme.bodyMedium
            ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
    );
  }

  Widget _buildList(
    BuildContext context,
    WidgetRef ref,
    List<CalculationHistoryEntry> entries,
    String? vehicleName,
    bool isExporting,
  ) {
    final List<(String, List<CalculationHistoryEntry>)> months = _groupByMonth(
      entries,
    );

    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        for (final (String month, List<CalculationHistoryEntry> monthEntries)
            in months)
          _MonthSection(
            month: month,
            count: monthEntries.length,
            entries: monthEntries,
            onDelete: (CalculationHistoryEntry entry) =>
                unawaited(_confirmDelete(context, ref, entry)),
            onExportEntry: isExporting
                ? null
                : (CalculationHistoryEntry entry) => unawaited(
                    ref
                        .read(historyExportProvider.notifier)
                        .export(
                          entries: <CalculationHistoryEntry>[entry],
                          vehicleName: vehicleName,
                        ),
                  ),
            onExportMonth: isExporting
                ? null
                : () => unawaited(
                    ref
                        .read(historyExportProvider.notifier)
                        .export(
                          entries: monthEntries,
                          vehicleName: vehicleName,
                        ),
                  ),
          ),
      ],
    );
  }

  static List<(String, List<CalculationHistoryEntry>)> _groupByMonth(
    List<CalculationHistoryEntry> entries,
  ) {
    final List<(String, List<CalculationHistoryEntry>)> months =
        <(String, List<CalculationHistoryEntry>)>[];
    String? currentMonth;

    for (final CalculationHistoryEntry entry in entries) {
      final DateTime local = entry.createdAt.toLocal();
      final String month = '${_monthNames[local.month - 1]} de ${local.year}';
      if (month != currentMonth) {
        currentMonth = month;
        months.add((month, <CalculationHistoryEntry>[]));
      }
      months.last.$2.add(entry);
    }

    return months;
  }

  static const List<String> _monthNames = <String>[
    'janeiro',
    'fevereiro',
    'março',
    'abril',
    'maio',
    'junho',
    'julho',
    'agosto',
    'setembro',
    'outubro',
    'novembro',
    'dezembro',
  ];

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
        const SnackBar(content: Text('Não foi possível excluir o registro.')),
      );
    }
  }
}

final class _MonthSection extends StatelessWidget {
  const _MonthSection({
    required this.month,
    required this.count,
    required this.entries,
    required this.onDelete,
    required this.onExportEntry,
    required this.onExportMonth,
  });

  final String month;
  final int count;
  final List<CalculationHistoryEntry> entries;
  final void Function(CalculationHistoryEntry entry) onDelete;
  final void Function(CalculationHistoryEntry entry)? onExportEntry;
  final VoidCallback? onExportMonth;

  static String _capitalize(String value) {
    if (value.isEmpty) {
      return value;
    }
    return value[0].toUpperCase() + value.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      shape: const Border(),
      collapsedShape: const Border(),
      title: Text(_capitalize(month)),
      subtitle: Text(count == 1 ? '1 registro' : '$count registros'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          IconButton(
            icon: const Icon(Icons.ios_share),
            tooltip: 'Exportar mês',
            onPressed: onExportMonth,
          ),
          const Icon(Icons.expand_more),
        ],
      ),
      children: <Widget>[
        for (final CalculationHistoryEntry entry in entries)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Card(
              elevation: 0,
              margin: EdgeInsets.zero,
              child: ListTile(
                title: Text(
                  HistoryPage._dateFormat.format(entry.createdAt.toLocal()),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 4,
                  children: <Widget>[
                    Text(
                      HistoryPage._recommendationLabel(entry.recommendedFuel),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Gasolina: ${HistoryPage._formatMoney(entry.gasolinePrice)}',
                    ),
                    Text(
                      'Etanol: ${HistoryPage._formatMoney(entry.ethanolPrice)}',
                    ),
                    Text(
                      'Proporção: ${HistoryPage._formatRatio(entry.ratio)}'
                      ' · ${HistoryPage._thresholdLabel(entry.thresholdSource)}',
                    ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    IconButton(
                      icon: const Icon(Icons.ios_share),
                      tooltip: 'Exportar registro',
                      onPressed: () => onExportEntry?.call(entry),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => onDelete(entry),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
