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

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      // Still at version 1, so nothing has to migrate yet.
      //
      // To evolve the schema: change the table, bump [schemaVersion], dump
      // the new version (see `drift_schemas/README.md`), then add a branch
      // here — guarded by the version it was introduced in, never by `to`,
      // so an install that skipped releases replays every step in order:
      //
      //     if (from < 2) await m.addColumn(bookmarks, bookmarks.archivedAt);
      //     if (from < 3) await m.createTable(tags);
      //
      // `test/migration_test.dart` then verifies each upgrade path lands on
      // exactly the schema a fresh install would have created.
    },
    beforeOpen: (details) async {
      // SQLite disables foreign-key enforcement by default, and the setting
      // is per-connection — so it has to be re-applied on every open, not
      // just at creation.
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
