/// A user-created folder grouping bookmarks by their stable ids.
class Collection {
  const Collection({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.bookmarkIds,
    required this.createdAt,
    required this.updatedAt,
    this.isPendingSync = false,
    this.isConflicted = false,
    this.isFailed = false,
  });

  final String id;
  final String name;

  /// Stable icon token (see `collectionPalette`).
  final String icon;

  /// ARGB seed color for the collection card gradient.
  final int color;

  /// Stable ids (bookmark uuids) of the bookmarks in this collection.
  final List<String> bookmarkIds;

  final DateTime createdAt;
  final DateTime updatedAt;

  /// `true` when this collection has local changes not yet pushed to the
  /// server. UI surfaces a badge for these.
  final bool isPendingSync;

  /// `true` when the server changed this collection underneath an unsynced
  /// local edit. Needs user resolution before it can sync again.
  final bool isConflicted;

  /// `true` when the server rejected the last push for a non-retryable reason
  /// (e.g. validation). Surfaced so the user can fix or discard it.
  final bool isFailed;

  int get itemCount => bookmarkIds.length;
}

class CollectionInput {
  const CollectionInput({
    required this.name,
    required this.icon,
    required this.color,
    this.bookmarkIds = const [],
  });

  final String name;
  final String icon;
  final int color;
  final List<String> bookmarkIds;
}
