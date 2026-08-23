import 'package:drift/drift.dart';

@DataClassName('VehicleProfileRow')
class VehicleProfiles extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get gasolineKmPerLiter => text().nullable()();
  TextColumn get ethanolKmPerLiter => text().nullable()();
  DateTimeColumn get updatedAt => dateTime()();
}

@DataClassName('HistoryEntryRow')
class HistoryEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get gasolinePrice => text()();
  TextColumn get ethanolPrice => text()();
  TextColumn get gasolineConsumption => text().nullable()();
  TextColumn get ethanolConsumption => text().nullable()();
  TextColumn get recommendedFuel => text()();
  TextColumn get ratio => text()();
  TextColumn get appliedThreshold => text()();
  TextColumn get thresholdSource => text()();
  TextColumn get gasolineCostPerKm => text().nullable()();
  TextColumn get ethanolCostPerKm => text().nullable()();
  TextColumn get maximumEthanolPrice => text()();
  TextColumn get difference => text()();
}
