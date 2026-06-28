import 'package:rev_sync/rev_sync.dart';

/// Mutable persistence row for a bookmark, compatible with [SyncLocalStore].
///
/// This is a pure persistence model; domain mapping lives in the bookmarks
/// feature's data layer.
class BookmarkEntity implements Syncable {
  BookmarkEntity({
    this.id = 0,
    required this.uuid,
    required this.title,
    required this.url,
    required this.description,
    required this.tags,
    required this.createdAt,
    required this.updatedAt,
    this.serverUpdatedAt,
    this.syncStateCode = 0,
    this.rev = 0,
    this.imageUrls = const [],
    this.videoUrl,
  });

  /// Internal PK assigned by the database. 0 means "new / not yet persisted".
  int id;

  @override
  String uuid;

  String title;
  String url;
  String description;
  List<String> tags;
  List<String> imageUrls;
  String? videoUrl;
  DateTime createdAt;

  @override
  DateTime updatedAt;

  DateTime? serverUpdatedAt;

  @override
  int rev;

  int syncStateCode;

  @override
  SyncState get syncState => SyncState.fromCode(syncStateCode);

  @override
  set syncState(SyncState value) => syncStateCode = value.code;
}
