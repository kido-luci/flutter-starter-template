import 'dart:async';

import 'package:analytics/analytics.dart';
import 'package:app_platform/app_platform.dart';
import 'package:architecture/architecture.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../domain/entities/bookmark.dart';
import '../../../domain/services/bookmarks_sync_controller.dart';
import '../../../domain/usecases/delete_bookmark.dart';
import '../../../domain/usecases/list_bookmarks.dart';
import '../../../domain/usecases/list_local_bookmarks.dart';
import 'bookmarks_list_state.dart';
import 'bookmarks_search_analytics_tracker.dart';

part 'bookmarks_list_event.dart';

@injectable
class BookmarksListBloc extends Bloc<BookmarksListEvent, BookmarksListState> {
  BookmarksListBloc(
    this._list,
    this._listLocal,
    this._delete,
    this._sync,
    this._analytics,
    this._share,
  ) : _searchAnalytics = BookmarksSearchAnalyticsTracker(_analytics),
      super(const BookmarksListState()) {
    on<BookmarksListLoadRequested>(
      _onLoadRequested,
      transformer: sequential(),
    );
    on<BookmarksListQueryChanged>(
      _onQueryChanged,
      transformer: sequential(),
    );
    on<BookmarksListDeleteRequested>(
      _onDeleteRequested,
      transformer: sequential(),
    );
    on<BookmarksListSortChanged>(_onSortChanged, transformer: sequential());
    on<BookmarksListShareRequested>(_onShareRequested);
    on<BookmarksListSyncRetried>(_onSyncRetried, transformer: sequential());
    on<_BookmarksSyncStatusChanged>(
      _onSyncStatusChanged,
      transformer: sequential(),
    );
    on<_BookmarksReloadSilentlyRequested>(
      _onReloadSilentlyRequested,
      transformer: sequential(),
    );
    // Reload local data after every sync cycle so server-side changes
    // appear without the user pulling-to-refresh.
    _syncSub = _sync.statusStream.listen((status) {
      if (isClosed) return;
      add(_BookmarksSyncStatusChanged(status));
    });
  }

  final ListBookmarks _list;
  final ListLocalBookmarks _listLocal;
  final DeleteBookmark _delete;
  final BookmarksSyncController _sync;
  final AnalyticsService _analytics;
  final ShareService _share;
  final BookmarksSearchAnalyticsTracker _searchAnalytics;
  late final StreamSubscription<BookmarksSyncStatus> _syncSub;
  BookmarksSyncStatus _lastSyncStatus = BookmarksSyncStatus.idle;

  static const Duration searchAnalyticsDebounce =
      BookmarksSearchAnalyticsTracker.debounce;

  Future<void> _onLoadRequested(
    BookmarksListLoadRequested event,
    Emitter<BookmarksListState> emit,
  ) => _loadAndEmit(emit);

  Future<void> _loadAndEmit(Emitter<BookmarksListState> emit) async {
    emit(state.copyWith(isLoading: true, failure: null));
    final result = await _list();
    switch (result) {
      case Ok(value: final items):
        emit(state.copyWith(isLoading: false, items: items));
      case Err(:final failure):
        emit(state.copyWith(isLoading: false, failure: failure));
    }
  }

  void _onSyncStatusChanged(
    _BookmarksSyncStatusChanged event,
    Emitter<BookmarksListState> emit,
  ) {
    final status = event.status;
    emit(state.copyWith(syncStatus: status));
    // syncing → idle transition: pull fresh local view (sync may have
    // applied server-side updates or deletes).
    if (_lastSyncStatus == BookmarksSyncStatus.syncing &&
        status != BookmarksSyncStatus.syncing) {
      add(const _BookmarksReloadSilentlyRequested());
    }
    _lastSyncStatus = status;
  }

  Future<void> _onReloadSilentlyRequested(
    _BookmarksReloadSilentlyRequested event,
    Emitter<BookmarksListState> emit,
  ) async {
    // Read local only: reloading via _list() would trigger another sync,
    // which would emit syncing → idle and schedule another reload, looping.
    final result = await _listLocal();
    if (result case Ok(value: final items)) {
      emit(state.copyWith(items: items));
    }
  }

  Future<void> _onSyncRetried(
    BookmarksListSyncRetried event,
    Emitter<BookmarksListState> emit,
  ) async {
    _analytics.trackBookmarkSyncRetried().fire();
    await _sync.sync();
  }

  void _onQueryChanged(
    BookmarksListQueryChanged event,
    Emitter<BookmarksListState> emit,
  ) {
    if (event.query == state.query) {
      return;
    }
    final next = state.copyWith(query: event.query);
    emit(next);
    _searchAnalytics.schedule(
      query: event.query,
      resultCount: next.visibleItems.length,
    );
  }

  void _onSortChanged(
    BookmarksListSortChanged event,
    Emitter<BookmarksListState> emit,
  ) {
    if (event.sort == state.sort) return;
    emit(state.copyWith(sort: event.sort));
  }

  void _onShareRequested(
    BookmarksListShareRequested event,
    Emitter<BookmarksListState> emit,
  ) {
    final bookmark = event.bookmark;
    _analytics
        .trackBookmarkShared(
          bookmarkId: bookmark.id,
          source: AnalyticsSources.list,
        )
        .fire();
    _share.share(text: bookmark.shareText, subject: bookmark.title).fire();
  }

  Future<void> _onDeleteRequested(
    BookmarksListDeleteRequested event,
    Emitter<BookmarksListState> emit,
  ) async {
    final id = event.id;
    final previous = state.items;
    emit(
      state.copyWith(
        items: previous.where((b) => b.id != id).toList(growable: false),
      ),
    );
    final result = await _delete(id);
    switch (result) {
      case Ok<void>():
        _analytics
            .trackBookmarkDeleted(
              bookmarkId: id,
              source: AnalyticsSources.list,
            )
            .fire();
      case Err(:final failure):
        _analytics
            .trackBookmarkDeleteFailed(
              bookmarkId: id,
              source: AnalyticsSources.list,
              errorType: failure.runtimeType.toString(),
            )
            .fire();
        emit(state.copyWith(items: previous));
        await _loadAndEmit(emit);
    }
  }

  @override
  Future<void> close() {
    _searchAnalytics.dispose();
    _syncSub.cancel();
    return super.close();
  }
}
