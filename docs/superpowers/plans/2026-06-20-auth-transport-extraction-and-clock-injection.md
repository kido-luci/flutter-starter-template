# Auth Transport Extraction + Testable Clock — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Move the authenticated `Dio` (auth interceptor + 401 refresh + token store) out of `feature_auth` and into the infra layer (`network` + `storage`) so feature→transport coupling becomes static and layering-enforced, and make data/domain time deterministic via the `clock` package.

**Architecture:** `storage` owns an `AuthTokenStore` (token persistence) and the `FlutterSecureStorage` provider. `network` owns the authenticated `Dio`, `AuthInterceptor`, and `TokenRefresher`, reading tokens through `storage.AuthTokenStore`. `feature_auth` keeps user/session flows and delegates token persistence to the shared `AuthTokenStore`. Every API feature already depends on `network`, so the previously-hidden runtime edge (`feature → auth's Dio`) disappears. Clock changes are independent and use the `clock` package's ambient `clock.now()`.

**Tech Stack:** Dart pub workspace, `injectable`/`get_it` DI (micro-packages), `dio`, `flutter_secure_storage`, `clock`, `mocktail` (via `test_utils`), FVM-pinned Flutter 3.44.0.

**Conventions for every task:**
- All Flutter/Dart commands go through FVM: `fvm flutter ...`, `fvm dart ...`.
- After changing any `injectable` annotation (`@module`, `@LazySingleton`, constructor params of an injected class), regenerate that package's DI:
  `(cd packages/<pkg> && fvm dart run build_runner build --delete-conflicting-outputs)`; for the root app use `fvm dart run build_runner build --delete-conflicting-outputs` at the repo root.
- Do this work on a feature branch (e.g. `git checkout -b refactor/auth-transport-extraction`), not on `main`.

---

## Task 1: Clock in `feature_bookmarks` (repository + stats service)

**Files:**
- Modify: `packages/features/bookmarks/pubspec.yaml` (add `clock`)
- Modify: `packages/features/bookmarks/lib/src/data/repositories/bookmarks_repository_impl.dart`
- Modify: `packages/features/bookmarks/lib/src/domain/services/bookmark_stats_service.dart`
- Test: `packages/features/bookmarks/test/data/repositories/bookmarks_repository_impl_test.dart` (exists)

- [ ] **Step 1: Add the `clock` dependency**

Run:
```bash
(cd packages/features/bookmarks && fvm flutter pub add clock)
```
Expected: `clock` appears under `dependencies:` in `packages/features/bookmarks/pubspec.yaml`.

- [ ] **Step 2: Write a failing test asserting deterministic create timestamps**

Add to `packages/features/bookmarks/test/data/repositories/bookmarks_repository_impl_test.dart` (inside the existing `main()`'s group; reuse the file's existing fakes for `BookmarksLocalDataSource`, `BookmarksSyncController`, `Uuid`):

```dart
import 'package:clock/clock.dart';
// ... existing imports

test('create stamps createdAt/updatedAt from the ambient clock', () async {
  final fixed = DateTime.utc(2026, 1, 2, 3, 4, 5);
  await withClock(Clock.fixed(fixed), () async {
    await repository.create(
      const BookmarkInput(
        title: 'T',
        url: 'https://e.com',
        description: '',
        tags: [],
        imageUrls: [],
        videoUrl: null,
      ),
    );
  });
  final captured =
      verify(() => local.putNew(captureAny())).captured.single
          as BookmarkEntity;
  expect(captured.createdAt, fixed);
  expect(captured.updatedAt, fixed);
});
```

(If the test file builds its subject differently, match its existing setup — the assertion on `createdAt`/`updatedAt == fixed` is the point.)

- [ ] **Step 3: Run the test to verify it fails**

Run:
```bash
fvm flutter test packages/features/bookmarks/test/data/repositories/bookmarks_repository_impl_test.dart --plain-name "ambient clock"
```
Expected: FAIL — `createdAt` equals real now, not `fixed`.

- [ ] **Step 4: Switch the repository to `clock.now()`**

In `bookmarks_repository_impl.dart`, add the import and replace the three `DateTime.now().toUtc()` call sites:

```dart
import 'package:clock/clock.dart';
```

- In `create()`: `final now = DateTime.now().toUtc();` → `final now = clock.now().toUtc();`
- In `update()`: `existing.applyInput(normalized, now: DateTime.now().toUtc());` → `existing.applyInput(normalized, now: clock.now().toUtc());`
- In `delete()`: `existing.updatedAt = DateTime.now().toUtc();` → `existing.updatedAt = clock.now().toUtc();`

- [ ] **Step 5: Switch the stats service to `clock.now()`**

In `bookmark_stats_service.dart`, add `import 'package:clock/clock.dart';` and change line 31:

```dart
final cutoff = clock.now().subtract(_recentWindow);
```

- [ ] **Step 6: Run the bookmarks test suite**

Run:
```bash
fvm flutter test packages/features/bookmarks/test
```
Expected: PASS (the new test plus all existing tests).

- [ ] **Step 7: Commit**

```bash
git add packages/features/bookmarks
git commit -m "refactor(bookmarks): use clock.now() for deterministic time"
```

---

