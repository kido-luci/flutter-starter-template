enum CollectionsSyncStatus { idle, syncing, error }

abstract interface class CollectionsSyncController {
  Stream<CollectionsSyncStatus> get statusStream;
  CollectionsSyncStatus get statusNow;

  Future<void> start();
  Future<void> stop();
  Future<void> sync();
}
