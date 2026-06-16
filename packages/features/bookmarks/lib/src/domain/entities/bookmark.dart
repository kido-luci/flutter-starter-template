class Bookmark {
  const Bookmark({
    required this.id,
    required this.title,
    required this.url,
    required this.description,
    required this.tags,
    required this.createdAt,
    required this.updatedAt,
    this.imageUrls = const [],
    this.videoUrl,
    this.isPendingSync = false,
    this.isConflicted = false,
    this.isFailed = false,
  });

  final String id;
  final String title;
  final String url;
  final String description;
  final List<String> tags;
  final List<String> imageUrls;
  final String? videoUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// `true` when this bookmark has local changes that haven't been pushed
  /// to the server yet. UI surfaces a badge for these.
  final bool isPendingSync;

  /// `true` when the server changed this bookmark underneath an unsynced local
  /// edit. Needs user resolution before it can sync again.
  final bool isConflicted;

  /// `true` when the server rejected the last push for a non-retryable reason
  /// (e.g. validation). Surfaced so the user can fix or discard it.
  final bool isFailed;
}

extension BookmarkShareText on Bookmark {
  /// Plain-text representation used when sharing via the platform share sheet.
  ///
  /// Kept here so every share entry point formats the text identically.
  String get shareText =>
      description.isNotEmpty ? '$title\n$url\n\n$description' : '$title\n$url';
}

class BookmarkInput {
  const BookmarkInput({
    required this.title,
    required this.url,
    required this.description,
    required this.tags,
    this.imageUrls = const [],
    this.videoUrl,
  });

  final String title;
  final String url;
  final String description;
  final List<String> tags;
  final List<String> imageUrls;
  final String? videoUrl;
}
