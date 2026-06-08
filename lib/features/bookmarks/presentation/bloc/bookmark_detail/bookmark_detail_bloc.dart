import 'package:analytics/analytics.dart';
import 'package:app_platform/app_platform.dart';
import 'package:architecture/architecture.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../domain/entities/bookmark.dart';
import '../../../domain/usecases/delete_bookmark.dart';
import '../../../domain/usecases/get_bookmark.dart';
import 'bookmark_detail_state.dart';

part 'bookmark_detail_event.dart';

@injectable
class BookmarkDetailBloc
    extends Bloc<BookmarkDetailEvent, BookmarkDetailState> {
  BookmarkDetailBloc(this._get, this._delete, this._analytics, this._share)
    : super(const BookmarkDetailState.loading()) {
    on<BookmarkDetailLoadRequested>(
      _onLoadRequested,
      transformer: sequential(),
    );
    on<BookmarkDetailDeleteRequested>(
      _onDeleteRequested,
      transformer: sequential(),
    );
    on<BookmarkDetailShareRequested>(_onShareRequested);
    on<BookmarkDetailUrlOpened>(_onUrlOpened);
  }

  final GetBookmark _get;
  final DeleteBookmark _delete;
  final AnalyticsService _analytics;
  final ShareService _share;

  Future<void> _onLoadRequested(
    BookmarkDetailLoadRequested event,
    Emitter<BookmarkDetailState> emit,
  ) async {
    emit(const BookmarkDetailState.loading());
    final result = await _get(event.id);
    switch (result) {
      case Ok(value: final bookmark):
        _analytics
            .trackBookmarkViewed(
              bookmarkId: bookmark.id,
              tagCount: bookmark.tags.length,
              hasDescription: bookmark.description.isNotEmpty,
            )
            .fire();
        emit(BookmarkDetailState.ready(bookmark));
      case Err(:final failure):
        emit(BookmarkDetailState.failure(failure));
    }
  }

  Future<void> _onDeleteRequested(
    BookmarkDetailDeleteRequested event,
    Emitter<BookmarkDetailState> emit,
  ) async {
    final previous = state;
    if (previous is BookmarkDetailReady) {
      emit(BookmarkDetailState.deleting(previous.bookmark));
    }
    final result = await _delete(event.id);
    switch (result) {
      case Ok<void>():
        _analytics
            .trackBookmarkDeleted(
              bookmarkId: event.id,
              source: AnalyticsSources.detail,
            )
            .fire();
        emit(const BookmarkDetailState.deleted());
      case Err(:final failure):
        _analytics
            .trackBookmarkDeleteFailed(
              bookmarkId: event.id,
              source: AnalyticsSources.detail,
              errorType: failure.runtimeType.toString(),
            )
            .fire();
        emit(BookmarkDetailState.failure(failure));
    }
  }

  void _onShareRequested(
    BookmarkDetailShareRequested event,
    Emitter<BookmarkDetailState> emit,
  ) {
    final bookmark = event.bookmark;
    _analytics
        .trackBookmarkShared(
          bookmarkId: bookmark.id,
          source: AnalyticsSources.detail,
        )
        .fire();
    _share.share(text: bookmark.shareText, subject: bookmark.title).fire();
  }

  void _onUrlOpened(
    BookmarkDetailUrlOpened event,
    Emitter<BookmarkDetailState> emit,
  ) {
    _analytics
        .trackBookmarkOpened(
          bookmarkId: event.bookmark.id,
          source: AnalyticsSources.detail,
        )
        .fire();
  }
}
