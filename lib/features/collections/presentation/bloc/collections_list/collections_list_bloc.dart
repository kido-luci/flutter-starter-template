import 'dart:async';

import 'package:architecture/architecture.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../domain/services/collections_sync_controller.dart';
import '../../../domain/usecases/delete_collection.dart';
import '../../../domain/usecases/list_collections.dart';
import '../../../domain/usecases/list_local_collections.dart';
import 'collections_list_state.dart';

part 'collections_list_event.dart';

@injectable
class CollectionsListBloc
    extends Bloc<CollectionsListEvent, CollectionsListState> {
  CollectionsListBloc(this._list, this._listLocal, this._delete, this._sync)
    : super(const CollectionsListState()) {
    on<CollectionsListLoadRequested>(
      _onLoadRequested,
      transformer: sequential(),
    );
    on<CollectionsListDeleteRequested>(
      _onDeleteRequested,
      transformer: sequential(),
    );
    on<_CollectionsSyncStatusChanged>(
      _onSyncStatusChanged,
      transformer: sequential(),
    );
    on<_CollectionsReloadSilentlyRequested>(
      _onReloadSilentlyRequested,
      transformer: sequential(),
    );
    // Reload local data after every sync cycle so server-side changes appear
    // without the user pulling-to-refresh.
    _syncSub = _sync.statusStream.listen((status) {
      if (isClosed) return;
      add(_CollectionsSyncStatusChanged(status));
    });
  }

  final ListCollections _list;
  final ListLocalCollections _listLocal;
  final DeleteCollection _delete;
  final CollectionsSyncController _sync;
  late final StreamSubscription<CollectionsSyncStatus> _syncSub;
  CollectionsSyncStatus _lastSyncStatus = CollectionsSyncStatus.idle;

  Future<void> _onLoadRequested(
    CollectionsListLoadRequested event,
    Emitter<CollectionsListState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, failure: null));
    final result = await _list();
    switch (result) {
      case Ok(value: final items):
        emit(state.copyWith(isLoading: false, items: items));
      case Err(:final failure):
        emit(state.copyWith(isLoading: false, failure: failure));
    }
  }

  Future<void> _onDeleteRequested(
    CollectionsListDeleteRequested event,
    Emitter<CollectionsListState> emit,
  ) async {
    final result = await _delete(event.id);
    switch (result) {
      case Ok():
        add(const _CollectionsReloadSilentlyRequested());
      case Err(:final failure):
        emit(state.copyWith(failure: failure));
    }
  }

  void _onSyncStatusChanged(
    _CollectionsSyncStatusChanged event,
    Emitter<CollectionsListState> emit,
  ) {
    final wasSyncing = _lastSyncStatus == CollectionsSyncStatus.syncing;
    _lastSyncStatus = event.status;
    emit(state.copyWith(syncStatus: event.status));
    // When a sync cycle finishes, refresh from local so pulled changes show.
    if (wasSyncing && event.status != CollectionsSyncStatus.syncing) {
      add(const _CollectionsReloadSilentlyRequested());
    }
  }

  Future<void> _onReloadSilentlyRequested(
    _CollectionsReloadSilentlyRequested event,
    Emitter<CollectionsListState> emit,
  ) async {
    final result = await _listLocal();
    if (result case Ok(value: final items)) {
      emit(state.copyWith(items: items));
    }
  }

  @override
  Future<void> close() {
    _syncSub.cancel();
    return super.close();
  }
}
