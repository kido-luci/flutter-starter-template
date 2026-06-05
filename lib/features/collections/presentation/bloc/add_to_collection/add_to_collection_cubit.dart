import 'package:architecture/architecture.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../domain/entities/collection.dart';
import '../../../domain/usecases/list_collections.dart';
import '../../../domain/usecases/update_collection.dart';
import 'add_to_collection_state.dart';

/// Drives the bottom sheet that toggles a single bookmark's membership across
/// the user's collections.
///
/// This is the collections feature's "capability" surfaced inside the
/// bookmarks detail screen (the single-consumer exception in the architecture
/// rules).
@injectable
class AddToCollectionCubit extends Cubit<AddToCollectionState> {
  AddToCollectionCubit(this._list, this._update)
    : super(const AddToCollectionState());

  final ListCollections _list;
  final UpdateCollection _update;

  Future<void> load(String bookmarkId) async {
    emit(state.copyWith(isLoading: true, failure: null));
    final result = await _list();
    switch (result) {
      case Ok(value: final collections):
        emit(
          state.copyWith(
            isLoading: false,
            collections: collections,
            memberOf: {
              for (final c in collections)
                if (c.bookmarkIds.contains(bookmarkId)) c.id,
            },
          ),
        );
      case Err(:final failure):
        emit(state.copyWith(isLoading: false, failure: failure));
    }
  }

  /// Adds or removes [bookmarkId] from the collection with [collectionId].
  Future<void> toggle(String collectionId, String bookmarkId) async {
    if (state.busyIds.contains(collectionId)) return;
    final index = state.collections.indexWhere((c) => c.id == collectionId);
    // The collection may have disappeared between render and tap.
    if (index == -1) return;
    final collection = state.collections[index];
    final isMember = state.memberOf.contains(collectionId);
    final nextIds = isMember
        ? collection.bookmarkIds.where((id) => id != bookmarkId).toList()
        : [...collection.bookmarkIds, bookmarkId];

    emit(state.copyWith(busyIds: {...state.busyIds, collectionId}));
    final result = await _update(
      UpdateCollectionParams(
        id: collectionId,
        input: CollectionInput(
          name: collection.name,
          icon: collection.icon,
          color: collection.color,
          bookmarkIds: nextIds,
        ),
      ),
    );

    final busy = {...state.busyIds}..remove(collectionId);
    switch (result) {
      case Ok(value: final updated):
        final collections = [
          for (final c in state.collections)
            if (c.id == collectionId) updated else c,
        ];
        final memberOf = {...state.memberOf};
        if (isMember) {
          memberOf.remove(collectionId);
        } else {
          memberOf.add(collectionId);
        }
        emit(
          state.copyWith(
            collections: collections,
            memberOf: memberOf,
            busyIds: busy,
          ),
        );
      case Err(:final failure):
        emit(state.copyWith(busyIds: busy, failure: failure));
    }
  }
}
