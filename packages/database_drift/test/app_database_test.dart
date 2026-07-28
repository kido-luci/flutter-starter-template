// Guards the database's opening contract: a fresh install must land on the
// schema the generated bindings expect, and every connection must enforce
// foreign keys. Both are silent failures otherwise — a drifted schema only
// surfaces as a query error in production, and SQLite happily ignores foreign
// keys when the pragma is left at its default.

import 'package:database_drift/database.dart';
import 'package:drift/native.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  test('a fresh database matches the schema drift generated', () async {
    // Fails if a table was edited without regenerating the bindings, or if a
    // hand-written migration step drifted from the table definitions.
    await db.validateDatabaseSchema();
  });

  test('foreign key enforcement is on for the connection', () async {
    final result = await db.customSelect('PRAGMA foreign_keys').getSingle();

    expect(result.data.values.first, 1);
  });
}
