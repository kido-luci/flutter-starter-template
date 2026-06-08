import 'package:analytics/analytics.dart';
import 'package:architecture/architecture.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/usecases/register.dart';
import '../../domain/usecases/restore_session.dart';
import '../../domain/usecases/sign_in.dart';
import '../../domain/usecases/sign_out.dart';
import 'auth_state.dart';

part 'auth_event.dart';

@lazySingleton
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required this._signIn,
    required this._register,
    required this._signOut,
    required this._restoreSession,
    required this._analytics,
  }) : super(const AuthState.initial()) {
    on<AuthSessionRestoreRequested>(
      _onSessionRestoreRequested,
      transformer: droppable(),
    );
    on<AuthSessionCleared>(_onSessionCleared);
    on<AuthSignInRequested>(_onSignInRequested, transformer: droppable());
    on<AuthRegisterRequested>(_onRegisterRequested, transformer: droppable());
    on<AuthSignOutRequested>(_onSignOutRequested, transformer: droppable());
  }

  final SignIn _signIn;
  final Register _register;
  final SignOut _signOut;
  final RestoreSession _restoreSession;
  final AnalyticsService _analytics;

  Future<void> _onSessionRestoreRequested(
    AuthSessionRestoreRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.restoring());
    final result = await _restoreSession();
    switch (result) {
      case Ok(value: final user):
        _analytics.setCurrentUser(user.id).fire();
        emit(AuthState.authenticated(user));
      case Err(failure: NoSessionFailure()):
        // Expected on first launch / after sign-out — not an error.
        _analytics.setCurrentUser(null).fire();
        emit(const AuthState.initial());
      case Err(:final failure):
        _analytics.setCurrentUser(null).fire();
        emit(AuthState.failure(failure));
    }
  }

  void _onSessionCleared(
    AuthSessionCleared event,
    Emitter<AuthState> emit,
  ) {
    emit(const AuthState.initial());
  }

  Future<void> _onSignInRequested(
    AuthSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.submitting());
    final result = await _signIn((
      username: event.username,
      password: event.password,
    ));
    switch (result) {
      case Ok(value: final user):
        _analytics.setCurrentUser(user.id).fire();
        _analytics.logLogin(method: 'password').fire();
        emit(AuthState.authenticated(user));
      case Err(:final failure):
        _analytics
            .trackLoginFailed(errorType: failure.runtimeType.toString())
            .fire();
        emit(AuthState.failure(failure));
    }
  }

  Future<void> _onRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.submitting());
    final result = await _register((
      username: event.username,
      password: event.password,
    ));
    switch (result) {
      case Ok(value: final user):
        _analytics.setCurrentUser(user.id).fire();
        _analytics.logSignUp(signUpMethod: 'password').fire();
        emit(AuthState.authenticated(user));
      case Err(:final failure):
        _analytics
            .trackLoginFailed(errorType: failure.runtimeType.toString())
            .fire();
        emit(AuthState.failure(failure));
    }
  }

  Future<void> _onSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    final current = state;
    if (current is AuthAuthenticated) {
      emit(AuthState.signingOut(current.user));
    }
    final result = await _signOut();
    _analytics.setCurrentUser(null).fire();
    if (result case Ok<void>()) {
      _analytics.trackSignOut().fire();
    }
    // Sign-out is best-effort: drop session locally regardless of result so the
    // user isn't stuck if the server call failed.
    emit(const AuthState.initial());
  }
}
