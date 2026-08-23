// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $VehicleProfilesTable extends VehicleProfiles
    with TableInfo<$VehicleProfilesTable, VehicleProfileRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VehicleProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _gasolineKmPerLiterMeta =
      const VerificationMeta('gasolineKmPerLiter');
  @override
  late final GeneratedColumn<String> gasolineKmPerLiter =
      GeneratedColumn<String>(
        'gasoline_km_per_liter',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _ethanolKmPerLiterMeta = const VerificationMeta(
    'ethanolKmPerLiter',
  );
  @override
  late final GeneratedColumn<String> ethanolKmPerLiter =
      GeneratedColumn<String>(
        'ethanol_km_per_liter',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    gasolineKmPerLiter,
    ethanolKmPerLiter,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'vehicle_profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<VehicleProfileRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('gasoline_km_per_liter')) {
      context.handle(
        _gasolineKmPerLiterMeta,
        gasolineKmPerLiter.isAcceptableOrUnknown(
          data['gasoline_km_per_liter']!,
          _gasolineKmPerLiterMeta,
        ),
      );
    }
    if (data.containsKey('ethanol_km_per_liter')) {
      context.handle(
        _ethanolKmPerLiterMeta,
        ethanolKmPerLiter.isAcceptableOrUnknown(
          data['ethanol_km_per_liter']!,
          _ethanolKmPerLiterMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  VehicleProfileRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VehicleProfileRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      gasolineKmPerLiter: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}gasoline_km_per_liter'],
      ),
      ethanolKmPerLiter: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ethanol_km_per_liter'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $VehicleProfilesTable createAlias(String alias) {
    return $VehicleProfilesTable(attachedDatabase, alias);
  }
}

