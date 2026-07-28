import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

// fst:feature:notifications:start
import 'tables/activities_table.dart';
// fst:feature:notifications:end
// fst:feature:bookmarks:start
import 'tables/bookmarks_table.dart';
// fst:feature:bookmarks:end
// fst:feature:collections:start
import 'tables/collections_table.dart';
// fst:feature:collections:end
// fst:feature:notifications:start
import 'tables/notifications_table.dart';
// fst:feature:notifications:end
// fst:backend:start
import 'tables/sync_cursors_table.dart';
// fst:backend:end

part 'app_database.g.dart';

/// Single Drift database for the app. Feature data layers receive this via DI
/// and access their respective table accessors.
///
/// One table per line so `fst create` can strip an excluded feature's table
/// without rewriting the list.
@DriftDatabase(
  tables: [
    // fst:feature:bookmarks:start
    Bookmarks,
    // fst:feature:bookmarks:end
    // fst:feature:collections:start
    Collections,
    // fst:feature:collections:end
    // fst:feature:notifications:start
    Notifications,
    Activities,
    // fst:feature:notifications:end
    // fst:backend:start
    SyncCursors,
    // fst:backend:end
  ],
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
