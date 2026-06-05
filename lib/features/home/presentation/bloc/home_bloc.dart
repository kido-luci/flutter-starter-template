import 'package:architecture/architecture.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../shared/domain/bookmark_stats.dart';
import '../../../../shared/domain/collections.dart';
import 'home_state.dart';

part 'home_event.dart';

@injectable
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc(this._bookmarkStats, this._collections) : super(const HomeState()) {
    on<HomeLoadRequested>(_onLoadRequested, transformer: droppable());
  }

  final BookmarkStatsReader _bookmarkStats;
  final CollectionsReader _collections;

  Future<void> _onLoadRequested(
    HomeLoadRequested event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, failure: null));
    final result = await _bookmarkStats();
    switch (result) {
      case Ok(value: final stats):
        emit(
          state.copyWith(
            isLoading: false,
            failure: null,
            totalBookmarks: stats.total,
            recentBookmarks: stats.recent,
            uniqueTags: stats.uniqueTags,
            recentItems: stats.recentItems,
          ),
        );
      case Err(:final failure):
        emit(state.copyWith(isLoading: false, failure: failure));
        return;
    }
    // Collections are a secondary concern: a failure here shouldn't block the
    // dashboard, so we only update the row when the read succeeds.
    final collectionsResult = await _collections();
    if (collectionsResult case Ok(value: final collections)) {
      emit(state.copyWith(collections: collections));
    }
  }
}
