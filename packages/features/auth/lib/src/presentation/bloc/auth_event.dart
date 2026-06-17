part of 'auth_bloc.dart';

sealed class AuthEvent {
  const AuthEvent();
}

final class AuthSessionRestoreRequested extends AuthEvent {
  const AuthSessionRestoreRequested();
}

final class AuthSessionCleared extends AuthEvent {
  const AuthSessionCleared();
}

final class AuthSignInRequested extends AuthEvent {
  const AuthSignInRequested({
    required this.username,
    required this.password,
  });

  final String username;
  final String password;
}

final class AuthRegisterRequested extends AuthEvent {
  const AuthRegisterRequested({
    required this.username,
    required this.password,
  });

  final String username;
  final String password;
}

final class AuthSignOutRequested extends AuthEvent {
  const AuthSignOutRequested();
}
