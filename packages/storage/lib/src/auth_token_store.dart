import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

/// Persists the authentication tokens (access + refresh) in platform-encrypted
/// storage. This is the source of truth the network transport reads from.
abstract interface class AuthTokenStore {
  String? get accessToken;
  String? get refreshToken;

  /// Loads persisted tokens into the in-memory cache. Idempotent.
  Future<void> load();

  Future<void> updateTokens({
    required String accessToken,
    required String refreshToken,
  });

  /// Clears tokens only (not the persisted user). Used on a genuine token
  /// rejection; the next cold start sees no refresh token and routes to login.
  Future<void> clearTokens();
}

const _kAccessKey = 'auth.access_token';
const _kRefreshKey = 'auth.refresh_token';

@LazySingleton(as: AuthTokenStore)
class SecureAuthTokenStore implements AuthTokenStore {
  SecureAuthTokenStore(this._storage);

  final FlutterSecureStorage _storage;

  String? _accessToken;
  String? _refreshToken;
  bool _loaded = false;

  @override
  String? get accessToken => _accessToken;

  @override
  String? get refreshToken => _refreshToken;

  @override
  Future<void> load() async {
    if (_loaded) return;
    final values = await _storage.readAll();
    _accessToken = values[_kAccessKey];
    _refreshToken = values[_kRefreshKey];
    _loaded = true;
  }

  @override
  Future<void> updateTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    _loaded = true;
    await Future.wait([
      _storage.write(key: _kAccessKey, value: accessToken),
      _storage.write(key: _kRefreshKey, value: refreshToken),
    ]);
  }

  @override
  Future<void> clearTokens() async {
    _accessToken = null;
    _refreshToken = null;
    await Future.wait([
      _storage.delete(key: _kAccessKey),
      _storage.delete(key: _kRefreshKey),
    ]);
  }
}
