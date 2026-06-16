import 'package:objectbox/objectbox.dart';

/// ObjectBox row caching a single notification. Mutable by necessity —
/// ObjectBox writes back into instances during property loading.
///
/// Identity at this layer is the string [uuid] (the server id). The integer
/// [id] is an internal ObjectBox PK that callers never see. Pure persistence
/// model: domain conversion (and the raw-type mapping) lives in the
/// notifications feature's data layer (`NotificationEntityMapper`).
@Entity()
class NotificationEntity {
  NotificationEntity({
    this.id = 0,
    required this.uuid,
    required this.title,
    required this.body,
    required this.type,
    required this.isRead,
    required this.createdAt,
    this.pendingRead = false,
  });

  /// ObjectBox primary key. Internal — never exposed to the domain layer.
  @Id()
  int id;

  /// Server id, stable across syncs.
  @Unique()
  String uuid;

  String title;
  String body;

  /// Raw server category (e.g. `social`); mapped to the domain notification
  /// type in the feature data layer. Stored raw so an unknown future type
  /// round-trips intact.
  String type;

  bool isRead;

  /// Stored and read back as UTC.
  @Property(type: PropertyType.dateNanoUtc)
  DateTime createdAt;

  /// `true` when the read-mark was set locally but hasn't been pushed to the
  /// server yet. Keeps the pull reconciler from overwriting an unsynced read.
  bool pendingRead;
}