## Task 2: Clock in `feature_collections` (repository)

**Files:**
- Modify: `packages/features/collections/pubspec.yaml` (add `clock`)
- Modify: `packages/features/collections/lib/src/data/repositories/collections_repository_impl.dart`
- Test: `packages/features/collections/test/data/repositories/collections_repository_impl_test.dart`

- [ ] **Step 1: Add the `clock` dependency**

Run:
```bash
(cd packages/features/collections && fvm flutter pub add clock)
```
Expected: `clock` under `dependencies:`.

- [ ] **Step 2: Write a failing test for deterministic create timestamps**

Add to the collections repository test (mirror Task 1's structure with the collections fakes):

```dart
import 'package:clock/clock.dart';

test('create stamps createdAt/updatedAt from the ambient clock', () async {
  final fixed = DateTime.utc(2026, 1, 2, 3, 4, 5);
  await withClock(Clock.fixed(fixed), () async {
    await repository.create(const CollectionInput(name: 'C', bookmarkIds: []));
  });
  final captured =
      verify(() => local.putNew(captureAny())).captured.single
          as CollectionEntity;
  expect(captured.createdAt, fixed);
  expect(captured.updatedAt, fixed);
});
```

(Match `CollectionInput`'s actual required fields if they differ.)

- [ ] **Step 3: Run the test to verify it fails**

Run:
```bash
fvm flutter test packages/features/collections/test/data/repositories/collections_repository_impl_test.dart --plain-name "ambient clock"
```
Expected: FAIL.

- [ ] **Step 4: Switch the repository to `clock.now()`**

In `collections_repository_impl.dart`, add `import 'package:clock/clock.dart';` and replace the three sites:
- `create()` line 50: `final now = clock.now().toUtc();`
- `update()` line 73: `existing.applyInput(normalized, now: clock.now().toUtc());`
- `delete()` line 98: `existing.updatedAt = clock.now().toUtc();`

- [ ] **Step 5: Run the collections test suite**

Run:
```bash
fvm flutter test packages/features/collections/test
```
Expected: PASS.

- [ ] **Step 6: Commit**

```bash
git add packages/features/collections
git commit -m "refactor(collections): use clock.now() for deterministic time"
```

---

## Task 3: Move the `FlutterSecureStorage` provider into `storage`

The `FlutterSecureStorage` provider currently lives in `feature_auth`
(`SecureStorageModule` in `auth_local_data_source.dart`), but `storage`'s own
`KeychainResetOnReinstall` already depends on `FlutterSecureStorage` — a
pre-existing `storage → auth` runtime edge. Moving the provider to `storage`
(its natural home) fixes that and is a prerequisite for `storage` owning the
token store.

**Files:**
- Create: `packages/storage/lib/src/secure_storage_module.dart`
- Modify: `packages/storage/lib/storage.dart` (no change needed if module is auto-collected; verify)
- Modify: `packages/features/auth/lib/src/data/datasources/auth_local_data_source.dart` (remove `SecureStorageModule`)

- [ ] **Step 1: Create the provider in `storage`**

Create `packages/storage/lib/src/secure_storage_module.dart`:

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

/// Provides the app-wide [FlutterSecureStorage] instance to the DI graph.
@module
abstract class SecureStorageModule {
  @lazySingleton
  FlutterSecureStorage provideSecureStorage() => const FlutterSecureStorage(
    // iOS: tokens stay accessible after the first unlock (so background token
    // refresh keeps working) but are device-only — never synced to iCloud
    // Keychain and never restored onto a different device. Android needs no
    // tuning here: this version already defaults to a strong AES-GCM +
    // RSA-OAEP KeyStore backend.
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );
}
```

- [ ] **Step 2: Remove the provider from `feature_auth`**

In `packages/features/auth/lib/src/data/datasources/auth_local_data_source.dart`, delete the entire `SecureStorageModule` block (lines 128–141, the `@module abstract class SecureStorageModule { ... }`). Leave the `import 'package:storage/storage.dart';` at the top (still used for `FlutterSecureStorage`).

- [ ] **Step 3: Regenerate DI for both packages**

Run:
```bash
(cd packages/storage && fvm dart run build_runner build --delete-conflicting-outputs)
(cd packages/features/auth && fvm dart run build_runner build --delete-conflicting-outputs)
```
Expected: `storage`'s generated module now registers `FlutterSecureStorage`; `feature_auth`'s no longer does.

- [ ] **Step 4: Verify both suites pass**

Run:
```bash
(cd packages/storage && fvm flutter test)
(cd packages/features/auth && fvm flutter test)
```
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add packages/storage packages/features/auth
git commit -m "refactor(storage): own the FlutterSecureStorage provider"
```

---

## Task 4: Add `AuthTokenStore` to `storage`

**Files:**
- Create: `packages/storage/lib/src/auth_token_store.dart`
- Modify: `packages/storage/lib/storage.dart` (export the port)
- Test: `packages/storage/test/auth_token_store_test.dart`

- [ ] **Step 1: Write the failing test**

Create `packages/storage/test/auth_token_store_test.dart`:

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:storage/storage.dart';

class _FakeSecureStorage extends Fake implements FlutterSecureStorage {
  final Map<String, String> _data = {};

  @override
  Future<Map<String, String>> readAll({
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async => Map.of(_data);

  @override
  Future<void> write({
    required String key,
    required String? value,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
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
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
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
```

- [ ] **Step 2: Run it to verify it fails**

Run:
```bash
fvm flutter test packages/storage/test/auth_token_store_test.dart
```
Expected: FAIL — `SecureAuthTokenStore` / `AuthTokenStore` undefined.

- [ ] **Step 3: Implement the port + impl**

Create `packages/storage/lib/src/auth_token_store.dart`:

```dart
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
```

- [ ] **Step 4: Export the port from the storage barrel**

In `packages/storage/lib/storage.dart`, add:

```dart
export 'src/auth_token_store.dart';
```

- [ ] **Step 5: Regenerate storage DI and run the test**

Run:
```bash
(cd packages/storage && fvm dart run build_runner build --delete-conflicting-outputs)
fvm flutter test packages/storage/test/auth_token_store_test.dart
```
Expected: PASS.

- [ ] **Step 6: Commit**

```bash
git add packages/storage
git commit -m "feat(storage): add AuthTokenStore (token persistence port + impl)"
```

---

## Task 5: Delegate `feature_auth` token persistence to `AuthTokenStore`

Keep the `AuthLocalDataSource` interface unchanged; route its token operations
through the injected `AuthTokenStore` so auth and the network transport share
one token source of truth. User persistence stays in auth.

**Files:**
- Modify: `packages/features/auth/lib/src/data/datasources/auth_local_data_source.dart`

- [ ] **Step 1: Inject `AuthTokenStore` and delegate token ops**

In `SecureStorageAuthDataSource`:

- Change the constructor and fields:

```dart
SecureStorageAuthDataSource(this._storage, this._tokens);

final FlutterSecureStorage _storage;
final AuthTokenStore _tokens;

AuthUser? _user;
bool _loaded = false;
```

(Remove the `_accessToken` / `_refreshToken` fields — tokens now live in `_tokens`.)

- Replace the token getters:

```dart
@override
AuthUser? get currentUser => _user;

@override
String? get accessToken => _tokens.accessToken;

@override
String? get refreshToken => _tokens.refreshToken;
```

- `load()` — load the user blob and delegate token loading:

```dart
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
      _user = null;
      await _storage.delete(key: _kUserKey);
    }
  }
  _loaded = true;
}
```

- `setSession(...)` — persist the user, delegate tokens:

```dart
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
    _tokens.updateTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    ),
  ]);
}
```

- `updateTokens(...)` — delegate:

```dart
@override
Future<void> updateTokens({
  required String accessToken,
  required String refreshToken,
}) => _tokens.updateTokens(
  accessToken: accessToken,
  refreshToken: refreshToken,
);
```

- `clearSession()` — clear the user, delegate token clear:

```dart
@override
Future<void> clearSession() async {
  _user = null;
  await Future.wait([
    _storage.delete(key: _kUserKey),
    _tokens.clearTokens(),
  ]);
}
```

Keep the `_kUserKey` constant; the `_kAccessKey` / `_kRefreshKey` constants in this file are now unused — delete them.

- [ ] **Step 2: Regenerate auth DI**

Run:
```bash
(cd packages/features/auth && fvm dart run build_runner build --delete-conflicting-outputs)
```
Expected: `SecureStorageAuthDataSource` now resolves `FlutterSecureStorage` + `AuthTokenStore`.

- [ ] **Step 3: Run the auth suite**

Run:
```bash
(cd packages/features/auth && fvm flutter test)
```
Expected: PASS. The existing `auth_repository_impl_test` mocks `AuthLocalDataSource` (interface unchanged), so it is unaffected. (`token_refresher_test` still passes — auth's refresher still reads tokens via `AuthLocalDataSource`, which now delegates to the shared store.)

- [ ] **Step 4: Commit**

```bash
git add packages/features/auth
git commit -m "refactor(auth): delegate token persistence to storage.AuthTokenStore"
```

---

## Task 6: Build the authenticated transport in `network`

Add `network`'s own `RefreshOutcome`, `TokenRefresher`, and `AuthInterceptor`
reading `storage.AuthTokenStore`. Do **not** wire the authenticated `Dio`
provider yet (Task 7) — registering it now would duplicate auth's unnamed `Dio`.

**Files:**
- Modify: `packages/network/pubspec.yaml` (add `storage`; ensure `test_utils` dev dep)
- Create: `packages/network/lib/src/token_refresher.dart`
- Create: `packages/network/lib/src/auth_interceptor.dart`
- Modify: `packages/network/lib/network.dart` (export both)
- Test: `packages/network/test/token_refresher_test.dart`
- Test: `packages/network/test/auth_interceptor_test.dart`

- [ ] **Step 1: Add dependencies**

Run:
```bash
(cd packages/network && fvm flutter pub add storage)
(cd packages/network && fvm flutter pub add dev:test_utils)
```
Expected: `storage` under `dependencies:`, `test_utils` under `dev_dependencies:`. (If either is already present, the command is a no-op.)

- [ ] **Step 2: Write the failing refresher test (migrated)**

Create `packages/network/test/token_refresher_test.dart`:

```dart
import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:network/network.dart';
import 'package:storage/storage.dart';
import 'package:test_utils/test_utils.dart';

