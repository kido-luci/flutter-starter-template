import 'package:drift/drift.dart';

/// Activity log cache table. Read-only from the user's perspective —
/// the server owns the log.
@DataClassName('ActivityRow')
class Activities extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get uuid => text().unique()();
  TextColumn get description => text()();
  TextColumn get type => text()();
  IntColumn get createdAtUs => integer()();
}
