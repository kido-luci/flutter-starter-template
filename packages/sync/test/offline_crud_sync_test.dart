import 'package:sync/sync.dart';
import 'package:test/test.dart';

import 'fakes.dart';

void main() {
  late MemStore store;
  late MemCursors cursors;
  late FakeAdapter adapter;
  late OfflineCrudSync<FakeRow> engine;

  setUp(() {
    store = MemStore();
    cursors = MemCursors();
    adapter = FakeAdapter();
    engine = OfflineCrudSync<FakeRow>(store, adapter, cursors);
  });

  group('push', () {
    test('a pending create is acknowledged and marked synced', () async {
      await store.put(FakeRow('a', 'hello', SyncState.pendingCreate));

      final outcome = await engine.run();

      expect(outcome, SyncOutcome.ok);
      final row = await store.getByUuid('a');
      expect(row!.syncState, SyncState.synced);
      expect(row.rev, greaterThan(0));
      // Server is authoritative for the value via record.apply.
      expect(row.value, 'hello');
    });

    test('a superseded create (409 already exists) becomes synced', () async {
      adapter.server['a'] = ServerRow(rev: 7, value: 'remote');
      await store.put(FakeRow('a', 'local', SyncState.pendingCreate));

      await engine.run();

      expect((await store.getByUuid('a'))!.syncState, SyncState.synced);
    });

    test('an update conflict marks the row conflicted', () async {
      adapter.conflictOnUpdate.add('a');
      await store.put(FakeRow('a', 'edited', SyncState.pendingUpdate, rev: 3));

      await engine.run();

      expect((await store.getByUuid('a'))!.syncState, SyncState.conflicted);
    });

    test('a terminal failure marks the row failed', () async {
      adapter.terminalOnCreate.add('a');
      await store.put(FakeRow('a', 'bad', SyncState.pendingCreate));

      final outcome = await engine.run();

      expect(outcome, SyncOutcome.ok); // terminal is handled, not a retry
      expect((await store.getByUuid('a'))!.syncState, SyncState.failed);
    });

    test(
      'a transient failure leaves the row pending and reports failures',
      () async {
        adapter.transientOnCreate.add('a');
        await store.put(FakeRow('a', 'x', SyncState.pendingCreate));

        final outcome = await engine.run();

        expect(outcome, SyncOutcome.hadFailures);
        expect(
          (await store.getByUuid('a'))!.syncState,
          SyncState.pendingCreate,
        );
      },
    );

    test(
      'lost-update guard: a concurrent edit during push stays pending',
      () async {
        await store.put(FakeRow('a', 'v1', SyncState.pendingCreate));
        // Simulate the user editing the row while the create is in flight.
        adapter.onCreate = (row) async {
          final inFlight = await store.getByUuid(row.uuid);
          inFlight!
            ..value = 'v2'
            ..updatedAt = row.updatedAt.add(const Duration(seconds: 1));
          await store.put(inFlight);
        };

        await engine.run();

        final row = await store.getByUuid('a');
        // The ack must NOT clobber the newer edit. The create succeeded
        // server-side, so the row is re-queued as an update carrying v2.
        expect(row!.syncState, SyncState.pendingUpdate);
        expect(row.value, 'v2');
      },
    );

    test(
      'a transient create whose row already landed stays pendingCreate, not '
      'conflicted',
      () async {
        await store.put(FakeRow('a', 'v1', SyncState.pendingCreate));
        // The create reached the server but the response was lost (transient),
        // so the server now lists the row while it is still pendingCreate.
        adapter.transientOnCreate.add('a');
        adapter.server['a'] = ServerRow(rev: 5, value: 'v1');

        final outcome = await engine.run();

        final row = await store.getByUuid('a');
        expect(outcome, SyncOutcome.hadFailures);
        // Must not dead-end as conflicted; the next push 409→supersedes it.
        expect(row!.syncState, SyncState.pendingCreate);
      },
    );

    test('a pending delete is pushed and hard-deleted locally', () async {
      adapter.server['a'] = ServerRow(rev: 2, value: 'x');
      await store.put(FakeRow('a', 'x', SyncState.pendingDelete, rev: 2));

      await engine.run();

      expect(await store.getByUuid('a'), isNull);
    });
  });

  group('pull', () {
    test('inserts a server-only row as synced', () async {
      adapter.server['a'] = ServerRow(rev: 5, value: 'remote');

      await engine.run();

      final row = await store.getByUuid('a');
      expect(row!.syncState, SyncState.synced);
      expect(row.value, 'remote');
      expect(row.rev, 5);
    });

    test(
      'overwrites a synced local row when the server rev is newer',
      () async {
        await store.put(FakeRow('a', 'old', SyncState.synced, rev: 1));
        adapter.server['a'] = ServerRow(rev: 4, value: 'new');

        await engine.run();

        final row = await store.getByUuid('a');
        expect(row!.value, 'new');
        expect(row.rev, 4);
      },
    );

    test('a tombstone removes a synced local row', () async {
      await store.put(FakeRow('a', 'x', SyncState.synced, rev: 1));
      adapter.server['a'] = ServerRow(rev: 2, value: 'x', deleted: true);

      await engine.run();

      expect(await store.getByUuid('a'), isNull);
    });

    test('a tombstone over an unsynced local edit is a conflict', () async {
      await store.put(FakeRow('a', 'mine', SyncState.pendingUpdate, rev: 1));
      adapter.server['a'] = ServerRow(rev: 9, value: 'x', deleted: true);
      // Avoid the push path turning this into something else first.
      adapter.transientOnUpdate.add('a');

      await engine.run();

      expect((await store.getByUuid('a'))!.syncState, SyncState.conflicted);
    });

    test('advances the cursor to the highest rev seen', () async {
      adapter.server['a'] = ServerRow(rev: 3, value: 'a');
      adapter.server['b'] = ServerRow(rev: 8, value: 'b');

      await engine.run();

      expect(await cursors.read('fakes'), 8);
      // A second run asks only for newer rows.
      await engine.run();
      expect(adapter.lastSince, 8);
    });
  });
}
