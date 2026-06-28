import 'package:rev_sync/rev_sync.dart';

/// Mutable persistence row for a collection, compatible with [SyncLocalStore].
///
/// This is a pure persistence model; domain mapping lives in the collections
/// feature's data layer.
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

  int id;

  @override
  String uuid;

  String name;
  String icon;
  int color;

  /// UUID references — same denormalised design as the ObjectBox version.
  List<String> bookmarkIds;

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
