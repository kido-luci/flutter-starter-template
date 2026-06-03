import 'package:architecture/architecture.dart';
import 'package:injectable/injectable.dart';

import '../../../../shared/domain/bookmark_stats.dart';
import '../entities/bookmark.dart';
import '../usecases/list_bookmarks.dart';

/// Computes [BookmarkStats] from the bookmark list, owning the "recent" rule.
///
/// Implements the shared [BookmarkStatsReader] so other features can summarize
/// bookmarks without depending on the bookmarks domain.
@LazySingleton(as: BookmarkStatsReader)
class BookmarkStatsService extends BookmarkStatsReader {
  const BookmarkStatsService(this._listBookmarks);

  static const _recentWindow = Duration(days: 7);
  static const _recentItemCount = 3;

  final ListBookmarks _listBookmarks;

  @override
  Future<Result<BookmarkStats>> call([NoParams param = noParams]) async {
    final result = await _listBookmarks();
    return switch (result) {
      Ok(value: final items) => Ok(_statsFrom(items)),
      Err(:final failure) => Err(failure),
    };
  }

  BookmarkStats _statsFrom(List<Bookmark> items) {
    final cutoff = DateTime.now().subtract(_recentWindow);
    return BookmarkStats(
      total: items.length,
      recent: items.where((b) => b.createdAt.isAfter(cutoff)).length,
      uniqueTags: items.expand((b) => b.tags).toSet().length,
      recentItems: items
          .take(_recentItemCount)
          .map(_toSummary)
          .toList(growable: false),
    );
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
