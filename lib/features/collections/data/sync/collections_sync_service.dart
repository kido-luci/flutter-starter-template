import 'dart:async';

import 'package:architecture/architecture.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:injectable/injectable.dart';
import 'package:network/network.dart';

import '../../domain/services/collections_sync_controller.dart';
import '../datasources/collections_remote_data_source.dart';
import '../local/collections_local_data_source.dart';
import 'collections_pull_reconciler.dart';
import 'collections_push_queue.dart';

/// Reconciles the local ObjectBox store with the remote API.
///
/// Triggers:
/// - [sync] is called explicitly on app start (post-auth) and after every
///   local mutation.
/// - Connectivity transitions from offline → online (via connectivity_plus).
///
/// Strategy:
/// 1. **Push**: drain every row in [SyncState.pendingCreate/pendingUpdate/
///    pendingDelete] to the server, marking each `synced` on success. A
///    failure leaves the row in its pending state so the next trigger retries.
/// 2. **Pull**: GET the full server list and reconcile by uuid:
///    - Server-only → insert locally as `synced`.
///    - Both sides → last-write-wins by `updated_at` (server vs local).
///    - Local-only synced row not in server payload → server deleted it
///      elsewhere; remove locally.
///    - Local-only pendingCreate not in server payload → keep, push next time.
///
/// Concurrent calls collapse into one in-flight sync (single-flight).
@LazySingleton(as: CollectionsSyncController)
class CollectionsSyncService implements CollectionsSyncController {
  CollectionsSyncService(
    CollectionsLocalDataSource local,
    CollectionsRemoteDataSource remote,
    this._connectivity,
  ) : _pushQueue = CollectionsPushQueue(local, remote),
      _pullReconciler = CollectionsPullReconciler(local, remote);

  final Connectivity _connectivity;
  final CollectionsPushQueue _pushQueue;
  final CollectionsPullReconciler _pullReconciler;

  final _status = StreamController<CollectionsSyncStatus>.broadcast();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;
  Future<void>? _inflight;
  bool _wasOnline = true;
  CollectionsSyncStatus _statusNow = CollectionsSyncStatus.idle;

  /// UI subscribes to drive sync indicators. The latest value is also
  /// available via [statusNow].
  @override
  Stream<CollectionsSyncStatus> get statusStream => _status.stream;
  @override
  CollectionsSyncStatus get statusNow => _statusNow;

  /// Begin reacting to connectivity changes and run an initial sync. Idempotent.
  @override
  Future<void> start() async {
    if (_connectivitySub != null) return;
    _connectivitySub = _connectivity.onConnectivityChanged.listen(
      _onConnectivity,
    );
    final initial = await _connectivity.checkConnectivity();
    _wasOnline = _hasNetwork(initial);
    sync().uw();
  }

  /// Stop listening and reset state. Called on sign-out.
  @override
  Future<void> stop() async {
    await _connectivitySub?.cancel();
    _connectivitySub = null;
  }

  void _onConnectivity(List<ConnectivityResult> result) {
    final online = _hasNetwork(result);
    if (online && !_wasOnline) {
      sync().uw();
    }
    _wasOnline = online;
  }

  bool _hasNetwork(List<ConnectivityResult> result) =>
      result.any((r) => r != ConnectivityResult.none);

  /// Public trigger. Concurrent callers share the in-flight future.
  @override
  Future<void> sync() {
    return _inflight ??= _run()..whenComplete(() => _inflight = null);
  }

  Future<void> _run() async {
    _emit(CollectionsSyncStatus.syncing);
    try {
      final pushHadFailures = await _pushQueue.push();
      await _pullReconciler.pull();
      // A failed row keeps its pending state and is retried next trigger; we
      // still surface `error` so the UI reflects that the sync was incomplete.
      _emit(
        pushHadFailures
            ? CollectionsSyncStatus.error
            : CollectionsSyncStatus.idle,
      );
    } on DioException {
      // Network/auth error — leave pending rows untouched so the next trigger
      // retries. Don't propagate; sync is fire-and-forget from callers.
      _emit(CollectionsSyncStatus.error);
    } on Object catch (_) {
      _emit(CollectionsSyncStatus.error);
    }
  }

  void _emit(CollectionsSyncStatus s) {
    _statusNow = s;
    _status.add(s);
  }
}