class VehicleProfileRow extends DataClass
    implements Insertable<VehicleProfileRow> {
  final int id;
  final String name;
  final String? gasolineKmPerLiter;
  final String? ethanolKmPerLiter;
  final DateTime updatedAt;
  const VehicleProfileRow({
    required this.id,
    required this.name,
    this.gasolineKmPerLiter,
    this.ethanolKmPerLiter,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || gasolineKmPerLiter != null) {
      map['gasoline_km_per_liter'] = Variable<String>(gasolineKmPerLiter);
    }
    if (!nullToAbsent || ethanolKmPerLiter != null) {
      map['ethanol_km_per_liter'] = Variable<String>(ethanolKmPerLiter);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  VehicleProfilesCompanion toCompanion(bool nullToAbsent) {
    return VehicleProfilesCompanion(
      id: Value(id),
      name: Value(name),
      gasolineKmPerLiter: gasolineKmPerLiter == null && nullToAbsent
          ? const Value.absent()
          : Value(gasolineKmPerLiter),
      ethanolKmPerLiter: ethanolKmPerLiter == null && nullToAbsent
          ? const Value.absent()
          : Value(ethanolKmPerLiter),
      updatedAt: Value(updatedAt),
    );
  }

  factory VehicleProfileRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VehicleProfileRow(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      gasolineKmPerLiter: serializer.fromJson<String?>(
        json['gasolineKmPerLiter'],
      ),
      ethanolKmPerLiter: serializer.fromJson<String?>(
        json['ethanolKmPerLiter'],
      ),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'gasolineKmPerLiter': serializer.toJson<String?>(gasolineKmPerLiter),
      'ethanolKmPerLiter': serializer.toJson<String?>(ethanolKmPerLiter),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  VehicleProfileRow copyWith({
    int? id,
    String? name,
    Value<String?> gasolineKmPerLiter = const Value.absent(),
    Value<String?> ethanolKmPerLiter = const Value.absent(),
    DateTime? updatedAt,
  }) => VehicleProfileRow(
    id: id ?? this.id,
    name: name ?? this.name,
    gasolineKmPerLiter: gasolineKmPerLiter.present
        ? gasolineKmPerLiter.value
        : this.gasolineKmPerLiter,
    ethanolKmPerLiter: ethanolKmPerLiter.present
        ? ethanolKmPerLiter.value
        : this.ethanolKmPerLiter,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  VehicleProfileRow copyWithCompanion(VehicleProfilesCompanion data) {
    return VehicleProfileRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      gasolineKmPerLiter: data.gasolineKmPerLiter.present
          ? data.gasolineKmPerLiter.value
          : this.gasolineKmPerLiter,
      ethanolKmPerLiter: data.ethanolKmPerLiter.present
          ? data.ethanolKmPerLiter.value
          : this.ethanolKmPerLiter,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VehicleProfileRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('gasolineKmPerLiter: $gasolineKmPerLiter, ')
          ..write('ethanolKmPerLiter: $ethanolKmPerLiter, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, gasolineKmPerLiter, ethanolKmPerLiter, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VehicleProfileRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.gasolineKmPerLiter == this.gasolineKmPerLiter &&
          other.ethanolKmPerLiter == this.ethanolKmPerLiter &&
          other.updatedAt == this.updatedAt);
}

class VehicleProfilesCompanion extends UpdateCompanion<VehicleProfileRow> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> gasolineKmPerLiter;
  final Value<String?> ethanolKmPerLiter;
  final Value<DateTime> updatedAt;
  const VehicleProfilesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.gasolineKmPerLiter = const Value.absent(),
    this.ethanolKmPerLiter = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  VehicleProfilesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.gasolineKmPerLiter = const Value.absent(),
    this.ethanolKmPerLiter = const Value.absent(),
    required DateTime updatedAt,
  }) : name = Value(name),
       updatedAt = Value(updatedAt);
  static Insertable<VehicleProfileRow> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? gasolineKmPerLiter,
    Expression<String>? ethanolKmPerLiter,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (gasolineKmPerLiter != null)
        'gasoline_km_per_liter': gasolineKmPerLiter,
      if (ethanolKmPerLiter != null) 'ethanol_km_per_liter': ethanolKmPerLiter,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  VehicleProfilesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? gasolineKmPerLiter,
    Value<String?>? ethanolKmPerLiter,
    Value<DateTime>? updatedAt,
  }) {
    return VehicleProfilesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      gasolineKmPerLiter: gasolineKmPerLiter ?? this.gasolineKmPerLiter,
      ethanolKmPerLiter: ethanolKmPerLiter ?? this.ethanolKmPerLiter,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (gasolineKmPerLiter.present) {
      map['gasoline_km_per_liter'] = Variable<String>(gasolineKmPerLiter.value);
    }
    if (ethanolKmPerLiter.present) {
      map['ethanol_km_per_liter'] = Variable<String>(ethanolKmPerLiter.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VehicleProfilesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('gasolineKmPerLiter: $gasolineKmPerLiter, ')
          ..write('ethanolKmPerLiter: $ethanolKmPerLiter, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $HistoryEntriesTable extends HistoryEntries
    with TableInfo<$HistoryEntriesTable, HistoryEntryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HistoryEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _gasolinePriceMeta = const VerificationMeta(
    'gasolinePrice',
  );
  @override
  late final GeneratedColumn<String> gasolinePrice = GeneratedColumn<String>(
    'gasoline_price',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ethanolPriceMeta = const VerificationMeta(
    'ethanolPrice',
  );
  @override
  late final GeneratedColumn<String> ethanolPrice = GeneratedColumn<String>(
    'ethanol_price',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _gasolineConsumptionMeta =
      const VerificationMeta('gasolineConsumption');
  @override
  late final GeneratedColumn<String> gasolineConsumption =
      GeneratedColumn<String>(
        'gasoline_consumption',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _ethanolConsumptionMeta =
      const VerificationMeta('ethanolConsumption');
  @override
  late final GeneratedColumn<String> ethanolConsumption =
      GeneratedColumn<String>(
        'ethanol_consumption',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _recommendedFuelMeta = const VerificationMeta(
    'recommendedFuel',
  );
  @override
  late final GeneratedColumn<String> recommendedFuel = GeneratedColumn<String>(
    'recommended_fuel',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ratioMeta = const VerificationMeta('ratio');
  @override
  late final GeneratedColumn<String> ratio = GeneratedColumn<String>(
    'ratio',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _appliedThresholdMeta = const VerificationMeta(
    'appliedThreshold',
  );
  @override
  late final GeneratedColumn<String> appliedThreshold = GeneratedColumn<String>(
    'applied_threshold',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _thresholdSourceMeta = const VerificationMeta(
    'thresholdSource',
  );
  @override
  late final GeneratedColumn<String> thresholdSource = GeneratedColumn<String>(
    'threshold_source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _gasolineCostPerKmMeta = const VerificationMeta(
    'gasolineCostPerKm',
  );
  @override
  late final GeneratedColumn<String> gasolineCostPerKm =
      GeneratedColumn<String>(
        'gasoline_cost_per_km',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _ethanolCostPerKmMeta = const VerificationMeta(
    'ethanolCostPerKm',
  );
  @override
  late final GeneratedColumn<String> ethanolCostPerKm = GeneratedColumn<String>(
    'ethanol_cost_per_km',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _maximumEthanolPriceMeta =
      const VerificationMeta('maximumEthanolPrice');
  @override
  late final GeneratedColumn<String> maximumEthanolPrice =
      GeneratedColumn<String>(
        'maximum_ethanol_price',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _differenceMeta = const VerificationMeta(
    'difference',
  );
  @override
  late final GeneratedColumn<String> difference = GeneratedColumn<String>(
    'difference',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    gasolinePrice,
    ethanolPrice,
    gasolineConsumption,
    ethanolConsumption,
    recommendedFuel,
    ratio,
    appliedThreshold,
    thresholdSource,
    gasolineCostPerKm,
    ethanolCostPerKm,
    maximumEthanolPrice,
    difference,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'history_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<HistoryEntryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('gasoline_price')) {
      context.handle(
        _gasolinePriceMeta,
        gasolinePrice.isAcceptableOrUnknown(
          data['gasoline_price']!,
          _gasolinePriceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_gasolinePriceMeta);
    }
    if (data.containsKey('ethanol_price')) {
      context.handle(
        _ethanolPriceMeta,
        ethanolPrice.isAcceptableOrUnknown(
          data['ethanol_price']!,
          _ethanolPriceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_ethanolPriceMeta);
    }
    if (data.containsKey('gasoline_consumption')) {
      context.handle(
        _gasolineConsumptionMeta,
        gasolineConsumption.isAcceptableOrUnknown(
          data['gasoline_consumption']!,
          _gasolineConsumptionMeta,
        ),
      );
    }
    if (data.containsKey('ethanol_consumption')) {
      context.handle(
        _ethanolConsumptionMeta,
        ethanolConsumption.isAcceptableOrUnknown(
          data['ethanol_consumption']!,
          _ethanolConsumptionMeta,
        ),
      );
    }
    if (data.containsKey('recommended_fuel')) {
      context.handle(
        _recommendedFuelMeta,
        recommendedFuel.isAcceptableOrUnknown(
          data['recommended_fuel']!,
          _recommendedFuelMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_recommendedFuelMeta);
    }
    if (data.containsKey('ratio')) {
      context.handle(
        _ratioMeta,
        ratio.isAcceptableOrUnknown(data['ratio']!, _ratioMeta),
      );
    } else if (isInserting) {
      context.missing(_ratioMeta);
    }
    if (data.containsKey('applied_threshold')) {
      context.handle(
        _appliedThresholdMeta,
        appliedThreshold.isAcceptableOrUnknown(
          data['applied_threshold']!,
          _appliedThresholdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_appliedThresholdMeta);
    }
    if (data.containsKey('threshold_source')) {
      context.handle(
        _thresholdSourceMeta,
        thresholdSource.isAcceptableOrUnknown(
          data['threshold_source']!,
          _thresholdSourceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_thresholdSourceMeta);
    }
    if (data.containsKey('gasoline_cost_per_km')) {
      context.handle(
        _gasolineCostPerKmMeta,
        gasolineCostPerKm.isAcceptableOrUnknown(
          data['gasoline_cost_per_km']!,
          _gasolineCostPerKmMeta,
        ),
      );
    }
    if (data.containsKey('ethanol_cost_per_km')) {
      context.handle(
        _ethanolCostPerKmMeta,
        ethanolCostPerKm.isAcceptableOrUnknown(
          data['ethanol_cost_per_km']!,
          _ethanolCostPerKmMeta,
        ),
      );
    }
    if (data.containsKey('maximum_ethanol_price')) {
      context.handle(
        _maximumEthanolPriceMeta,
        maximumEthanolPrice.isAcceptableOrUnknown(
          data['maximum_ethanol_price']!,
          _maximumEthanolPriceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_maximumEthanolPriceMeta);
    }
    if (data.containsKey('difference')) {
      context.handle(
        _differenceMeta,
        difference.isAcceptableOrUnknown(data['difference']!, _differenceMeta),
      );
    } else if (isInserting) {
      context.missing(_differenceMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  HistoryEntryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HistoryEntryRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      gasolinePrice: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}gasoline_price'],
      )!,
      ethanolPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ethanol_price'],
      )!,
      gasolineConsumption: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}gasoline_consumption'],
      ),
      ethanolConsumption: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ethanol_consumption'],
      ),
      recommendedFuel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recommended_fuel'],
      )!,
      ratio: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ratio'],
      )!,
      appliedThreshold: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}applied_threshold'],
      )!,
      thresholdSource: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}threshold_source'],
      )!,
      gasolineCostPerKm: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}gasoline_cost_per_km'],
      ),
      ethanolCostPerKm: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ethanol_cost_per_km'],
      ),
      maximumEthanolPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}maximum_ethanol_price'],
      )!,
      difference: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}difference'],
      )!,
    );
  }

  @override
  $HistoryEntriesTable createAlias(String alias) {
    return $HistoryEntriesTable(attachedDatabase, alias);
  }
}

class HistoryEntryRow extends DataClass implements Insertable<HistoryEntryRow> {
  final int id;
  final DateTime createdAt;
  final String gasolinePrice;
  final String ethanolPrice;
  final String? gasolineConsumption;
  final String? ethanolConsumption;
  final String recommendedFuel;
  final String ratio;
  final String appliedThreshold;
  final String thresholdSource;
  final String? gasolineCostPerKm;
  final String? ethanolCostPerKm;
  final String maximumEthanolPrice;
  final String difference;
  const HistoryEntryRow({
    required this.id,
    required this.createdAt,
    required this.gasolinePrice,
    required this.ethanolPrice,
    this.gasolineConsumption,
    this.ethanolConsumption,
    required this.recommendedFuel,
    required this.ratio,
    required this.appliedThreshold,
    required this.thresholdSource,
    this.gasolineCostPerKm,
    this.ethanolCostPerKm,
    required this.maximumEthanolPrice,
    required this.difference,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['gasoline_price'] = Variable<String>(gasolinePrice);
    map['ethanol_price'] = Variable<String>(ethanolPrice);
    if (!nullToAbsent || gasolineConsumption != null) {
      map['gasoline_consumption'] = Variable<String>(gasolineConsumption);
    }
    if (!nullToAbsent || ethanolConsumption != null) {
      map['ethanol_consumption'] = Variable<String>(ethanolConsumption);
    }
    map['recommended_fuel'] = Variable<String>(recommendedFuel);
    map['ratio'] = Variable<String>(ratio);
    map['applied_threshold'] = Variable<String>(appliedThreshold);
    map['threshold_source'] = Variable<String>(thresholdSource);
    if (!nullToAbsent || gasolineCostPerKm != null) {
      map['gasoline_cost_per_km'] = Variable<String>(gasolineCostPerKm);
    }
    if (!nullToAbsent || ethanolCostPerKm != null) {
      map['ethanol_cost_per_km'] = Variable<String>(ethanolCostPerKm);
    }
    map['maximum_ethanol_price'] = Variable<String>(maximumEthanolPrice);
    map['difference'] = Variable<String>(difference);
    return map;
  }

  HistoryEntriesCompanion toCompanion(bool nullToAbsent) {
    return HistoryEntriesCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      gasolinePrice: Value(gasolinePrice),
      ethanolPrice: Value(ethanolPrice),
      gasolineConsumption: gasolineConsumption == null && nullToAbsent
          ? const Value.absent()
          : Value(gasolineConsumption),
      ethanolConsumption: ethanolConsumption == null && nullToAbsent
          ? const Value.absent()
          : Value(ethanolConsumption),
      recommendedFuel: Value(recommendedFuel),
      ratio: Value(ratio),
      appliedThreshold: Value(appliedThreshold),
      thresholdSource: Value(thresholdSource),
      gasolineCostPerKm: gasolineCostPerKm == null && nullToAbsent
          ? const Value.absent()
          : Value(gasolineCostPerKm),
      ethanolCostPerKm: ethanolCostPerKm == null && nullToAbsent
          ? const Value.absent()
          : Value(ethanolCostPerKm),
      maximumEthanolPrice: Value(maximumEthanolPrice),
      difference: Value(difference),
    );
  }

  factory HistoryEntryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HistoryEntryRow(
      id: serializer.fromJson<int>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      gasolinePrice: serializer.fromJson<String>(json['gasolinePrice']),
      ethanolPrice: serializer.fromJson<String>(json['ethanolPrice']),
      gasolineConsumption: serializer.fromJson<String?>(
        json['gasolineConsumption'],
      ),
      ethanolConsumption: serializer.fromJson<String?>(
        json['ethanolConsumption'],
      ),
      recommendedFuel: serializer.fromJson<String>(json['recommendedFuel']),
      ratio: serializer.fromJson<String>(json['ratio']),
      appliedThreshold: serializer.fromJson<String>(json['appliedThreshold']),
      thresholdSource: serializer.fromJson<String>(json['thresholdSource']),
      gasolineCostPerKm: serializer.fromJson<String?>(
        json['gasolineCostPerKm'],
      ),
      ethanolCostPerKm: serializer.fromJson<String?>(json['ethanolCostPerKm']),
      maximumEthanolPrice: serializer.fromJson<String>(
        json['maximumEthanolPrice'],
      ),
      difference: serializer.fromJson<String>(json['difference']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'gasolinePrice': serializer.toJson<String>(gasolinePrice),
      'ethanolPrice': serializer.toJson<String>(ethanolPrice),
      'gasolineConsumption': serializer.toJson<String?>(gasolineConsumption),
      'ethanolConsumption': serializer.toJson<String?>(ethanolConsumption),
      'recommendedFuel': serializer.toJson<String>(recommendedFuel),
      'ratio': serializer.toJson<String>(ratio),
      'appliedThreshold': serializer.toJson<String>(appliedThreshold),
      'thresholdSource': serializer.toJson<String>(thresholdSource),
      'gasolineCostPerKm': serializer.toJson<String?>(gasolineCostPerKm),
      'ethanolCostPerKm': serializer.toJson<String?>(ethanolCostPerKm),
      'maximumEthanolPrice': serializer.toJson<String>(maximumEthanolPrice),
      'difference': serializer.toJson<String>(difference),
    };
  }

  HistoryEntryRow copyWith({
    int? id,
    DateTime? createdAt,
    String? gasolinePrice,
    String? ethanolPrice,
    Value<String?> gasolineConsumption = const Value.absent(),
    Value<String?> ethanolConsumption = const Value.absent(),
    String? recommendedFuel,
    String? ratio,
    String? appliedThreshold,
    String? thresholdSource,
    Value<String?> gasolineCostPerKm = const Value.absent(),
    Value<String?> ethanolCostPerKm = const Value.absent(),
    String? maximumEthanolPrice,
    String? difference,
  }) => HistoryEntryRow(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    gasolinePrice: gasolinePrice ?? this.gasolinePrice,
    ethanolPrice: ethanolPrice ?? this.ethanolPrice,
    gasolineConsumption: gasolineConsumption.present
        ? gasolineConsumption.value
        : this.gasolineConsumption,
    ethanolConsumption: ethanolConsumption.present
        ? ethanolConsumption.value
        : this.ethanolConsumption,
    recommendedFuel: recommendedFuel ?? this.recommendedFuel,
    ratio: ratio ?? this.ratio,
    appliedThreshold: appliedThreshold ?? this.appliedThreshold,
    thresholdSource: thresholdSource ?? this.thresholdSource,
    gasolineCostPerKm: gasolineCostPerKm.present
        ? gasolineCostPerKm.value
        : this.gasolineCostPerKm,
    ethanolCostPerKm: ethanolCostPerKm.present
        ? ethanolCostPerKm.value
        : this.ethanolCostPerKm,
    maximumEthanolPrice: maximumEthanolPrice ?? this.maximumEthanolPrice,
    difference: difference ?? this.difference,
  );
  HistoryEntryRow copyWithCompanion(HistoryEntriesCompanion data) {
    return HistoryEntryRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      gasolinePrice: data.gasolinePrice.present
          ? data.gasolinePrice.value
          : this.gasolinePrice,
      ethanolPrice: data.ethanolPrice.present
          ? data.ethanolPrice.value
          : this.ethanolPrice,
      gasolineConsumption: data.gasolineConsumption.present
          ? data.gasolineConsumption.value
          : this.gasolineConsumption,
      ethanolConsumption: data.ethanolConsumption.present
          ? data.ethanolConsumption.value
          : this.ethanolConsumption,
      recommendedFuel: data.recommendedFuel.present
          ? data.recommendedFuel.value
          : this.recommendedFuel,
      ratio: data.ratio.present ? data.ratio.value : this.ratio,
      appliedThreshold: data.appliedThreshold.present
          ? data.appliedThreshold.value
          : this.appliedThreshold,
      thresholdSource: data.thresholdSource.present
          ? data.thresholdSource.value
          : this.thresholdSource,
      gasolineCostPerKm: data.gasolineCostPerKm.present
          ? data.gasolineCostPerKm.value
          : this.gasolineCostPerKm,
      ethanolCostPerKm: data.ethanolCostPerKm.present
          ? data.ethanolCostPerKm.value
          : this.ethanolCostPerKm,
      maximumEthanolPrice: data.maximumEthanolPrice.present
          ? data.maximumEthanolPrice.value
          : this.maximumEthanolPrice,
      difference: data.difference.present
          ? data.difference.value
          : this.difference,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HistoryEntryRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('gasolinePrice: $gasolinePrice, ')
          ..write('ethanolPrice: $ethanolPrice, ')
          ..write('gasolineConsumption: $gasolineConsumption, ')
          ..write('ethanolConsumption: $ethanolConsumption, ')
          ..write('recommendedFuel: $recommendedFuel, ')
          ..write('ratio: $ratio, ')
          ..write('appliedThreshold: $appliedThreshold, ')
          ..write('thresholdSource: $thresholdSource, ')
          ..write('gasolineCostPerKm: $gasolineCostPerKm, ')
          ..write('ethanolCostPerKm: $ethanolCostPerKm, ')
          ..write('maximumEthanolPrice: $maximumEthanolPrice, ')
          ..write('difference: $difference')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    gasolinePrice,
    ethanolPrice,
    gasolineConsumption,
    ethanolConsumption,
    recommendedFuel,
    ratio,
    appliedThreshold,
    thresholdSource,
    gasolineCostPerKm,
    ethanolCostPerKm,
    maximumEthanolPrice,
    difference,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HistoryEntryRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.gasolinePrice == this.gasolinePrice &&
          other.ethanolPrice == this.ethanolPrice &&
          other.gasolineConsumption == this.gasolineConsumption &&
          other.ethanolConsumption == this.ethanolConsumption &&
          other.recommendedFuel == this.recommendedFuel &&
          other.ratio == this.ratio &&
          other.appliedThreshold == this.appliedThreshold &&
          other.thresholdSource == this.thresholdSource &&
          other.gasolineCostPerKm == this.gasolineCostPerKm &&
          other.ethanolCostPerKm == this.ethanolCostPerKm &&
          other.maximumEthanolPrice == this.maximumEthanolPrice &&
          other.difference == this.difference);
}

class HistoryEntriesCompanion extends UpdateCompanion<HistoryEntryRow> {
  final Value<int> id;
  final Value<DateTime> createdAt;
  final Value<String> gasolinePrice;
  final Value<String> ethanolPrice;
  final Value<String?> gasolineConsumption;
  final Value<String?> ethanolConsumption;
  final Value<String> recommendedFuel;
  final Value<String> ratio;
  final Value<String> appliedThreshold;
  final Value<String> thresholdSource;
  final Value<String?> gasolineCostPerKm;
  final Value<String?> ethanolCostPerKm;
  final Value<String> maximumEthanolPrice;
  final Value<String> difference;
  const HistoryEntriesCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.gasolinePrice = const Value.absent(),
    this.ethanolPrice = const Value.absent(),
    this.gasolineConsumption = const Value.absent(),
    this.ethanolConsumption = const Value.absent(),
    this.recommendedFuel = const Value.absent(),
    this.ratio = const Value.absent(),
    this.appliedThreshold = const Value.absent(),
    this.thresholdSource = const Value.absent(),
    this.gasolineCostPerKm = const Value.absent(),
    this.ethanolCostPerKm = const Value.absent(),
    this.maximumEthanolPrice = const Value.absent(),
    this.difference = const Value.absent(),
  });
  HistoryEntriesCompanion.insert({
    this.id = const Value.absent(),
    required DateTime createdAt,
    required String gasolinePrice,
    required String ethanolPrice,
    this.gasolineConsumption = const Value.absent(),
    this.ethanolConsumption = const Value.absent(),
    required String recommendedFuel,
    required String ratio,
    required String appliedThreshold,
    required String thresholdSource,
    this.gasolineCostPerKm = const Value.absent(),
    this.ethanolCostPerKm = const Value.absent(),
    required String maximumEthanolPrice,
    required String difference,
  }) : createdAt = Value(createdAt),
       gasolinePrice = Value(gasolinePrice),
       ethanolPrice = Value(ethanolPrice),
       recommendedFuel = Value(recommendedFuel),
       ratio = Value(ratio),
       appliedThreshold = Value(appliedThreshold),
       thresholdSource = Value(thresholdSource),
       maximumEthanolPrice = Value(maximumEthanolPrice),
       difference = Value(difference);
  static Insertable<HistoryEntryRow> custom({
    Expression<int>? id,
    Expression<DateTime>? createdAt,
    Expression<String>? gasolinePrice,
    Expression<String>? ethanolPrice,
    Expression<String>? gasolineConsumption,
    Expression<String>? ethanolConsumption,
    Expression<String>? recommendedFuel,
    Expression<String>? ratio,
    Expression<String>? appliedThreshold,
    Expression<String>? thresholdSource,
    Expression<String>? gasolineCostPerKm,
    Expression<String>? ethanolCostPerKm,
    Expression<String>? maximumEthanolPrice,
    Expression<String>? difference,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (gasolinePrice != null) 'gasoline_price': gasolinePrice,
      if (ethanolPrice != null) 'ethanol_price': ethanolPrice,
      if (gasolineConsumption != null)
        'gasoline_consumption': gasolineConsumption,
      if (ethanolConsumption != null) 'ethanol_consumption': ethanolConsumption,
      if (recommendedFuel != null) 'recommended_fuel': recommendedFuel,
      if (ratio != null) 'ratio': ratio,
      if (appliedThreshold != null) 'applied_threshold': appliedThreshold,
      if (thresholdSource != null) 'threshold_source': thresholdSource,
      if (gasolineCostPerKm != null) 'gasoline_cost_per_km': gasolineCostPerKm,
      if (ethanolCostPerKm != null) 'ethanol_cost_per_km': ethanolCostPerKm,
      if (maximumEthanolPrice != null)
        'maximum_ethanol_price': maximumEthanolPrice,
      if (difference != null) 'difference': difference,
    });
  }

  HistoryEntriesCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? createdAt,
    Value<String>? gasolinePrice,
    Value<String>? ethanolPrice,
    Value<String?>? gasolineConsumption,
    Value<String?>? ethanolConsumption,
    Value<String>? recommendedFuel,
    Value<String>? ratio,
    Value<String>? appliedThreshold,
    Value<String>? thresholdSource,
    Value<String?>? gasolineCostPerKm,
    Value<String?>? ethanolCostPerKm,
    Value<String>? maximumEthanolPrice,
    Value<String>? difference,
  }) {
    return HistoryEntriesCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      gasolinePrice: gasolinePrice ?? this.gasolinePrice,
      ethanolPrice: ethanolPrice ?? this.ethanolPrice,
      gasolineConsumption: gasolineConsumption ?? this.gasolineConsumption,
      ethanolConsumption: ethanolConsumption ?? this.ethanolConsumption,
      recommendedFuel: recommendedFuel ?? this.recommendedFuel,
      ratio: ratio ?? this.ratio,
      appliedThreshold: appliedThreshold ?? this.appliedThreshold,
      thresholdSource: thresholdSource ?? this.thresholdSource,
      gasolineCostPerKm: gasolineCostPerKm ?? this.gasolineCostPerKm,
      ethanolCostPerKm: ethanolCostPerKm ?? this.ethanolCostPerKm,
      maximumEthanolPrice: maximumEthanolPrice ?? this.maximumEthanolPrice,
      difference: difference ?? this.difference,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (gasolinePrice.present) {
      map['gasoline_price'] = Variable<String>(gasolinePrice.value);
    }
    if (ethanolPrice.present) {
      map['ethanol_price'] = Variable<String>(ethanolPrice.value);
    }
    if (gasolineConsumption.present) {
      map['gasoline_consumption'] = Variable<String>(gasolineConsumption.value);
    }
    if (ethanolConsumption.present) {
      map['ethanol_consumption'] = Variable<String>(ethanolConsumption.value);
    }
    if (recommendedFuel.present) {
      map['recommended_fuel'] = Variable<String>(recommendedFuel.value);
    }
    if (ratio.present) {
      map['ratio'] = Variable<String>(ratio.value);
    }
    if (appliedThreshold.present) {
      map['applied_threshold'] = Variable<String>(appliedThreshold.value);
    }
    if (thresholdSource.present) {
      map['threshold_source'] = Variable<String>(thresholdSource.value);
    }
    if (gasolineCostPerKm.present) {
      map['gasoline_cost_per_km'] = Variable<String>(gasolineCostPerKm.value);
    }
    if (ethanolCostPerKm.present) {
      map['ethanol_cost_per_km'] = Variable<String>(ethanolCostPerKm.value);
    }
    if (maximumEthanolPrice.present) {
      map['maximum_ethanol_price'] = Variable<String>(
        maximumEthanolPrice.value,
      );
    }
    if (difference.present) {
      map['difference'] = Variable<String>(difference.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HistoryEntriesCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('gasolinePrice: $gasolinePrice, ')
          ..write('ethanolPrice: $ethanolPrice, ')
          ..write('gasolineConsumption: $gasolineConsumption, ')
          ..write('ethanolConsumption: $ethanolConsumption, ')
          ..write('recommendedFuel: $recommendedFuel, ')
          ..write('ratio: $ratio, ')
          ..write('appliedThreshold: $appliedThreshold, ')
          ..write('thresholdSource: $thresholdSource, ')
          ..write('gasolineCostPerKm: $gasolineCostPerKm, ')
          ..write('ethanolCostPerKm: $ethanolCostPerKm, ')
          ..write('maximumEthanolPrice: $maximumEthanolPrice, ')
          ..write('difference: $difference')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $VehicleProfilesTable vehicleProfiles = $VehicleProfilesTable(
    this,
  );
  late final $HistoryEntriesTable historyEntries = $HistoryEntriesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    vehicleProfiles,
    historyEntries,
  ];
}

typedef $$VehicleProfilesTableCreateCompanionBuilder =
    VehicleProfilesCompanion Function({
      Value<int> id,
      required String name,
      Value<String?> gasolineKmPerLiter,
      Value<String?> ethanolKmPerLiter,
      required DateTime updatedAt,
    });
typedef $$VehicleProfilesTableUpdateCompanionBuilder =
    VehicleProfilesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String?> gasolineKmPerLiter,
      Value<String?> ethanolKmPerLiter,
      Value<DateTime> updatedAt,
    });

