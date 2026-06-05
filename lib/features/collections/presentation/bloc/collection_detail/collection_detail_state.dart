import 'package:architecture/architecture.dart';

import '../../../../../shared/domain/bookmark_stats.dart';
import '../../../domain/entities/collection.dart';

/// State for the collection detail screen: the collection itself, its member
/// bookmarks, and the full bookmark list used by the "add bookmarks" picker.
class CollectionDetailState {
  const CollectionDetailState({
    this.isLoading = false,
    this.isUpdating = false,
    this.deleted = false,
    this.collection,
    this.members = const [],
    this.allBookmarks = const [],
    this.failure,
  });

  final bool isLoading;
  final bool isUpdating;

  /// Flips to true after a successful delete so the screen can pop.
  final bool deleted;
  final Collection? collection;
  final List<BookmarkSummary> members;
  final List<BookmarkSummary> allBookmarks;
  final Failure? failure;

  /// Bookmarks not yet in the collection — candidates for the picker.
  List<BookmarkSummary> get candidates {
    final memberIds = collection?.bookmarkIds.toSet() ?? const <String>{};
    return allBookmarks
        .where((b) => !memberIds.contains(b.id))
        .toList(growable: false);
  }

  CollectionDetailState copyWith({
    bool? isLoading,
    bool? isUpdating,
    bool? deleted,
    Collection? collection,
    List<BookmarkSummary>? members,
    List<BookmarkSummary>? allBookmarks,
    Failure? failure,
  }) {
    return CollectionDetailState(
      isLoading: isLoading ?? this.isLoading,
      isUpdating: isUpdating ?? this.isUpdating,
      deleted: deleted ?? this.deleted,
      collection: collection ?? this.collection,
      members: members ?? this.members,
      allBookmarks: allBookmarks ?? this.allBookmarks,
      failure: failure,
    );
  }
}
