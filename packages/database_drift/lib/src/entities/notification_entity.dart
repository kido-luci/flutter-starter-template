/// Mutable persistence row for a notification cache entry.
///
/// This is a pure persistence model; domain mapping lives in the notifications
/// feature's data layer.
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

  int id;
  String uuid;
  String title;
  String body;
  String type;
  bool isRead;
  DateTime createdAt;
  bool pendingRead;
}
