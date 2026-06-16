import 'package:database/database.dart';
import '../../domain/entities/user_activity.dart';

/// Maps the persistence [ActivityEntity] to the domain [UserActivity].
///
/// Lives in the feature data layer (not on the entity) so the dependency
/// direction stays `feature → database` and the entity stays domain-free.
extension ActivityEntityMapper on ActivityEntity {
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
