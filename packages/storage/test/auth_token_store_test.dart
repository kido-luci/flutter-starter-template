import 'package:flutter_test/flutter_test.dart';
import 'package:storage/storage.dart';

class _FakeSecureStorage extends Fake implements FlutterSecureStorage {
  final Map<String, String> _data = {};

  @override
  Future<Map<String, String>> readAll({
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async => Map.of(_data);

  @override
  Future<void> write({
    required String key,
    required String? value,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (value == null) {
      _data.remove(key);
    } else {
      _data[key] = value;
    }
  }

  @override
  Future<void> delete({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async => _data.remove(key);
}

void main() {
  late _FakeSecureStorage storage;
  late SecureAuthTokenStore store;

  setUp(() {
    storage = _FakeSecureStorage();
    store = SecureAuthTokenStore(storage);
  });

  test('load reads persisted tokens into memory', () async {
    await storage.write(key: 'auth.access_token', value: 'a');
    await storage.write(key: 'auth.refresh_token', value: 'r');

    await store.load();

    expect(store.accessToken, 'a');
    expect(store.refreshToken, 'r');
  });

  test('updateTokens persists and caches', () async {
    await store.updateTokens(accessToken: 'a2', refreshToken: 'r2');

    expect(store.accessToken, 'a2');
    expect(store.refreshToken, 'r2');
    expect(await storage.readAll(), {
      'auth.access_token': 'a2',
      'auth.refresh_token': 'r2',
    });
  });

  test('clearTokens wipes memory and storage', () async {
    await store.updateTokens(accessToken: 'a', refreshToken: 'r');

    await store.clearTokens();

    expect(store.accessToken, isNull);
    expect(store.refreshToken, isNull);
    expect(await storage.readAll(), isEmpty);
  });
}
