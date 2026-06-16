part of 'bookmark_detail_bloc.dart';

sealed class BookmarkDetailEvent {
  const BookmarkDetailEvent();
}

final class BookmarkDetailLoadRequested extends BookmarkDetailEvent {
  const BookmarkDetailLoadRequested(this.id);

  final String id;
}

final class BookmarkDetailDeleteRequested extends BookmarkDetailEvent {
  const BookmarkDetailDeleteRequested(this.id);

  final String id;
}

final class BookmarkDetailShareRequested extends BookmarkDetailEvent {
  const BookmarkDetailShareRequested(this.bookmark);

  final Bookmark bookmark;
}

final class BookmarkDetailUrlOpened extends BookmarkDetailEvent {
  const BookmarkDetailUrlOpened(this.bookmark);

  final Bookmark bookmark;
}
