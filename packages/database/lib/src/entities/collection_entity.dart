import 'package:objectbox/objectbox.dart' hide SyncState;
import 'package:sync/sync.dart';

/// ObjectBox row for a collection. Mutable by necessity — ObjectBox writes
/// back into instances during property loading, so this cannot be a
/// Freezed/sealed class.
///
/// Pure persistence model: domain conversion lives in the collections feature's
/// data layer (`CollectionEntityMapper`).
@Entity()
class CollectionEntity implements Syncable {
  CollectionEntity({
    this.id = 0,
    required this.uuid,
    required this.name,
    required this.icon,
    required this.color,
    required this.bookmarkIds,
    required this.createdAt,
    required this.updatedAt,
    this.serverUpdatedAt,
    this.syncStateCode = 0,
    this.rev = 0,
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

  String name;
  String icon;
  int color;
  List<String> bookmarkIds;

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
}
