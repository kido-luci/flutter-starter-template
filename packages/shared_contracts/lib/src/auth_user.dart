/// Authenticated user identity exposed to the presentation layer.
class AuthUser {
  const AuthUser({required this.id, required this.username});

  final String id;
  final String username;
}
