import 'package:objectbox/objectbox.dart' hide SyncState;
import 'package:sync/sync.dart';

import '../../domain/entities/bookmark.dart';

/// ObjectBox row for a bookmark. Mutable by necessity — ObjectBox writes back
/// into instances during property loading, so this cannot be a Freezed/sealed
/// class.
@Entity()
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

  /// ObjectBox primary key. Internal — never exposed to the domain layer.
  /// 0 means "new"; ObjectBox assigns it on first `put`.
  @Id()
  int id;

  /// Stable string ID used by the domain layer and by the server. Generated
  /// client-side at create time so the row has a meaningful id before the
  /// first successful sync.
  @override
  @Unique()
  String uuid;

  String title;
  String url;
  String description;
  List<String> tags;
  List<String> imageUrls;
  String? videoUrl;

  /// Stored and read back as UTC. Domain layer handles any presentation-time
  /// conversion to local.
  @Property(type: PropertyType.dateNanoUtc)
  DateTime createdAt;

  /// Local mutation time — bumped on any local change. The sync engine compares
  /// it before/after a push to detect a concurrent edit (the lost-update guard).
  @override
  @Property(type: PropertyType.dateNanoUtc)
  DateTime updatedAt;

  /// Server's view of `updatedAt` at the time of the last successful pull/push.
  /// `null` for rows that haven't been synced yet (pendingCreate).
  @Property(type: PropertyType.dateNanoUtc)
  DateTime? serverUpdatedAt;

  /// The server revision this row was last reconciled to. Drives delta sync and
  /// conflict detection. 0 until first acknowledged by the server.
  @override
  int rev;

  /// Stored form of [syncState]. Use the [syncState] getter/setter instead.
  int syncStateCode;

  @override
  @Transient()
  SyncState get syncState => SyncState.fromCode(syncStateCode);
  @override
  set syncState(SyncState value) => syncStateCode = value.code;

  Bookmark toDomain() => Bookmark(
    id: uuid,
    title: title,
    url: url,
    description: description,
    tags: List.unmodifiable(tags),
    imageUrls: List.unmodifiable(imageUrls),
    videoUrl: videoUrl,
    createdAt: createdAt,
    updatedAt: updatedAt,
    isPendingSync: syncState.isPending,
    isConflicted: syncState == SyncState.conflicted,
    isFailed: syncState == SyncState.failed,
  );

  /// Mutates this entity from a [BookmarkInput] for create/update flows.
  /// Bumps `updatedAt`; leaves `createdAt` alone so updates preserve it.
  void applyInput(BookmarkInput input, {required DateTime now}) {
    title = input.title;
    url = input.url;
    description = input.description;
    tags = List.of(input.tags);
    imageUrls = List.of(input.imageUrls);
    videoUrl = input.videoUrl;
    updatedAt = now;
  }
}