class _MockTokenStore extends Mock implements AuthTokenStore {}

class _MockDio extends Mock implements Dio {}

void main() {
  late _MockTokenStore tokens;
  late _MockDio dio;
  late TokenRefresher refresher;

  Response<Map<String, dynamic>> okResponse(Map<String, dynamic>? body) =>
      Response<Map<String, dynamic>>(
        requestOptions: RequestOptions(path: '/api/auth/refresh'),
        statusCode: 200,
        data: body,
      );

  DioException dioError({int? status, DioExceptionType? type}) => DioException(
    requestOptions: RequestOptions(path: '/api/auth/refresh'),
    type: type ?? DioExceptionType.badResponse,
    response: status == null
        ? null
        : Response<dynamic>(
            requestOptions: RequestOptions(path: '/api/auth/refresh'),
            statusCode: status,
          ),
  );

  setUp(() {
    tokens = _MockTokenStore();
    dio = _MockDio();
    refresher = TokenRefresher(tokens, dio);
    when(() => tokens.clearTokens()).thenAnswer((_) async {});
    when(
      () => tokens.updateTokens(
        accessToken: any(named: 'accessToken'),
        refreshToken: any(named: 'refreshToken'),
      ),
    ).thenAnswer((_) async {});
  });

  void stubPost(Object Function() answer) {
    when(
      () => dio.post<Map<String, dynamic>>(any(), data: any(named: 'data')),
    ).thenAnswer((_) {
      final result = answer();
      if (result is DioException) throw result;
      return Future.value(result as Response<Map<String, dynamic>>);
    });
  }

  test('returns invalidSession and does not POST when no refresh token',
      () async {
    when(() => tokens.refreshToken).thenReturn(null);

    expect(await refresher.refresh(), RefreshOutcome.invalidSession);
    verifyNever(
      () => dio.post<Map<String, dynamic>>(any(), data: any(named: 'data')),
    );
  });

  test('refreshes and persists new tokens on success', () async {
    when(() => tokens.refreshToken).thenReturn('old');
    stubPost(
      () => okResponse({
        'access_token': 'new-access',
        'refresh_token': 'new-refresh',
        'expires_in': 3600,
      }),
    );

    expect(await refresher.refresh(), RefreshOutcome.refreshed);
    verify(
      () => tokens.updateTokens(
        accessToken: 'new-access',
        refreshToken: 'new-refresh',
      ),
    ).called(1);
    verifyNever(() => tokens.clearTokens());
  });

  test('keeps session (networkError) on connection error', () async {
    when(() => tokens.refreshToken).thenReturn('old');
    stubPost(() => dioError(type: DioExceptionType.connectionError));

    expect(await refresher.refresh(), RefreshOutcome.networkError);
    verifyNever(() => tokens.clearTokens());
  });

  test('keeps session (networkError) on a 5xx server error', () async {
    when(() => tokens.refreshToken).thenReturn('old');
    stubPost(() => dioError(status: 503));

    expect(await refresher.refresh(), RefreshOutcome.networkError);
    verifyNever(() => tokens.clearTokens());
  });

  test('clears tokens (invalidSession) on 401', () async {
    when(() => tokens.refreshToken).thenReturn('old');
    stubPost(() => dioError(status: 401));

    expect(await refresher.refresh(), RefreshOutcome.invalidSession);
    verify(() => tokens.clearTokens()).called(1);
  });

  test('clears tokens (invalidSession) on a null body', () async {
    when(() => tokens.refreshToken).thenReturn('old');
    stubPost(() => okResponse(null));

    expect(await refresher.refresh(), RefreshOutcome.invalidSession);
    verify(() => tokens.clearTokens()).called(1);
  });

  test('clears tokens (invalidSession) on a malformed body, without throwing',
      () async {
    when(() => tokens.refreshToken).thenReturn('old');
    stubPost(() => okResponse({'unexpected': 'shape'}));

    expect(await refresher.refresh(), RefreshOutcome.invalidSession);
    verify(() => tokens.clearTokens()).called(1);
    verifyNever(
      () => tokens.updateTokens(
        accessToken: any(named: 'accessToken'),
        refreshToken: any(named: 'refreshToken'),
      ),
    );
  });

  test('single-flight: concurrent callers share one POST', () async {
    when(() => tokens.refreshToken).thenReturn('old');
    final completer = Completer<Response<Map<String, dynamic>>>();
    when(
      () => dio.post<Map<String, dynamic>>(any(), data: any(named: 'data')),
    ).thenAnswer((_) => completer.future);

    final f1 = refresher.refresh();
    final f2 = refresher.refresh();
    expect(f1, same(f2));

    completer.complete(
      okResponse({'access_token': 'a', 'refresh_token': 'r', 'expires_in': 1}),
    );
    await f1;

    verify(
      () => dio.post<Map<String, dynamic>>(any(), data: any(named: 'data')),
    ).called(1);
  });
}
```

- [ ] **Step 3: Run it to verify it fails**

Run:
```bash
fvm flutter test packages/network/test/token_refresher_test.dart
```
Expected: FAIL — `TokenRefresher` / `RefreshOutcome` not exported by `network`.

- [ ] **Step 4: Implement `TokenRefresher` in network**

Create `packages/network/lib/src/token_refresher.dart`:

```dart
import 'dart:async';

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:storage/storage.dart';

