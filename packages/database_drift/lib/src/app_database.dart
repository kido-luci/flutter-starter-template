import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'tables/activities_table.dart';
import 'tables/bookmarks_table.dart';
import 'tables/collections_table.dart';
import 'tables/notifications_table.dart';
import 'tables/sync_cursors_table.dart';

part 'app_database.g.dart';

/// Single Drift database for the app. Feature data layers receive this via DI
/// and access their respective table accessors.
@DriftDatabase(
  tables: [Bookmarks, Collections, Notifications, Activities, SyncCursors],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  /// Opens the database in the platform-specific documents directory.
  factory AppDatabase.open() => AppDatabase(driftDatabase(name: 'app'));

  @override
  int get schemaVersion => 1;
}
