import 'package:architecture/architecture.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../domain/entities/bookmark.dart';
import '../../../domain/services/bookmarks_sync_controller.dart';

part 'bookmarks_list_state.freezed.dart';

/// Ordering applied to the visible bookmark list.
enum BookmarkSort { newest, oldest, titleAz }

@freezed
abstract class BookmarksListState with _$BookmarksListState {
  const factory BookmarksListState({
    @Default(false) bool isLoading,
    @Default(BookmarksSyncStatus.idle) BookmarksSyncStatus syncStatus,
    @Default([]) List<Bookmark> items,
    @Default('') String query,
    @Default(BookmarkSort.newest) BookmarkSort sort,
    Failure? failure,
  }) = _BookmarksListState;
  const BookmarksListState._();

  /// Items filtered by the active query (matches title, url, or any tag) and
  /// ordered by [sort].
  List<Bookmark> get visibleItems {
    final needle = query.trim().toLowerCase();
    final filtered = needle.isEmpty
        ? items
        : items.where((b) {
            if (b.title.toLowerCase().contains(needle)) return true;
            if (b.url.toLowerCase().contains(needle)) return true;
            return b.tags.any((t) => t.toLowerCase().contains(needle));
          });

    final sorted = filtered.toList();
    switch (sort) {
      case BookmarkSort.newest:
        sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      case BookmarkSort.oldest:
        sorted.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      case BookmarkSort.titleAz:
        sorted.sort(
          (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
        );
    }
    return List.unmodifiable(sorted);
  }
}