/// Outcome of a token-refresh attempt.
///
/// Distinguishes a *transient* failure (offline / timeout / server hiccup —
/// keep the session, retry later) from a genuine auth rejection (the refresh
/// token is dead and the tokens must be cleared).
enum RefreshOutcome { refreshed, networkError, invalidSession }

/// Single-flight refresh: concurrent callers share one in-flight POST so the
/// server doesn't see a stampede during a 401 storm. Uses the unauthenticated
/// (`plain`) Dio so the refresh call itself can't recurse through the auth
/// interceptor.
@lazySingleton
class TokenRefresher {
  TokenRefresher(this._tokens, @Named('plain') this._dio);

  final AuthTokenStore _tokens;
  final Dio _dio;
  Future<RefreshOutcome>? _inflight;

  Future<RefreshOutcome> refresh() =>
      _inflight ??= _run()..whenComplete(() => _inflight = null);

  Future<RefreshOutcome> _run() async {
    final token = _tokens.refreshToken;
    if (token == null) return RefreshOutcome.invalidSession;
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/api/auth/refresh',
        data: {'refresh_token': token},
      );
      final body = response.data;
      final String access;
      final String refresh;
      try {
        if (body == null) throw const FormatException('empty refresh body');
        final a = body['access_token'];
        final r = body['refresh_token'];
        if (a is! String || r is! String) {
          throw const FormatException('missing tokens');
        }
        access = a;
        refresh = r;
      } on Object {
        await _tokens.clearTokens();
        return RefreshOutcome.invalidSession;
      }
      await _tokens.updateTokens(accessToken: access, refreshToken: refresh);
      return RefreshOutcome.refreshed;
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (status == 401 || status == 403) {
        await _tokens.clearTokens();
        return RefreshOutcome.invalidSession;
      }
      return RefreshOutcome.networkError;
    }
  }
}
```

- [ ] **Step 5: Export `token_refresher.dart` from the network barrel**

In `packages/network/lib/network.dart`, add:

```dart
export 'src/token_refresher.dart';
```

- [ ] **Step 6: Run the refresher test**

Run:
```bash
fvm flutter test packages/network/test/token_refresher_test.dart
```
Expected: PASS.

- [ ] **Step 7: Write the failing interceptor test (new coverage)**

Create `packages/network/test/auth_interceptor_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:network/network.dart';
import 'package:storage/storage.dart';
import 'package:test_utils/test_utils.dart';

