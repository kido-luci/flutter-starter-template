import 'package:architecture/architecture.dart';
import 'package:shared_contracts/shared_contracts.dart';

abstract interface class AuthRepository {
  Future<Result<AuthUser>> signIn({
    required String username,
    required String password,
  });

  Future<Result<AuthUser>> register({
    required String username,
    required String password,
  });

  Future<Result<void>> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  Future<Result<void>> signOut();

  /// Permanently deletes the current account on the server and clears the
  /// local session. Unlike [signOut], the local session is only cleared when
  /// the server confirms the deletion, so a failure leaves the user signed in.
  Future<Result<void>> deleteAccount();

  /// Loads any persisted session and attempts to refresh its access token.
  /// Returns `Ok(user)` if a valid session can be restored, otherwise `Err`.
  Future<Result<AuthUser>> restoreSession();

  AuthUser? get currentUser;
}
