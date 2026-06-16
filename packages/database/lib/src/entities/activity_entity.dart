import 'package:objectbox/objectbox.dart';

/// ObjectBox row caching a single activity-log entry. Read-only from the user's
/// perspective — the server owns the log, so this is only ever filled by sync.
///
/// Pure persistence model: domain conversion (and the raw-type mapping) lives
/// in the notifications feature's data layer (`ActivityEntityMapper`).
@Entity()
class ActivityEntity {
  ActivityEntity({
    this.id = 0,
    required this.uuid,
    required this.description,
    required this.type,
    required this.createdAt,
  });

  /// ObjectBox primary key. Internal — never exposed to the domain layer.
  @Id()
  int id;

  /// Server id, stable across syncs.
  @Unique()
  String uuid;

  String description;

  /// Raw server activity type (e.g. `signed_in`); mapped to the domain activity
  /// type in the feature data layer. Stored raw so an unknown future type
  /// round-trips intact.
  String type;

  /// Stored and read back as UTC.
  @Property(type: PropertyType.dateNanoUtc)
  DateTime createdAt;
}