class _MockTokenStore extends Mock implements AuthTokenStore {}

class _MockRefresher extends Mock implements TokenRefresher {}

class _MockDio extends Mock implements Dio {}

class _RequestHandler extends RequestInterceptorHandler {}

class _ErrorHandler extends ErrorInterceptorHandler {}

void main() {
  late _MockTokenStore tokens;
  late _MockRefresher refresher;
  late _MockDio dio;
  late AuthInterceptor interceptor;

  setUp(() {
    tokens = _MockTokenStore();
    refresher = _MockRefresher();
    dio = _MockDio();
    interceptor = AuthInterceptor(tokens, refresher, dio);
  });

  test('onRequest attaches the bearer token when present', () {
    when(() => tokens.accessToken).thenReturn('abc');
    final options = RequestOptions(path: '/x');

    interceptor.onRequest(options, _RequestHandler());

    expect(options.headers['Authorization'], 'Bearer abc');
  });

  test('onRequest sends no header when there is no token', () {
    when(() => tokens.accessToken).thenReturn(null);
    final options = RequestOptions(path: '/x');

    interceptor.onRequest(options, _RequestHandler());

    expect(options.headers.containsKey('Authorization'), isFalse);
  });

  test('onError on 401 refreshes and retries the request once', () async {
    when(() => tokens.accessToken).thenReturn('new');
    when(() => refresher.refresh())
        .thenAnswer((_) async => RefreshOutcome.refreshed);
    when(() => dio.fetch<dynamic>(any())).thenAnswer(
      (_) async => Response<dynamic>(
        requestOptions: RequestOptions(path: '/x'),
        statusCode: 200,
      ),
    );

    final err = DioException(
      requestOptions: RequestOptions(path: '/x'),
      response: Response<dynamic>(
        requestOptions: RequestOptions(path: '/x'),
        statusCode: 401,
      ),
    );

    await interceptor.onError(err, _ErrorHandler());

    final retried = verify(() => dio.fetch<dynamic>(captureAny()))
        .captured
        .single as RequestOptions;
    expect(retried.extra['__auth_retried__'], isTrue);
    expect(retried.headers['Authorization'], 'Bearer new');
  });

  test('onError does not retry when already retried (loop guard)', () async {
    final err = DioException(
      requestOptions: RequestOptions(path: '/x', extra: {'__auth_retried__': true}),
      response: Response<dynamic>(
        requestOptions: RequestOptions(path: '/x'),
        statusCode: 401,
      ),
    );

    await interceptor.onError(err, _ErrorHandler());

    verifyNever(() => refresher.refresh());
  });

  test('onError does not retry when refresh fails', () async {
    when(() => refresher.refresh())
        .thenAnswer((_) async => RefreshOutcome.invalidSession);

    final err = DioException(
      requestOptions: RequestOptions(path: '/x'),
      response: Response<dynamic>(
        requestOptions: RequestOptions(path: '/x'),
        statusCode: 401,
      ),
    );

    await interceptor.onError(err, _ErrorHandler());

    verifyNever(() => dio.fetch<dynamic>(any()));
  });
}
```

- [ ] **Step 8: Run it to verify it fails**

Run:
```bash
fvm flutter test packages/network/test/auth_interceptor_test.dart
```
Expected: FAIL — `AuthInterceptor` not exported.

- [ ] **Step 9: Implement `AuthInterceptor` in network**

Create `packages/network/lib/src/auth_interceptor.dart`:

```dart
import 'package:dio/dio.dart';
import 'package:storage/storage.dart';

