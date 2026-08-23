import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/profile/vehicle_profile_controller.dart';
import '../../domain/vehicle_profile.dart';
import '../widgets/fuel_input_field.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<VehicleProfile?> state =
        ref.watch(vehicleProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu veículo'),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : _ProfileForm(initialProfile: state.value),
    );
  }
}

final class _ProfileForm extends ConsumerStatefulWidget {
  const _ProfileForm({required this.initialProfile});

  final VehicleProfile? initialProfile;

  @override
  ConsumerState<_ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends ConsumerState<_ProfileForm> {
  late final TextEditingController _nameController = TextEditingController(
    text: widget.initialProfile?.name ?? '',
  );
  late final TextEditingController _gasolineController = TextEditingController(
    text: _initialConsumption(widget.initialProfile?.gasolineKmPerLiter),
  );
  late final TextEditingController _ethanolController = TextEditingController(
    text: _initialConsumption(widget.initialProfile?.ethanolKmPerLiter),
  );

  String? _nameError;
  String? _gasolineError;
  String? _ethanolError;
  bool _isSubmitting = false;

  static String _initialConsumption(Decimal? value) {
    if (value == null) {
      return '';
    }
    return value.toString().replaceAll('.', ',');
  }

  static Decimal? _parseConsumption(String raw) {
    final String normalized = raw.trim().replaceAll(',', '.');
    if (normalized.isEmpty) {
      return null;
    }
    return Decimal.tryParse(normalized);
  }

  static String? _consumptionError(String raw, Decimal? parsed) {
    if (raw.trim().isEmpty || parsed != null) {
      return null;
    }
    return 'Informe um valor maior que zero.';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _gasolineController.dispose();
    _ethanolController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSubmitting) {
      return;
    }

    final String name = _nameController.text.trim();
    final Decimal? gasoline = _parseConsumption(_gasolineController.text);
    final Decimal? ethanol = _parseConsumption(_ethanolController.text);

    String? nameError;
    String? gasolineError =
        _consumptionError(_gasolineController.text, gasoline);
    String? ethanolError =
        _consumptionError(_ethanolController.text, ethanol);

    VehicleProfile? profile;
    try {
      profile = VehicleProfile(
        name: name,
        gasolineKmPerLiter: gasoline,
        ethanolKmPerLiter: ethanol,
      );
    } on ArgumentError catch (error) {
      final String argumentName = '${error.name}';
      if (argumentName == 'name') {
        nameError = 'Informe o nome do veículo.';
      }
      if (argumentName == 'gasolineKmPerLiter') {
        gasolineError ??= 'Informe um valor maior que zero.';
      }
      if (argumentName == 'ethanolKmPerLiter') {
        ethanolError ??= 'Informe um valor maior que zero.';
      }
    }

    if (profile == null ||
        nameError != null ||
        gasolineError != null ||
        ethanolError != null) {
      setState(() {
        _nameError = nameError;
        _gasolineError = gasolineError;
        _ethanolError = ethanolError;
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await ref.read(vehicleProfileProvider.notifier).save(profile);
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isSubmitting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível salvar o perfil.')),
      );
      return;
    }

    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Perfil salvo.')),
    );
    Navigator.of(context).pop();
  }

  TextFormField _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    String? errorText,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: <TextInputFormatter>[DecimalInputFormatter()],
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        errorText: errorText,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 16,
            children: <Widget>[
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nome do veículo',
                  hintText: 'Ex: Meu carro',
                  errorText: _nameError,
                ),
              ),
              _buildField(
                controller: _gasolineController,
                label: 'Consumo de gasolina (km/L)',
                hint: 'Ex: 10',
                errorText: _gasolineError,
              ),
              _buildField(
                controller: _ethanolController,
                label: 'Consumo de etanol (km/L)',
                hint: 'Ex: 10',
                errorText: _ethanolError,
              ),
              FilledButton(
                onPressed: _isSubmitting ? null : _submit,
                child: Text(_isSubmitting ? 'Salvando...' : 'Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
