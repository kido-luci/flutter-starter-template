import 'package:architecture/architecture.dart';
import '../entities/bookmark.dart';

abstract interface class BookmarksRepository {
  Future<Result<List<Bookmark>>> list();

  /// Reads the local store without triggering a background sync.
  ///
  /// Used for re-reads that follow a sync cycle, so reloading the freshly
  /// pulled data does not kick off yet another sync.
  Future<Result<List<Bookmark>>> listLocal();
  Future<Result<Bookmark>> get(String id);
  Future<Result<Bookmark>> create(BookmarkInput input);
  Future<Result<Bookmark>> update(String id, BookmarkInput input);
  Future<Result<void>> delete(String id);
}