class $$VehicleProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $VehicleProfilesTable> {
  $$VehicleProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gasolineKmPerLiter => $composableBuilder(
    column: $table.gasolineKmPerLiter,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ethanolKmPerLiter => $composableBuilder(
    column: $table.ethanolKmPerLiter,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$VehicleProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $VehicleProfilesTable> {
  $$VehicleProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gasolineKmPerLiter => $composableBuilder(
    column: $table.gasolineKmPerLiter,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ethanolKmPerLiter => $composableBuilder(
    column: $table.ethanolKmPerLiter,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$VehicleProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $VehicleProfilesTable> {
  $$VehicleProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get gasolineKmPerLiter => $composableBuilder(
    column: $table.gasolineKmPerLiter,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ethanolKmPerLiter => $composableBuilder(
    column: $table.ethanolKmPerLiter,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$VehicleProfilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VehicleProfilesTable,
          VehicleProfileRow,
          $$VehicleProfilesTableFilterComposer,
          $$VehicleProfilesTableOrderingComposer,
          $$VehicleProfilesTableAnnotationComposer,
          $$VehicleProfilesTableCreateCompanionBuilder,
          $$VehicleProfilesTableUpdateCompanionBuilder,
          (
            VehicleProfileRow,
            BaseReferences<
              _$AppDatabase,
              $VehicleProfilesTable,
              VehicleProfileRow
            >,
          ),
          VehicleProfileRow,
          PrefetchHooks Function()
        > {
  $$VehicleProfilesTableTableManager(
    _$AppDatabase db,
    $VehicleProfilesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VehicleProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VehicleProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VehicleProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> gasolineKmPerLiter = const Value.absent(),
                Value<String?> ethanolKmPerLiter = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => VehicleProfilesCompanion(
                id: id,
                name: name,
                gasolineKmPerLiter: gasolineKmPerLiter,
                ethanolKmPerLiter: ethanolKmPerLiter,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> gasolineKmPerLiter = const Value.absent(),
                Value<String?> ethanolKmPerLiter = const Value.absent(),
                required DateTime updatedAt,
              }) => VehicleProfilesCompanion.insert(
                id: id,
                name: name,
                gasolineKmPerLiter: gasolineKmPerLiter,
                ethanolKmPerLiter: ethanolKmPerLiter,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$VehicleProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VehicleProfilesTable,
      VehicleProfileRow,
      $$VehicleProfilesTableFilterComposer,
      $$VehicleProfilesTableOrderingComposer,
      $$VehicleProfilesTableAnnotationComposer,
      $$VehicleProfilesTableCreateCompanionBuilder,
      $$VehicleProfilesTableUpdateCompanionBuilder,
      (
        VehicleProfileRow,
        BaseReferences<_$AppDatabase, $VehicleProfilesTable, VehicleProfileRow>,
      ),
      VehicleProfileRow,
      PrefetchHooks Function()
    >;
typedef $$HistoryEntriesTableCreateCompanionBuilder =
    HistoryEntriesCompanion Function({
      Value<int> id,
      required DateTime createdAt,
      required String gasolinePrice,
      required String ethanolPrice,
      Value<String?> gasolineConsumption,
      Value<String?> ethanolConsumption,
      required String recommendedFuel,
      required String ratio,
      required String appliedThreshold,
      required String thresholdSource,
      Value<String?> gasolineCostPerKm,
      Value<String?> ethanolCostPerKm,
      required String maximumEthanolPrice,
      required String difference,
    });
typedef $$HistoryEntriesTableUpdateCompanionBuilder =
    HistoryEntriesCompanion Function({
      Value<int> id,
      Value<DateTime> createdAt,
      Value<String> gasolinePrice,
      Value<String> ethanolPrice,
      Value<String?> gasolineConsumption,
      Value<String?> ethanolConsumption,
      Value<String> recommendedFuel,
      Value<String> ratio,
      Value<String> appliedThreshold,
      Value<String> thresholdSource,
      Value<String?> gasolineCostPerKm,
      Value<String?> ethanolCostPerKm,
      Value<String> maximumEthanolPrice,
      Value<String> difference,
    });

class $$HistoryEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $HistoryEntriesTable> {
  $$HistoryEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gasolinePrice => $composableBuilder(
    column: $table.gasolinePrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ethanolPrice => $composableBuilder(
    column: $table.ethanolPrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gasolineConsumption => $composableBuilder(
    column: $table.gasolineConsumption,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ethanolConsumption => $composableBuilder(
    column: $table.ethanolConsumption,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recommendedFuel => $composableBuilder(
    column: $table.recommendedFuel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ratio => $composableBuilder(
    column: $table.ratio,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get appliedThreshold => $composableBuilder(
    column: $table.appliedThreshold,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get thresholdSource => $composableBuilder(
    column: $table.thresholdSource,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gasolineCostPerKm => $composableBuilder(
    column: $table.gasolineCostPerKm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ethanolCostPerKm => $composableBuilder(
    column: $table.ethanolCostPerKm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get maximumEthanolPrice => $composableBuilder(
    column: $table.maximumEthanolPrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get difference => $composableBuilder(
    column: $table.difference,
    builder: (column) => ColumnFilters(column),
  );
}

class $$HistoryEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $HistoryEntriesTable> {
  $$HistoryEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gasolinePrice => $composableBuilder(
    column: $table.gasolinePrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ethanolPrice => $composableBuilder(
    column: $table.ethanolPrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gasolineConsumption => $composableBuilder(
    column: $table.gasolineConsumption,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ethanolConsumption => $composableBuilder(
    column: $table.ethanolConsumption,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recommendedFuel => $composableBuilder(
    column: $table.recommendedFuel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ratio => $composableBuilder(
    column: $table.ratio,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get appliedThreshold => $composableBuilder(
    column: $table.appliedThreshold,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get thresholdSource => $composableBuilder(
    column: $table.thresholdSource,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gasolineCostPerKm => $composableBuilder(
    column: $table.gasolineCostPerKm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ethanolCostPerKm => $composableBuilder(
    column: $table.ethanolCostPerKm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get maximumEthanolPrice => $composableBuilder(
    column: $table.maximumEthanolPrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get difference => $composableBuilder(
    column: $table.difference,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HistoryEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $HistoryEntriesTable> {
  $$HistoryEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get gasolinePrice => $composableBuilder(
    column: $table.gasolinePrice,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ethanolPrice => $composableBuilder(
    column: $table.ethanolPrice,
    builder: (column) => column,
  );

  GeneratedColumn<String> get gasolineConsumption => $composableBuilder(
    column: $table.gasolineConsumption,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ethanolConsumption => $composableBuilder(
    column: $table.ethanolConsumption,
    builder: (column) => column,
  );

  GeneratedColumn<String> get recommendedFuel => $composableBuilder(
    column: $table.recommendedFuel,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ratio =>
      $composableBuilder(column: $table.ratio, builder: (column) => column);

  GeneratedColumn<String> get appliedThreshold => $composableBuilder(
    column: $table.appliedThreshold,
    builder: (column) => column,
  );

  GeneratedColumn<String> get thresholdSource => $composableBuilder(
    column: $table.thresholdSource,
    builder: (column) => column,
  );

  GeneratedColumn<String> get gasolineCostPerKm => $composableBuilder(
    column: $table.gasolineCostPerKm,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ethanolCostPerKm => $composableBuilder(
    column: $table.ethanolCostPerKm,
    builder: (column) => column,
  );

  GeneratedColumn<String> get maximumEthanolPrice => $composableBuilder(
    column: $table.maximumEthanolPrice,
    builder: (column) => column,
  );

  GeneratedColumn<String> get difference => $composableBuilder(
    column: $table.difference,
    builder: (column) => column,
  );
}

class $$HistoryEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HistoryEntriesTable,
          HistoryEntryRow,
          $$HistoryEntriesTableFilterComposer,
          $$HistoryEntriesTableOrderingComposer,
          $$HistoryEntriesTableAnnotationComposer,
          $$HistoryEntriesTableCreateCompanionBuilder,
          $$HistoryEntriesTableUpdateCompanionBuilder,
          (
            HistoryEntryRow,
            BaseReferences<
              _$AppDatabase,
              $HistoryEntriesTable,
              HistoryEntryRow
            >,
          ),
          HistoryEntryRow,
          PrefetchHooks Function()
        > {
  $$HistoryEntriesTableTableManager(
    _$AppDatabase db,
    $HistoryEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HistoryEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HistoryEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HistoryEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String> gasolinePrice = const Value.absent(),
                Value<String> ethanolPrice = const Value.absent(),
                Value<String?> gasolineConsumption = const Value.absent(),
                Value<String?> ethanolConsumption = const Value.absent(),
                Value<String> recommendedFuel = const Value.absent(),
                Value<String> ratio = const Value.absent(),
                Value<String> appliedThreshold = const Value.absent(),
                Value<String> thresholdSource = const Value.absent(),
                Value<String?> gasolineCostPerKm = const Value.absent(),
                Value<String?> ethanolCostPerKm = const Value.absent(),
                Value<String> maximumEthanolPrice = const Value.absent(),
                Value<String> difference = const Value.absent(),
              }) => HistoryEntriesCompanion(
                id: id,
                createdAt: createdAt,
                gasolinePrice: gasolinePrice,
                ethanolPrice: ethanolPrice,
                gasolineConsumption: gasolineConsumption,
                ethanolConsumption: ethanolConsumption,
                recommendedFuel: recommendedFuel,
                ratio: ratio,
                appliedThreshold: appliedThreshold,
                thresholdSource: thresholdSource,
                gasolineCostPerKm: gasolineCostPerKm,
                ethanolCostPerKm: ethanolCostPerKm,
                maximumEthanolPrice: maximumEthanolPrice,
                difference: difference,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime createdAt,
                required String gasolinePrice,
                required String ethanolPrice,
                Value<String?> gasolineConsumption = const Value.absent(),
                Value<String?> ethanolConsumption = const Value.absent(),
                required String recommendedFuel,
                required String ratio,
                required String appliedThreshold,
                required String thresholdSource,
                Value<String?> gasolineCostPerKm = const Value.absent(),
                Value<String?> ethanolCostPerKm = const Value.absent(),
                required String maximumEthanolPrice,
                required String difference,
              }) => HistoryEntriesCompanion.insert(
                id: id,
                createdAt: createdAt,
                gasolinePrice: gasolinePrice,
                ethanolPrice: ethanolPrice,
                gasolineConsumption: gasolineConsumption,
                ethanolConsumption: ethanolConsumption,
                recommendedFuel: recommendedFuel,
                ratio: ratio,
                appliedThreshold: appliedThreshold,
                thresholdSource: thresholdSource,
                gasolineCostPerKm: gasolineCostPerKm,
                ethanolCostPerKm: ethanolCostPerKm,
                maximumEthanolPrice: maximumEthanolPrice,
                difference: difference,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$HistoryEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HistoryEntriesTable,
      HistoryEntryRow,
      $$HistoryEntriesTableFilterComposer,
      $$HistoryEntriesTableOrderingComposer,
      $$HistoryEntriesTableAnnotationComposer,
      $$HistoryEntriesTableCreateCompanionBuilder,
      $$HistoryEntriesTableUpdateCompanionBuilder,
      (
        HistoryEntryRow,
        BaseReferences<_$AppDatabase, $HistoryEntriesTable, HistoryEntryRow>,
      ),
      HistoryEntryRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$VehicleProfilesTableTableManager get vehicleProfiles =>
      $$VehicleProfilesTableTableManager(_db, _db.vehicleProfiles);
  $$HistoryEntriesTableTableManager get historyEntries =>
      $$HistoryEntriesTableTableManager(_db, _db.historyEntries);
}
