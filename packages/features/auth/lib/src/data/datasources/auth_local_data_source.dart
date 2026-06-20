import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:shared_contracts/shared_contracts.dart';
import 'package:storage/storage.dart';

/// Persists the active authentication session — current user, access token,
/// and refresh token — in platform-encrypted storage (Keychain on iOS,
/// EncryptedSharedPreferences/Keystore on Android).
///
/// All getters cache in memory after the first read so the Dio interceptor's
/// hot path doesn't hit native channels per request. `load` is awaited once
/// during session restore (see `AuthRepositoryImpl.restoreSession`, driven by
/// the splash screen) before any token-bearing request is made; it is a no-op
/// on subsequent calls.
abstract interface class AuthLocalDataSource {
  AuthUser? get currentUser;
  String? get accessToken;
  String? get refreshToken;

  Future<void> load();
  Future<void> setSession({
    required AuthUser user,
    required String accessToken,
    required String refreshToken,
  });
  Future<void> updateTokens({
    required String accessToken,
    required String refreshToken,
  });
  Future<void> clearSession();
}

const _kUserKey = 'auth.user';

@LazySingleton(as: AuthLocalDataSource)
class SecureStorageAuthDataSource implements AuthLocalDataSource {
  SecureStorageAuthDataSource(this._storage, this._tokens);

  final FlutterSecureStorage _storage;
  final AuthTokenStore _tokens;

  AuthUser? _user;
  bool _loaded = false;

  @override
  AuthUser? get currentUser => _user;

  @override
  String? get accessToken => _tokens.accessToken;

  @override
  String? get refreshToken => _tokens.refreshToken;

  @override
  Future<void> load() async {
    if (_loaded) return;
    await _tokens.load();
    final userJson = await _storage.read(key: _kUserKey);
    if (userJson != null) {
      try {
        final map = jsonDecode(userJson) as Map<String, dynamic>;
        _user = AuthUser(
          id: map['id'] as String,
          username: map['username'] as String,
        );
      } on Object {
        // Corrupt persisted user — treat as no session rather than throwing on
        // every launch. Drop the bad entry so the next cold start is clean.
        _user = null;
        await _storage.delete(key: _kUserKey);
      }
    }
    _loaded = true;
  }

  @override
  Future<void> setSession({
    required AuthUser user,
    required String accessToken,
    required String refreshToken,
  }) async {
    _user = user;
    _loaded = true;
    await Future.wait([
      _storage.write(
        key: _kUserKey,
        value: jsonEncode({'id': user.id, 'username': user.username}),
      ),
      _tokens.updateTokens(accessToken: accessToken, refreshToken: refreshToken),
    ]);
  }

  @override
  Future<void> updateTokens({
    required String accessToken,
    required String refreshToken,
  }) => _tokens.updateTokens(
    accessToken: accessToken,
    refreshToken: refreshToken,
  );

  @override
  Future<void> clearSession() async {
    _user = null;
    await Future.wait([
      _storage.delete(key: _kUserKey),
      _tokens.clearTokens(),
    ]);
  }
}
