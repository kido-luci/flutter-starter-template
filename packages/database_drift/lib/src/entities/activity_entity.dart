/// Mutable persistence row for an activity-log cache entry.
///
/// This is a pure persistence model; domain mapping lives in the notifications
/// feature's data layer.
class ActivityEntity {
  ActivityEntity({
    this.id = 0,
    required this.uuid,
    required this.description,
    required this.type,
    required this.createdAt,
  });

  int id;
  String uuid;
  String description;
  String type;
  DateTime createdAt;
}
