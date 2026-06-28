import 'package:drift/drift.dart';

/// Notifications cache table. Read-only from the user's perspective —
/// the server owns the log.
@DataClassName('NotificationRow')
class Notifications extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get uuid => text().unique()();
  TextColumn get title => text()();
  TextColumn get body => text()();
  TextColumn get type => text()();
  BoolColumn get isRead => boolean()();
  IntColumn get createdAtUs => integer()();
  BoolColumn get pendingRead => boolean().withDefault(const Constant(false))();
}
