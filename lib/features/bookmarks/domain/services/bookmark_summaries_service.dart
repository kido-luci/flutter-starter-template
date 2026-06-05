import 'package:architecture/architecture.dart';
import 'package:injectable/injectable.dart';

import '../../../../shared/domain/bookmark_stats.dart';
import '../../../../shared/domain/bookmark_summaries.dart';
import '../entities/bookmark.dart';
import '../usecases/list_bookmarks.dart';

/// Projects every [Bookmark] to a [BookmarkSummary].
///
/// Implements the shared [BookmarkSummariesReader] so the collections feature
/// can resolve member bookmarks without depending on the bookmarks domain.
@LazySingleton(as: BookmarkSummariesReader)
class BookmarkSummariesService extends BookmarkSummariesReader {
  const BookmarkSummariesService(this._listBookmarks);

  final ListBookmarks _listBookmarks;

  @override
  Future<Result<List<BookmarkSummary>>> call([
    NoParams param = noParams,
  ]) async {
    final result = await _listBookmarks();
    return switch (result) {
      Ok(value: final items) => Ok(
        items.map(_toSummary).toList(growable: false),
      ),
      Err(:final failure) => Err(failure),
    };
  }

  BookmarkSummary _toSummary(Bookmark bookmark) => BookmarkSummary(
    id: bookmark.id,
    title: bookmark.title,
    url: bookmark.url,
    description: bookmark.description,
    tags: bookmark.tags,
    imageUrls: bookmark.imageUrls,
  );
}
