/// Kind of action the user performed, used to pick an icon in the UI.
enum UserActivityType { created, updated, deleted, signedIn, other }

/// A single entry in the current user's recent activity log.
class UserActivity {
  const UserActivity({
    required this.id,
    required this.description,
    required this.type,
    required this.createdAt,
  });

  final String id;
  final String description;
  final UserActivityType type;
  final DateTime createdAt;
}
