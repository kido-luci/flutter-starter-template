import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:shared_contracts/shared_contracts.dart';
import 'package:shared_ui/shared_ui.dart';
import 'bloc/auth_bloc.dart';
import 'bloc/auth_state.dart';

/// Adapts [AuthBloc] to the app-wide [Session] contract.
///
/// Keeps [AuthBloc] as the single source of truth while exposing only the
/// session surface other features need, so they don't depend on auth's
/// presentation layer.
class AuthSession extends ChangeNotifier implements Session {
  AuthSession(this._bloc) {
    _subscription = _bloc.stream.listen((_) => notifyListeners());
  }

  final AuthBloc _bloc;
  late final StreamSubscription<AuthState> _subscription;

  @override
  AuthUser? get currentUser => switch (_bloc.state) {
    AuthAuthenticated(:final user) || AuthSigningOut(:final user) => user,
    _ => null,
  };

  @override
  bool get isSigningOut => _bloc.state is AuthSigningOut;

  @override
  Future<void> restore() async {
    final settled = _bloc.stream.firstWhere(
      (state) =>
          state is AuthAuthenticated ||
          state is AuthInitial ||
          state is AuthFailure,
      orElse: () => _bloc.state,
    );
    _bloc.add(const AuthSessionRestoreRequested());
    await settled;
  }

  @override
  void signOut() => _bloc.add(const AuthSignOutRequested());

  @override
  void clearSession() => _bloc.add(const AuthSessionCleared());

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
