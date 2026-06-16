import 'package:architecture/architecture.dart';
import '../entities/collection.dart';

abstract interface class CollectionsRepository {
  Future<Result<List<Collection>>> list();

  /// Reads the local store without triggering a background sync.
  ///
  /// Used for re-reads that follow a sync cycle, so reloading the freshly
  /// pulled data does not kick off yet another sync.
  Future<Result<List<Collection>>> listLocal();
  Future<Result<Collection>> get(String id);
  Future<Result<Collection>> create(CollectionInput input);
  Future<Result<Collection>> update(String id, CollectionInput input);
  Future<Result<void>> delete(String id);
}
