import 'dart:async';

import 'connectivity_source.dart';
import 'sync_status.dart';

/// Drives a sync body on the right triggers and shields it from overlap.
///
/// Owns the cross-cutting concerns every synced resource shares, so the body
/// itself stays a plain push/pull function:
/// - **start/stop** lifecycle with a generation guard, so a `stop` that lands
///   while `start` awaits connectivity setup can't leave a listener running;
/// - **offline → online** re-sync via [ConnectivitySource];
/// - **single-flight**: concurrent [sync] callers share one in-flight run;
/// - **exponential backoff**: a run that fails or leaves rows pending is retried
///   on a timer (while online), capped at the max backoff;
/// - a [statusStream] of [SyncStatus] for the UI.
class SyncScheduler {
  /// Creates a scheduler that runs the given push/pull body on the triggers
  /// above. The optional positional durations tune the retry backoff (kept
  /// small in tests).
  SyncScheduler(
    this._body,
    this._connectivity, [
    this._baseBackoff = const Duration(seconds: 2),
    this._maxBackoff = const Duration(minutes: 5),
  ]);

  final Future<SyncOutcome> Function() _body;
  final ConnectivitySource _connectivity;
  final Duration _baseBackoff;
  final Duration _maxBackoff;

  final _status = StreamController<SyncStatus>.broadcast();
  StreamSubscription<bool>? _connectivitySub;
  Future<void>? _inflight;
  Timer? _retryTimer;
  bool _wasOnline = true;
  int _backoffAttempt = 0;
  SyncStatus _statusNow = SyncStatus.idle;

  /// Bumped on every start/stop so async setup in [start] can detect a [stop]
  /// that landed meanwhile and bail out.
  int _generation = 0;

  /// The latest status, also pushed on [statusStream].
  SyncStatus get statusNow => _statusNow;

  /// Surfaced sync state for the UI.
  Stream<SyncStatus> get statusStream => _status.stream;

  /// Starts reacting to connectivity and runs an initial sync. Idempotent.
  Future<void> start() async {
    if (_connectivitySub != null) return;
    final generation = ++_generation;
    _connectivitySub = _connectivity.onOnlineChanged.listen(_onConnectivity);
    final online = await _connectivity.isOnline();
    if (_generation != generation) return;
    _wasOnline = online;
    unawaited(sync());
  }

  /// Stops listening, cancels any pending retry, and resets transient state.
  Future<void> stop() async {
    _generation++;
    _retryTimer?.cancel();
    _retryTimer = null;
    _backoffAttempt = 0;
    await _connectivitySub?.cancel();
    _connectivitySub = null;
  }

  /// Triggers a sync. Concurrent callers share the in-flight run.
  Future<void> sync() {
    return _inflight ??= _run().whenComplete(() => _inflight = null);
  }

  /// Releases the status stream. Call once the scheduler is discarded.
  Future<void> dispose() async {
    await stop();
    await _status.close();
  }

  void _onConnectivity(bool online) {
    if (online && !_wasOnline) {
      _backoffAttempt = 0;
      unawaited(sync());
    }
    _wasOnline = online;
  }

  Future<void> _run() async {
    final generation = _generation;
    _retryTimer?.cancel();
    _emit(SyncStatus.syncing);
    SyncOutcome outcome;
    try {
      outcome = await _body();
    } on Object {
      outcome = SyncOutcome.error;
    }
    // A stop() (or restart) that landed while the body was in flight bumps the
    // generation; don't emit status or arm a retry timer after teardown.
    if (generation != _generation) return;
    if (outcome == SyncOutcome.ok) {
      _backoffAttempt = 0;
      _emit(SyncStatus.idle);
    } else {
      _emit(SyncStatus.error);
      _scheduleRetry();
    }
  }

  void _scheduleRetry() {
    if (!_wasOnline) return;
    _backoffAttempt++;
    final factor = 1 << (_backoffAttempt - 1);
    var delay = _baseBackoff * factor;
    if (delay > _maxBackoff) delay = _maxBackoff;
    _retryTimer?.cancel();
    _retryTimer = Timer(delay, () => unawaited(sync()));
  }

  void _emit(SyncStatus status) {
    _statusNow = status;
    if (!_status.isClosed) _status.add(status);
  }
}
