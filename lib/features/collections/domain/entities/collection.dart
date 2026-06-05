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
