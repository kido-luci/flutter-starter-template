import 'package:architecture/architecture.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../../shared/domain/bookmark_stats.dart';
import '../../../../../shared/domain/bookmark_summaries.dart';
import '../../../domain/entities/collection.dart';
import '../../../domain/usecases/delete_collection.dart';
import '../../../domain/usecases/get_collection.dart';
import '../../../domain/usecases/update_collection.dart';
import 'collection_detail_state.dart';

@injectable
class CollectionDetailCubit extends Cubit<CollectionDetailState> {
  CollectionDetailCubit(
    this._get,
    this._update,
    this._delete,
    this._bookmarkSummaries,
  ) : super(const CollectionDetailState());

  final GetCollection _get;
  final UpdateCollection _update;
  final DeleteCollection _delete;
  final BookmarkSummariesReader _bookmarkSummaries;

  Future<void> load(String id) async {
    emit(state.copyWith(isLoading: true, failure: null));
    final collectionResult = await _get(id);
    if (collectionResult case Err(:final failure)) {
      emit(state.copyWith(isLoading: false, failure: failure));
      return;
    }
    final collection = (collectionResult as Ok<Collection>).value;
    final summariesResult = await _bookmarkSummaries();
    final allBookmarks = switch (summariesResult) {
      Ok(value: final items) => items,
      Err() => const <BookmarkSummary>[],
    };
    emit(
      state.copyWith(
        isLoading: false,
        collection: collection,
        allBookmarks: allBookmarks,
        members: _membersOf(collection, allBookmarks),
      ),
    );
  }

  /// Adds [bookmarkIds] to the collection (union with current members).
  Future<void> addBookmarks(Set<String> bookmarkIds) {
    final current = state.collection;
    if (current == null || bookmarkIds.isEmpty) return Future.value();
    final next = <String>[...current.bookmarkIds];
    for (final id in bookmarkIds) {
      if (!next.contains(id)) next.add(id);
    }
    return _persist(current, next);
  }

  /// Deletes the whole collection.
  Future<void> delete() async {
    final current = state.collection;
    if (current == null || state.isUpdating) return;
    emit(state.copyWith(isUpdating: true, failure: null));
    final result = await _delete(current.id);
    switch (result) {
      case Ok():
        emit(state.copyWith(isUpdating: false, deleted: true));
      case Err(:final failure):
        emit(state.copyWith(isUpdating: false, failure: failure));
    }
  }

  /// Removes a single bookmark from the collection.
  Future<void> removeBookmark(String bookmarkId) {
    final current = state.collection;
    if (current == null) return Future.value();
    final next = current.bookmarkIds.where((id) => id != bookmarkId).toList();
    return _persist(current, next);
  }

  Future<void> _persist(Collection current, List<String> bookmarkIds) async {
    if (state.isUpdating) return;
    emit(state.copyWith(isUpdating: true, failure: null));
    final result = await _update(
      UpdateCollectionParams(
        id: current.id,
        input: CollectionInput(
          name: current.name,
          icon: current.icon,
          color: current.color,
          bookmarkIds: bookmarkIds,
        ),
      ),
    );
    switch (result) {
      case Ok(value: final updated):
        emit(
          state.copyWith(
            isUpdating: false,
            collection: updated,
            members: _membersOf(updated, state.allBookmarks),
          ),
        );
      case Err(:final failure):
        emit(state.copyWith(isUpdating: false, failure: failure));
    }
  }

  List<BookmarkSummary> _membersOf(
    Collection collection,
    List<BookmarkSummary> all,
  ) {
    final byId = {for (final b in all) b.id: b};
    return [for (final id in collection.bookmarkIds) ?byId[id]];
  }
}
