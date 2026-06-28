import 'package:drift/drift.dart';

/// Stores the highest server revision applied for each sync resource.
/// One row per resource; upserted after every successful pull.
@DataClassName('SyncCursorRow')
class SyncCursors extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get resource => text().unique()();
  IntColumn get rev => integer()();
}
