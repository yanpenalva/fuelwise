import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'package:fuelwise/infrastructure/database/tables.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [VehicleProfiles, HistoryEntries])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? driftDatabase(name: 'fuelwise'));

  @override
  int get schemaVersion => 1;

  Future<VehicleProfileRow?> getVehicleProfile() {
    return (select(vehicleProfiles)
          ..orderBy([(t) => OrderingTerm(expression: t.id)]))
        .getSingleOrNull();
  }

  Future<VehicleProfileRow> insertVehicleProfile(
    VehicleProfilesCompanion entry,
  ) async {
    final id = await into(vehicleProfiles).insert(entry);
    return await (select(vehicleProfiles)..where((t) => t.id.equals(id)))
        .getSingle();
  }

  Future<void> updateVehicleProfile(VehicleProfileRow row) {
    return (update(vehicleProfiles)..where((t) => t.id.equals(row.id)))
        .write(row.toCompanion(false));
  }

  Future<HistoryEntryRow> insertHistoryEntry(
    HistoryEntriesCompanion entry,
  ) async {
    final id = await into(historyEntries).insert(entry);
    return await (select(historyEntries)..where((t) => t.id.equals(id)))
        .getSingle();
  }

  Future<List<HistoryEntryRow>> getAllHistoryEntries() {
    return (select(historyEntries)
          ..orderBy([
            (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc),
            (t) => OrderingTerm(expression: t.id, mode: OrderingMode.desc),
          ]))
        .get();
  }

  Future<int> deleteHistoryEntry(int id) {
    return (delete(historyEntries)..where((t) => t.id.equals(id))).go();
  }
}