import 'token_refresher.dart';

/// Attaches the persisted access token to outgoing requests and, on 401,
/// transparently refreshes the token once and retries the original request.
///
/// Requests already carrying `__auth_retried__` in their extras skip the retry
/// path so a doomed refresh can never cause an infinite loop.
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._tokens, this._refresher, this._dio);

  final AuthTokenStore _tokens;
  final TokenRefresher _refresher;
  final Dio _dio;

  static const _retriedKey = '__auth_retried__';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = _tokens.accessToken;
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final response = err.response;
    final request = err.requestOptions;
    final alreadyRetried = request.extra[_retriedKey] == true;

    if (response?.statusCode != 401 || alreadyRetried) {
      handler.next(err);
      return;
    }

    final outcome = await _refresher.refresh();
    if (outcome != RefreshOutcome.refreshed) {
      handler.next(err);
      return;
    }

    try {
      final retried = await _dio.fetch<dynamic>(
        request
          ..extra[_retriedKey] = true
          ..headers['Authorization'] = 'Bearer ${_tokens.accessToken}',
      );
      handler.resolve(retried);
    } on DioException catch (e) {
      handler.next(e);
    }
  }
}
```

- [ ] **Step 10: Export `auth_interceptor.dart` from the network barrel**

In `packages/network/lib/network.dart`, add:

```dart
export 'src/auth_interceptor.dart';
```

- [ ] **Step 11: Regenerate network DI and run the network suite**

Run:
```bash
(cd packages/network && fvm dart run build_runner build --delete-conflicting-outputs)
(cd packages/network && fvm flutter test)
```
Expected: PASS (new refresher + interceptor tests plus existing interceptor tests). Note: `network`'s generated module now registers `TokenRefresher`, but nothing constructs the authenticated `Dio` yet, so there is no duplicate registration with `feature_auth`.

- [ ] **Step 12: Commit**

```bash
git add packages/network
git commit -m "feat(network): add AuthInterceptor + TokenRefresher over AuthTokenStore"
```

---

## Task 7: Switch the authenticated `Dio` from `feature_auth` to `network`

The atomic swap: `network` starts providing the unnamed authenticated `Dio`;
`feature_auth` stops. After this, every feature resolves `network`'s `Dio`.

**Files:**
- Modify: `packages/network/lib/src/network_module.dart` (add authenticated `Dio` provider)
- Modify: `packages/features/auth/lib/src/data/network/auth_network_module.dart` (drop `provideDio`)
- Modify: `packages/features/auth/lib/src/data/repositories/auth_repository_impl.dart` (import refresher from network)
- Delete: `packages/features/auth/lib/src/data/network/auth_interceptor.dart`
- Delete: `packages/features/auth/lib/src/data/network/token_refresher.dart`
- Delete: `packages/features/auth/test/data/network/token_refresher_test.dart`
- Delete: `packages/features/auth/lib/src/data/models/refresh_token_response.dart` (+ `.freezed.dart`) — **only if unused elsewhere** (verify in Step 1)

- [ ] **Step 1: Confirm `RefreshTokenResponse` is only used by the old refresher**

Run:
```bash
grep -rn "RefreshTokenResponse\|refresh_token_response" packages/features/auth/lib --include="*.dart" | grep -v ".freezed.dart"
```
Expected: matches only in `token_refresher.dart` (being deleted) and `refresh_token_response.dart` itself. If anything else references it, keep the file; otherwise it will be deleted in Step 5.

- [ ] **Step 2: Add the authenticated `Dio` provider to `network`**

In `packages/network/lib/src/network_module.dart`, add the imports and a provider inside `NetworkModule`:

```dart
import 'package:firebase_performance/firebase_performance.dart';
import 'package:storage/storage.dart';

