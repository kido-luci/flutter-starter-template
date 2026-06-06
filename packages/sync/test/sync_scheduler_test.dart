import 'dart:async';

import 'package:sync/sync.dart';
import 'package:test/test.dart';

import 'fakes.dart';

void main() {
  late FakeConnectivity connectivity;

  setUp(() => connectivity = FakeConnectivity());
  tearDown(() => connectivity.dispose());

  SyncScheduler scheduler(Future<SyncOutcome> Function() body) => SyncScheduler(
    body,
    connectivity,
    const Duration(milliseconds: 10),
    const Duration(milliseconds: 40),
  );

  test('start runs an initial sync and idles on success', () async {
    var runs = 0;
    final s = scheduler(() async {
      runs++;
      return SyncOutcome.ok;
    });

    await s.start();
    await Future<void>.delayed(Duration.zero);

    expect(runs, 1);
    expect(s.statusNow, SyncStatus.idle);
    await s.dispose();
  });

  test(
    'concurrent sync calls share one in-flight run (single-flight)',
    () async {
      final gate = Completer<void>();
      var runs = 0;
      final s = scheduler(() async {
        runs++;
        await gate.future;
        return SyncOutcome.ok;
      });

      final a = s.sync();
      final b = s.sync();
      expect(runs, 1);
      gate.complete();
      await Future.wait([a, b]);
      expect(runs, 1);
      await s.dispose();
    },
  );

  test('an offline→online transition triggers a sync', () async {
    connectivity.online = false;
    var runs = 0;
    final s = scheduler(() async {
      runs++;
      return SyncOutcome.ok;
    });

    await s.start();
    await Future<void>.delayed(Duration.zero);
    final afterStart = runs;

    connectivity.goOnline();
    await Future<void>.delayed(Duration.zero);

    expect(runs, afterStart + 1);
    await s.dispose();
  });

  test('a failing run reports error and retries with backoff', () async {
    var runs = 0;
    final s = scheduler(() async {
      runs++;
      return runs == 1 ? SyncOutcome.error : SyncOutcome.ok;
    });

    await s.sync();
    expect(s.statusNow, SyncStatus.error);

    // The backoff timer fires and the retry succeeds.
    await Future<void>.delayed(const Duration(milliseconds: 30));
    expect(runs, greaterThanOrEqualTo(2));
    expect(s.statusNow, SyncStatus.idle);
    await s.dispose();
  });

  test('a stop during an in-flight run cancels the would-be retry', () async {
    final gate = Completer<void>();
    var runs = 0;
    final s = scheduler(() async {
      runs++;
      await gate.future;
      return SyncOutcome.error;
    });

    final inflight = s.sync(); // starts the run, then blocks on the gate
    await s.stop(); // stop lands while the body is still in flight
    gate.complete(); // body now completes with an error, post-stop
    await inflight;

    await Future<void>.delayed(const Duration(milliseconds: 30));
    expect(runs, 1, reason: 'no retry should be armed after stop mid-run');
    await s.dispose();
  });

  test('stop cancels the pending retry', () async {
    var runs = 0;
    final s = scheduler(() async {
      runs++;
      return SyncOutcome.error;
    });

    await s.sync();
    final afterFirst = runs;
    await s.stop();

    await Future<void>.delayed(const Duration(milliseconds: 30));
    expect(runs, afterFirst, reason: 'no retry should fire after stop');
    await s.dispose();
  });
}
