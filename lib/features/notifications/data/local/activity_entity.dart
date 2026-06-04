import 'package:objectbox/objectbox.dart';

import '../../domain/entities/user_activity.dart';

/// ObjectBox row caching a single activity-log entry. Read-only from the user's
/// perspective — the server owns the log, so this is only ever filled by sync.
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

  /// Raw server activity type (e.g. `signed_in`); mapped to [UserActivityType]
  /// in [toDomain]. Stored raw so an unknown future type round-trips intact.
  String type;

  /// Stored and read back as UTC.
  @Property(type: PropertyType.dateNanoUtc)
  DateTime createdAt;

  UserActivity toDomain() => UserActivity(
    id: uuid,
    description: description,
    type: activityTypeFromRaw(type),
    createdAt: createdAt,
  );
}

/// Maps a raw server activity type to its [UserActivityType], defaulting to
/// [UserActivityType.other] for unrecognized values.
UserActivityType activityTypeFromRaw(String raw) => switch (raw) {
  'created' => UserActivityType.created,
  'updated' => UserActivityType.updated,
  'deleted' => UserActivityType.deleted,
  'signed_in' => UserActivityType.signedIn,
  _ => UserActivityType.other,
};