import 'auth_interceptor.dart';
import 'performance_interceptor.dart';
import 'retry_interceptor.dart';
import 'token_refresher.dart';
```

```dart
  /// Authenticated Dio used by the app: attaches the Bearer token and, on 401,
  /// transparently refreshes once and retries the request.
  ///
  /// Interceptor order matters. [PerformanceInterceptor] runs first (outside
  /// dev) so it times the full request including retries; [AuthInterceptor]
  /// owns the 401 → refresh path; [RetryInterceptor] handles transient failures
  /// with backoff. In dev a [devLogInterceptor] is appended last so it observes
  /// the final, token-bearing requests.
  @lazySingleton
  Dio provideDio(
    AuthTokenStore tokens,
    TokenRefresher refresher,
    EnvConfig env,
    FirebasePerformance performance,
  ) {
    final dio = Dio(apiBaseOptions(env.apiBaseUrl, timeout: env.apiTimeout));
    if (!env.isDev) {
      dio.interceptors.add(PerformanceInterceptor(performance));
    }
    dio.interceptors.add(AuthInterceptor(tokens, refresher, dio));
    dio.interceptors.add(RetryInterceptor(dio));
    if (env.isDev) {
      dio.interceptors.add(devLogInterceptor());
    }
    return dio;
  }
```

(Verify the exact import path/type for `FirebasePerformance` and `EnvConfig` match how `network` already references them — `config`'s `EnvConfig` is already imported in this file; `FirebasePerformance` comes from `firebase_performance`, already a `network` dependency used by `PerformanceInterceptor`.)

- [ ] **Step 3: Remove `provideDio` from `feature_auth`**

In `packages/features/auth/lib/src/data/network/auth_network_module.dart`, delete the `provideDio(...)` method and its now-unused imports (`AuthLocalDataSource`, `auth_interceptor.dart`, `token_refresher.dart`, `EnvConfig`, `FirebasePerformance`). Keep only:

```dart
import 'package:injectable/injectable.dart';
import 'package:network/network.dart';

import '../datasources/auth_remote_data_source.dart';

@module
abstract class AuthNetworkModule {
  @lazySingleton
  AuthRemoteDataSource provideAuthRemoteDataSource(Dio dio) =>
      AuthRemoteDataSource(dio);
}
```

- [ ] **Step 4: Point `AuthRepositoryImpl` at network's refresher**

In `packages/features/auth/lib/src/data/repositories/auth_repository_impl.dart`, remove the import `import '../network/token_refresher.dart';` (the `TokenRefresher` / `RefreshOutcome` now come from `package:network/network.dart`, already imported on line 3). The constructor and `restoreSession` switch on `RefreshOutcome` unchanged.

Also tidy the orphaned user in the `invalidSession` branch of `restoreSession` (hygiene — the refresher already cleared tokens):

```dart
case RefreshOutcome.invalidSession:
  // Tokens were already cleared by the refresher; drop the now-orphaned
  // persisted user too so storage doesn't keep a userless session blob.
  await _local.clearSession();
  return const Err(NoSessionFailure('Session expired.'));
```

- [ ] **Step 5: Delete the moved/dead files**

Run:
```bash
git rm packages/features/auth/lib/src/data/network/auth_interceptor.dart \
       packages/features/auth/lib/src/data/network/token_refresher.dart \
       packages/features/auth/test/data/network/token_refresher_test.dart
# Only if Step 1 confirmed it is unused:
git rm packages/features/auth/lib/src/data/models/refresh_token_response.dart \
       packages/features/auth/lib/src/data/models/refresh_token_response.freezed.dart
```

- [ ] **Step 6: Regenerate DI for network, auth, and the root app**

Run:
```bash
(cd packages/network && fvm dart run build_runner build --delete-conflicting-outputs)
(cd packages/features/auth && fvm dart run build_runner build --delete-conflicting-outputs)
fvm dart run build_runner build --delete-conflicting-outputs
```
Expected: the unnamed `Dio` is now registered by `network`'s generated module; `feature_auth`'s generated module no longer registers it (no duplicate-registration error).

- [ ] **Step 7: Run the network + auth suites**

Run:
```bash
(cd packages/network && fvm flutter test)
(cd packages/features/auth && fvm flutter test)
```
Expected: PASS.

- [ ] **Step 8: Commit**

```bash
git add -A packages/network packages/features/auth
git commit -m "refactor: move authenticated Dio from feature_auth to network"
```

---

## Task 8: Simplify DI ordering + add the Dio guardrail

**Files:**
- Modify: `lib/app/di/injection.dart` (reorder + comment)
- Modify: `test/architecture/di_module_ordering_test.dart` (drop the Dio constraint)
- Test: `test/architecture/authenticated_dio_test.dart` (new smoke guardrail)

- [ ] **Step 1: Reorder `Storage` before `Network` and update the doc comment**

In `lib/app/di/injection.dart`, update the `@InjectableInit` doc comment to:

```dart
/// Async because core database modules use `@preResolve` to open native
/// resources before any consumer is constructed. Must be awaited from `main`.
///
/// Ordering: `storage` provides the `AuthTokenStore` + `FlutterSecureStorage`
/// that `network` builds the authenticated `Dio` on, so it is listed before
/// `network`. `shared_contracts` registers `ActivityNotifier`, consumed by a
/// feature BLoC, so it precedes the feature modules. The authenticated `Dio` is
/// now provided by `network` (not by `feature_auth`), so no feature module
/// needs to be ordered relative to `feature_auth` for it.
```

And move `ExternalModule(StoragePackageModule)` to sit immediately before `ExternalModule(NetworkPackageModule)`:

```dart
    ExternalModule(AnalyticsPackageModule),
    ExternalModule(ConfigPackageModule),
    ExternalModule(StoragePackageModule),
    ExternalModule(NetworkPackageModule),
    ExternalModule(AppPlatformPackageModule),
    ExternalModule(ThemePackageModule),
    ExternalModule(SyncConnectivityPlusPackageModule),
    ExternalModule(SharedContractsPackageModule),
    ExternalModule(FeatureAuthPackageModule),
    // ...feature modules unchanged
