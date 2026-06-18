import 'package:architecture/architecture.dart';
import 'package:injectable/injectable.dart';
import 'package:network/network.dart';

import 'package:shared_contracts/shared_contracts.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/change_password_request.dart';
import '../models/refresh_token_request.dart';
import '../models/register_request.dart';
import '../models/sign_in_request.dart';
import '../network/token_refresher.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remote, this._local, this._refresher);

  final AuthRemoteDataSource _remote;
  final AuthLocalDataSource _local;
  final TokenRefresher _refresher;

  @override
  AuthUser? get currentUser => _local.currentUser;

  @override
  Future<Result<AuthUser>> signIn({
    required String username,
    required String password,
  }) async {
    try {
      final response = await _remote.signIn(
        SignInRequest(username: username, password: password),
      );
      final user = response.user.toDomain();
      await _local.setSession(
        user: user,
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
      );
      return Ok(user);
    } on DioException catch (e) {
      return Err(_mapDioError(e));
    } on Object {
      // A malformed response body makes the parse throw a non-Dio error; map
      // it to a failure instead of letting it escape into the bloc.
      return const Err(UnknownFailure('Unexpected server response'));
    }
  }

  @override
  Future<Result<AuthUser>> register({
    required String username,
    required String password,
  }) async {
    try {
      final response = await _remote.register(
        RegisterRequest(username: username, password: password),
      );
      final user = response.user.toDomain();
      await _local.setSession(
        user: user,
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
      );
      return Ok(user);
    } on DioException catch (e) {
      return Err(_mapDioError(e));
    } on Object {
      // A malformed response body makes the parse throw a non-Dio error; map
      // it to a failure instead of letting it escape into the bloc.
      return const Err(UnknownFailure('Unexpected server response'));
    }
  }

  @override
  Future<Result<void>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _remote.changePassword(
        ChangePasswordRequest(
          currentPassword: currentPassword,
          newPassword: newPassword,
        ),
      );
      return const Ok(null);
    } on DioException catch (e) {
      return Err(_mapDioError(e));
    }
  }

  @override
  Future<Result<void>> signOut() async {
    final refreshToken = _local.refreshToken;
    if (refreshToken != null) {
      try {
        await _remote.signOut(RefreshTokenRequest(refreshToken: refreshToken));
      } on DioException {
        // Best-effort: drop the local session even if the server call fails so
        // the user isn't stuck signed in after a network blip.
      }
    }
    await _local.clearSession();
    return const Ok(null);
  }

  @override
  Future<Result<void>> deleteAccount() async {
    try {
      await _remote.deleteAccount();
      // Only drop the local session once the server confirms deletion, so a
      // failed request leaves the user signed in to retry.
      await _local.clearSession();
      return const Ok(null);
    } on DioException catch (e) {
      return Err(_mapDioError(e));
    }
  }

  @override
  Future<Result<AuthUser>> restoreSession() async {
    await _local.load();
    final user = _local.currentUser;
    final refreshToken = _local.refreshToken;
    if (user == null || refreshToken == null) {
      return const Err(NoSessionFailure());
    }
    final outcome = await _refresher.refresh();
    switch (outcome) {
      case RefreshOutcome.refreshed:
        return Ok(user);
      case RefreshOutcome.networkError:
        // Offline or a transient server error at launch. Restore the session
        // optimistically and let AuthInterceptor refresh lazily on the first
        // 401 once connectivity returns. Wiping a possibly-valid session here
        // is what forced offline users to re-login.
        return Ok(user);
      case RefreshOutcome.invalidSession:
        // The refresher already cleared storage on a genuine token rejection.
        return const Err(NoSessionFailure('Session expired.'));
    }
  }

  Failure _mapDioError(DioException e) {
    final status = e.response?.statusCode;
    if (status == 401) {
      final message =
          _extractMessage(e.response?.data) ?? 'Invalid username or password.';
      return InvalidCredentialsFailure(message);
    }
    return UnknownFailure(e.message ?? 'Network error');
  }

  String? _extractMessage(Object? body) {
    if (body is Map<String, dynamic>) {
      final message = body['message'];
      if (message is String) return message;
    }
    return null;
  }
}
