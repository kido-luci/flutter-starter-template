import 'package:drift/drift.dart';

/// Bookmarks table. [List<String>] fields are stored as JSON text;
/// [DateTime] fields are stored as microseconds since epoch (UTC) to
/// match the precision requirements of the rev_sync engine.
@DataClassName('BookmarkRow')
class Bookmarks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get uuid => text().unique()();
  TextColumn get title => text()();
  TextColumn get url => text()();
  TextColumn get description => text()();
  TextColumn get tagsJson => text().withDefault(const Constant('[]'))();
  TextColumn get imageUrlsJson => text().withDefault(const Constant('[]'))();
  TextColumn get videoUrl => text().nullable()();
  IntColumn get createdAtUs => integer()();
  IntColumn get updatedAtUs => integer()();
  IntColumn get serverUpdatedAtUs => integer().nullable()();
  IntColumn get rev => integer().withDefault(const Constant(0))();
  IntColumn get syncStateCode => integer().withDefault(const Constant(0))();
}