```

- [ ] **Step 2: Drop the now-false Dio ordering constraint from the guardrail**

In `test/architecture/di_module_ordering_test.dart`, remove the entire
`'FeatureAuthPackageModule': { ... }` entry from `_mustPrecede` (lines 43–56),
and delete its `// auth provides the authenticated Dio ...` comment. Keep the
`SharedContractsPackageModule → FeatureNotificationsPackageModule` edge. Update
the file's top-of-file prose comment to remove the second bullet about
`FeatureAuthPackageModule` providing the authenticated `Dio`.

- [ ] **Step 3: Regenerate the root DI and write the smoke guardrail test**

Run:
```bash
fvm dart run build_runner build --delete-conflicting-outputs
```

Create `test/architecture/authenticated_dio_test.dart`:

```dart
// Guardrail: the authenticated Dio must be resolvable from the composed DI
// graph. After moving its provider from feature_auth to network, this proves
// every API feature can still resolve `Dio` from the shared GetIt.

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_starter_template/app/di/injection.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await getIt.reset();
  });

  test('configureDependencies registers a resolvable authenticated Dio',
      () async {
    await configureDependencies();
    expect(getIt.isRegistered<Dio>(), isTrue);
    expect(getIt<Dio>(), isA<Dio>());
  });
}
```

If `configureDependencies()` requires platform plugins that fail under the VM
(e.g. secure storage / shared preferences channels), narrow the assertion to
registration-only by initializing just the modules, or guard the resolve in a
`try/catch` that still asserts `isRegistered<Dio>()`. Verify which is needed
when the test first runs (Step 4) and adjust before committing.

- [ ] **Step 4: Run the architecture suite**

Run:
```bash
fvm flutter test test/architecture/
```
Expected: PASS — `package_layering_test` (now covering `network → storage`),
`di_module_ordering_test` (Dio constraint gone), `feature_boundaries_test`, and
the new `authenticated_dio_test`.

- [ ] **Step 5: Commit**

```bash
git add lib/app/di/injection.dart test/architecture/
git commit -m "refactor(di): simplify module ordering; guard authenticated Dio"
```

---

## Task 9: Full workspace verification

**Files:** none (verification only)

- [ ] **Step 1: Regenerate everything from a clean state**

Run:
```bash
fvm dart run build_runner build --delete-conflicting-outputs
```
Expected: completes with no errors.

- [ ] **Step 2: Format + analyze**

Run:
```bash
fvm dart format .
fvm flutter analyze
```
Expected: no formatting changes left unstaged, analyzer reports no issues.

- [ ] **Step 3: Run the full root + per-package test suites**

Run:
```bash
fvm flutter test --exclude-tags golden
(cd packages/storage && fvm flutter test)
(cd packages/network && fvm flutter test)
(cd packages/features/auth && fvm flutter test)
(cd packages/features/bookmarks && fvm flutter test)
(cd packages/features/collections && fvm flutter test)
```
Expected: all green.

- [ ] **Step 4: Manual smoke (optional but recommended) — sign-in path**

Start the backend (`cd simple_backend_server && go run .`) and run the app
(`fvm flutter run`); sign in, create a bookmark, kill/restart to confirm session
restore, then sign out. Confirms the relocated transport + token store work
end-to-end. (Or run `tool/run_e2e.sh` if an iOS Simulator is available.)

- [ ] **Step 5: Final commit (only if format/analyze produced changes)**

```bash
git add -A
git commit -m "chore: format + analyze after auth transport extraction"
```

---

## Self-review notes

- **Spec coverage:** storage `AuthTokenStore` (Task 4) ✓; network transport + authenticated `Dio` (Tasks 6–7) ✓; `feature_auth` narrowing + token delegation + `invalidSession` user cleanup (Tasks 5, 7) ✓; DI ordering simplification + guardrail (Task 8) ✓; Clock in data/domain (Tasks 1–2) ✓. **Addition beyond the spec:** Task 3 moves the `FlutterSecureStorage` provider into `storage` — required because the token-store impl must not depend on auth's registration (and it fixes a pre-existing `storage → auth` hidden edge via `KeychainResetOnReinstall`). Update the spec's "Affected files" to mention this if keeping the docs in sync.
- **Type consistency:** `AuthTokenStore` methods (`accessToken`, `refreshToken`, `load`, `updateTokens`, `clearTokens`) are used identically in Tasks 4–7. `RefreshOutcome` values (`refreshed`, `networkError`, `invalidSession`) match across the refresher (Task 6) and `restoreSession` (Task 7). The interceptor retry key `__auth_retried__` matches between implementation and test.
- **Behavior preservation:** interceptor order, single-flight refresh, and transient-vs-invalid semantics are copied verbatim; only the token source (`AuthLocalDataSource` → `AuthTokenStore`) and parse (DTO → inline) change, both covered by migrated/added tests.
