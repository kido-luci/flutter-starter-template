part of 'bookmarks_list_bloc.dart';

sealed class BookmarksListEvent {
  const BookmarksListEvent();
}

final class BookmarksListLoadRequested extends BookmarksListEvent {
  const BookmarksListLoadRequested();
}

final class BookmarksListQueryChanged extends BookmarksListEvent {
  const BookmarksListQueryChanged(this.query);

  final String query;
}

final class BookmarksListDeleteRequested extends BookmarksListEvent {
  const BookmarksListDeleteRequested(this.id);

  final String id;
}

final class BookmarksListSortChanged extends BookmarksListEvent {
  const BookmarksListSortChanged(this.sort);

  final BookmarkSort sort;
}

final class BookmarksListShareRequested extends BookmarksListEvent {
  const BookmarksListShareRequested(this.bookmark);

  final Bookmark bookmark;
}

final class BookmarksListSyncRetried extends BookmarksListEvent {
  const BookmarksListSyncRetried();
}

final class _BookmarksSyncStatusChanged extends BookmarksListEvent {
  const _BookmarksSyncStatusChanged(this.status);

  final BookmarksSyncStatus status;
}

final class _BookmarksReloadSilentlyRequested extends BookmarksListEvent {
  const _BookmarksReloadSilentlyRequested();
}
