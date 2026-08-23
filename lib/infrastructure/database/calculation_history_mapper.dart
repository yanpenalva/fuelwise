import 'package:decimal/decimal.dart';

import 'package:fuelwise/domain/calculation_history_entry.dart';
import 'package:fuelwise/domain/fuel_type.dart';
import 'package:fuelwise/domain/threshold_source.dart';
import 'package:fuelwise/infrastructure/database/app_database.dart';
import 'package:fuelwise/infrastructure/database/calculation_history_storage_exception.dart';

final class CalculationHistoryMapper {
  const CalculationHistoryMapper();

  CalculationHistoryEntry toDomain(HistoryEntryRow row) {
    return CalculationHistoryEntry(
      id: row.id,
      createdAt: row.createdAt,
      gasolinePrice: _toRequiredDecimal(row.gasolinePrice, 'gasolinePrice'),
      ethanolPrice: _toRequiredDecimal(row.ethanolPrice, 'ethanolPrice'),
      gasolineConsumption:
          _toDecimal(row.gasolineConsumption, 'gasolineConsumption'),
      ethanolConsumption:
          _toDecimal(row.ethanolConsumption, 'ethanolConsumption'),
      recommendedFuel: _toEnum(FuelType.values, row.recommendedFuel, 'recommendedFuel'),
      ratio: _toRequiredDecimal(row.ratio, 'ratio'),
      appliedThreshold:
          _toRequiredDecimal(row.appliedThreshold, 'appliedThreshold'),
      thresholdSource:
          _toEnum(ThresholdSource.values, row.thresholdSource, 'thresholdSource'),
      gasolineCostPerKilometer:
          _toDecimal(row.gasolineCostPerKm, 'gasolineCostPerKm'),
      ethanolCostPerKilometer:
          _toDecimal(row.ethanolCostPerKm, 'ethanolCostPerKm'),
      maximumEthanolPrice:
          _toRequiredDecimal(row.maximumEthanolPrice, 'maximumEthanolPrice'),
      difference: _toRequiredDecimal(row.difference, 'difference'),
    );
  }

  Decimal? _toDecimal(String? raw, String fieldName) {
    if (raw == null) {
      return null;
    }

    return _parse(raw, fieldName);
  }

  Decimal _toRequiredDecimal(String raw, String fieldName) {
    final value = _parse(raw, fieldName);

    if (value == null) {
      throw CalculationHistoryStorageException(fieldName, raw);
    }

    return value;
  }

  Decimal? _parse(String raw, String fieldName) {
    final normalized = raw.trim().replaceAll(',', '.');
    final value = Decimal.tryParse(normalized);

    if (value == null) {
      throw CalculationHistoryStorageException(fieldName, raw);
    }

    return value;
  }

  T _toEnum<T extends Enum>(List<T> values, String raw, String fieldName) {
    for (final value in values) {
      if (value.name == raw) {
        return value;
      }
    }

    throw CalculationHistoryStorageException(fieldName, raw);
  }
}
