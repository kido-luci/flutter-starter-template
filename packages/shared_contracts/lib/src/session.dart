import 'package:flutter/foundation.dart';

import 'auth_user.dart';

/// Application-wide authenticated session, readable by any feature.
///
/// Decouples feature UI from the auth feature's presentation layer: features
/// depend on this contract (in `shared_contracts`) instead of reaching into
/// `AuthBloc`. The auth feature provides the implementation.
///
/// Listenable so widgets can rebuild on session changes via
/// `ListenableBuilder`.
abstract interface class Session implements Listenable {
  /// The authenticated user, or `null` when no one is signed in.
  AuthUser? get currentUser;

  /// Whether a sign-out is currently in progress.
  bool get isSigningOut;

  /// Restores any persisted login.
  ///
  /// Completes once the session status settles (authenticated,
  /// unauthenticated, or failed). Called by the splash gate on startup.
  Future<void> restore();

  /// Ends the current session. UI reacts to the change via [isSigningOut]
  /// and [currentUser]; callers don't need to await.
  void signOut();

  /// Clears session state locally without a sign-out request.
  ///
  /// Used after the account is already gone server-side (e.g. account
  /// deletion), so the router redirects to login.
  void clearSession();

  /// Releases resources. Called by the owner when the session is no longer
  /// needed.
  void dispose();
}
