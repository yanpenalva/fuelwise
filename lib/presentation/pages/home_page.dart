import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/comparison/comparison_form_controller.dart';
import '../../application/comparison/comparison_form_state.dart';
import '../../application/preferences/app_preferences_controller.dart';
import '../../application/preferences/app_preferences_data.dart';
import '../../application/preferences/rule_mode.dart';
import '../../application/preferences/theme_mode_preference.dart';
import '../../domain/fuel_calculation_result.dart';
import '../release/app_release.dart';
import '../widgets/fuel_input_field.dart';
import '../widgets/result_view.dart';
import 'history_page.dart';
import 'profile_page.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  static const String _slogan = 'Combustível certo, custo consciente.';
  static const Duration _minimumSplashDuration = Duration(seconds: 1);

  Timer? _splashTimer;

  final TextEditingController _gasolinePriceController =
      TextEditingController();
  final TextEditingController _ethanolPriceController =
      TextEditingController();
  final TextEditingController _gasolineConsumptionController =
      TextEditingController();
  final TextEditingController _ethanolConsumptionController =
      TextEditingController();

  bool _welcomeDialogShown = false;

  @override
  void initState() {
    super.initState();
    _splashTimer = Timer(_minimumSplashDuration, () {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _splashTimer?.cancel();
    _gasolinePriceController.dispose();
    _ethanolPriceController.dispose();
    _gasolineConsumptionController.dispose();
    _ethanolConsumptionController.dispose();
    super.dispose();
  }

  void _maybeShowWelcomeDialog() {
    final AsyncValue<AppPreferencesData> preferences =
        ref.watch(appPreferencesProvider);

    final AppPreferencesData? data = preferences.value;
    if (data == null || data.hasSeenWelcome || _welcomeDialogShown) {
      return;
    }

    _welcomeDialogShown = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      unawaited(_showWelcomeDialog());
    });
  }

  Future<void> _showWelcomeDialog() async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Bem-vindo ao Fuelwise'),
          content: const SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8,
              children: <Widget>[
                Text(
                  'Descubra qual combustível compensa mais abastecer hoje.',
                ),
                Text('1. Informe o preço do litro da gasolina e do etanol.'),
                Text(
                  '2. Opcionalmente, informe quantos km seu carro anda por litro com cada combustível.',
                ),
                Text(
                  '3. Toque em Calcular e veja a recomendação, os custos por km e até quanto o etanol pode custar para valer a pena.',
                ),
              ],
            ),
          ),
          actions: <Widget>[
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Entendi'),
            ),
          ],
        );
      },
    );

    try {
      await ref.read(appPreferencesProvider.notifier).markWelcomeSeen();
    } catch (_) {
      _showSnackbar(
        'Não foi possível lembrar desta mensagem no próximo acesso.',
        error: true,
      );
    }
  }

  void _onFormStateChanged(
    ComparisonFormState? previous,
    ComparisonFormState next,
  ) {
    final HistorySaveStatus previousStatus =
        previous?.historySave ?? const HistorySaveIdle();
    final HistorySaveStatus status = next.historySave;

    if (status is HistorySaveFailure && previousStatus is! HistorySaveFailure) {
      _showSnackbar(status.message, error: true);
    }
  }

  void _showSnackbar(String message, {required bool error}) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            error ? Theme.of(context).colorScheme.error : null,
      ),
    );
  }

  void _selectRule(Set<RuleMode> selection) {
    ref.read(appPreferencesProvider.notifier).selectRule(selection.first);
  }

  void _cycleThemeMode(ThemeModePreference current) {
    final ThemeModePreference next = _nextThemeMode(current);
    ref.read(appPreferencesProvider.notifier).selectThemeMode(next);
  }

  static ThemeModePreference _nextThemeMode(ThemeModePreference current) {
    return switch (current) {
      ThemeModePreference.system => ThemeModePreference.light,
      ThemeModePreference.light => ThemeModePreference.dark,
      ThemeModePreference.dark => ThemeModePreference.system,
    };
  }

  static IconData _themeModeIcon(ThemeModePreference mode) {
    return switch (mode) {
      ThemeModePreference.system => Icons.brightness_auto,
      ThemeModePreference.light => Icons.light_mode,
      ThemeModePreference.dark => Icons.dark_mode,
    };
  }

  void _submit() {
    ref
        .read(comparisonFormProvider.notifier)
        .submit(
          gasolinePriceText: CurrencyInputFormatter.toParserInput(
            _gasolinePriceController.text,
          ),
          ethanolPriceText: CurrencyInputFormatter.toParserInput(
            _ethanolPriceController.text,
          ),
          gasolineConsumptionText: _gasolineConsumptionController.text,
          ethanolConsumptionText: _ethanolConsumptionController.text,
        );
  }

  void _startNewCalculation() {
    ref.read(comparisonFormProvider.notifier).reset();
    _gasolinePriceController.clear();
    _ethanolPriceController.clear();
    _gasolineConsumptionController.clear();
    _ethanolConsumptionController.clear();
  }

  Widget _buildForm(ComparisonFormState form, RuleMode ruleMode) {
    return SingleChildScrollView(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 16,
            children: <Widget>[
              Card(
                elevation: 0,
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.local_gas_station,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Compare os preços e descubra qual combustível '
                          'rende mais para o seu bolso.',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              FuelInputField(
                label: 'Preço da gasolina',
                controller: _gasolinePriceController,
                errorText: form.gasolinePriceError,
                prefixText: 'R\$ ',
                hintText: '6,29',
                useCurrencyMask: true,
              ),
              FuelInputField(
                label: 'Preço do etanol',
                controller: _ethanolPriceController,
                errorText: form.ethanolPriceError,
                prefixText: 'R\$ ',
                hintText: '4,59',
                useCurrencyMask: true,
              ),
              FuelInputField(
                label: 'Consumo de gasolina',
                controller: _gasolineConsumptionController,
                errorText: form.gasolineConsumptionError,
                suffixText: 'L',
                hintText: 'Ex: 10',
                helperText: 'Quantos km por litro na gasolina (opcional)',
              ),
              FuelInputField(
                label: 'Consumo de etanol',
                controller: _ethanolConsumptionController,
                errorText: form.ethanolConsumptionError,
                suffixText: 'L',
                hintText: 'Ex: 7',
                helperText: 'Quantos km por litro no etanol (opcional)',
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 8,
                children: <Widget>[
                  SegmentedButton<RuleMode>(
                    segments: const <ButtonSegment<RuleMode>>[
                      ButtonSegment<RuleMode>(
                        value: RuleMode.standard,
                        label: Text('Padrão (0,70)'),
                      ),
                      ButtonSegment<RuleMode>(
                        value: RuleMode.custom,
                        icon: Icon(Icons.directions_car),
                        label: Text('Personalizada'),
                      ),
                    ],
                    selected: <RuleMode>{ruleMode},
                    onSelectionChanged: _selectRule,
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: ruleMode == RuleMode.custom
                        ? Text(
                            'O limiar será calculado pela divisão do consumo '
                            'do etanol pelo da gasolina informados acima.',
                            key: const ValueKey<String>('custom-helper'),
                            style: Theme.of(context).textTheme.bodySmall,
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
              FilledButton.icon(
                onPressed: form.isSubmitting ? null : _submit,
                icon: form.isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.calculate),
                label: Text(form.isSubmitting ? 'Calculando...' : 'Calcular'),
              ),
              Center(
                child: Text(
                  AppRelease.label,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResult(FuelCalculationResult result) {
    final HistorySaveStatus historySave =
        ref.watch(comparisonFormProvider).historySave;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(child: ResultView(result: result)),
            const SizedBox(height: 8),
            FilledButton.tonalIcon(
              onPressed: _startNewCalculation,
              icon: const Icon(Icons.refresh),
              label: const Text('Novo cálculo'),
            ),
            const SizedBox(height: 4),
            Text(
              switch (historySave) {
                HistorySaveIdle() => '',
                HistorySaveSaving() => 'Salvando no histórico...',
                HistorySaveSuccess() => 'Salvo no histórico.',
                HistorySaveFailure() => '',
              },
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLaunchLoading() {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                Icons.local_gas_station,
                size: 48,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 12),
              Text(
                'Fuelwise',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                _slogan,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 24),
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _maybeShowWelcomeDialog();
    final AsyncValue<AppPreferencesData> preferences =
        ref.watch(appPreferencesProvider);

    if (preferences.isLoading || _splashTimer?.isActive == true) {
      return _buildLaunchLoading();
    }

    final ComparisonFormState form = ref.watch(comparisonFormProvider);
    final RuleMode ruleMode =
        ref.watch(appPreferencesProvider).value?.ruleMode ?? RuleMode.standard;

    ref.listen<ComparisonFormState>(
      comparisonFormProvider,
      _onFormStateChanged,
    );

    final FuelCalculationResult? result = form.result;
    final ThemeModePreference themeMode =
        preferences.value?.themeMode ?? ThemeModePreference.system;
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: <Widget>[
            Icon(
              Icons.local_gas_station,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            const Flexible(
              child: Text(
                'Fuelwise',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(_themeModeIcon(themeMode)),
            tooltip: 'Alternar tema',
            onPressed: () => _cycleThemeMode(themeMode),
          ),
          IconButton(
            icon: const Icon(Icons.directions_car),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (BuildContext context) => const ProfilePage(),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (BuildContext context) => const HistoryPage(),
              ),
            ),
          ),
        ],
      ),
      body: result == null ? _buildForm(form, ruleMode) : _buildResult(result),
    );
  }
}
