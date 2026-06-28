import 'package:drift/drift.dart';

/// Collections table. bookmarkIds is stored as a JSON array — the same
/// denormalised design as the ObjectBox version.
@DataClassName('CollectionRow')
class Collections extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get uuid => text().unique()();
  TextColumn get name => text()();
  TextColumn get icon => text()();
  IntColumn get color => integer()();
  TextColumn get bookmarkIdsJson => text().withDefault(const Constant('[]'))();
  IntColumn get createdAtUs => integer()();
  IntColumn get updatedAtUs => integer()();
  IntColumn get serverUpdatedAtUs => integer().nullable()();
  IntColumn get rev => integer().withDefault(const Constant(0))();
  IntColumn get syncStateCode => integer().withDefault(const Constant(0))();
}
