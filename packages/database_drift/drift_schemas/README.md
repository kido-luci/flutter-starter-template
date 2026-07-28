# Drift schema snapshots

One JSON file per released `schemaVersion` of `AppDatabase`. They are the only
record of what the schema looked like at a given version — once the Dart table
definitions move on, an old shape cannot be reconstructed from them. **Commit
every dump, and never edit one by hand.**

They exist so migration tests can start a database at an old version, run the
real `onUpgrade`, and assert the result matches what a fresh install of the new
version would have created.

## Changing the schema

1. Edit the table under `lib/src/tables/`.
2. Bump `schemaVersion` in `lib/src/app_database.dart`.
3. Add the upgrade step to `MigrationStrategy.onUpgrade`, guarded by the
   version it was introduced in (`if (from < 2) …`) so an install that skipped
   releases replays every step in order.
4. Regenerate the Drift bindings:

   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

5. Dump the new version:

   ```bash
   dart run drift_dev schema dump lib/src/app_database.dart drift_schemas/
   ```

6. Commit the new `drift_schema_v<n>.json` alongside the code change.

## Writing a migration test

Once a second version exists, generate the step helpers and use
`SchemaVerifier` to exercise each upgrade path:

```bash
dart run drift_dev schema generate drift_schemas/ test/generated_migrations/
```

See the [drift migration testing guide](https://drift.simonbinder.eu/Migrations/tests/).
