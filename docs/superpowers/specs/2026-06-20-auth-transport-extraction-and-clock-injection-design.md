# Design: Extract authenticated transport to infra + testable Clock

Date: 2026-06-20
Status: Approved (design) — pending implementation plan

## Problem

Two findings from an objective architecture review:

1. **Hidden runtime coupling via the service locator.** The authenticated
   `Dio` (the one carrying the auth interceptor + 401 refresh) is registered by
   `feature_auth`'s `AuthNetworkModule.provideDio`. Every other API feature
   (`bookmarks`, `collections`, `notifications`) resolves the unnamed `Dio`
   from the shared `GetIt` without declaring a dependency on `feature_auth`.
   The edge is real at runtime but invisible to the pubspec graph,
   `package_layering_test`, and `feature_boundaries_test`. It is held together
   only by the manual ordering in `lib/app/di/injection.dart`
   (`FeatureAuthPackageModule` listed before the other feature modules).

   This is an *asymmetry*: `Uuid` — a comparable cross-cutting singleton — is
   provided by the **app shell** (`AppServicesModule`), the legitimate owner
   that depends on every feature. The authenticated `Dio` is instead owned by a
   sibling **feature**, which other features silently depend on.

2. **No testable clock.** `DateTime.now()` is called directly in data/domain
   code (repositories + a domain service) while `Uuid` is injected. Time-
   dependent logic — including the sync engine's lost-update guard, which
   compares `updatedAt` — cannot be made deterministic in tests. No `Clock`
   abstraction exists.

## Goals

- Make the authenticated `Dio` an **infrastructure-provided** singleton so the
  dependency becomes static (feature → `network`, already declared) and
  enforceable by the layering test. Remove the brittle "auth before other
  features" DI ordering constraint.
- Make data/domain time deterministic in tests via the `clock` package, with no
  new DI registrations or hidden edges.
- Preserve all existing auth/session behavior. The project is pre-release, so
  there are no production users, but the token-refresh and session-clearing
  semantics are subtle and must be kept correct, verified test-first.

## Non-goals

- No change to the refresh/retry logic, interceptor ordering, or the
  `RefreshOutcome` (transient vs invalid-session) semantics.
- No change to consuming features beyond what the move requires (they keep
  resolving `Dio`).
- Not touching the `Uuid` service-locator registration, package granularity,
  `fst:` markers, or DI micro-package ceremony — these are deliberate,
  documented trade-offs, out of scope.
- No UI / presentation changes. Presentation sites that call `DateTime.now()`
  for relative-time display, and `app_platform`'s messaging service, are out of
  the Clock scope (low test value).

## Key insight that makes the extraction safe

`AuthRepositoryImpl.restoreSession()` already guards on token presence:

```dart
if (user == null || refreshToken == null) return const Err(NoSessionFailure());
```

So on a genuine token rejection (`RefreshOutcome.invalidSession`), it is
sufficient for the refresher to clear **only the tokens**. The next cold start
sees `refreshToken == null` and routes to login regardless of any stale
persisted user. `network` therefore never needs to reach into `feature_auth` to
clear the user. (`restoreSession`'s `invalidSession` branch will additionally
call the auth store's full `clearSession()` to tidy the now-orphaned user blob —
optional hygiene, not correctness.)

## Target architecture

Authenticated transport becomes infrastructure rather than feature-owned.

### 1. `storage` (layer rank 1) — owns the token store (source of truth for tokens)

New port + secure-storage implementation, holding only the token half of the
current session store:

```dart
abstract interface class AuthTokenStore {
  String? get accessToken;
  String? get refreshToken;
  Future<void> load();
  Future<void> updateTokens({
    required String accessToken,
    required String refreshToken,
  });
  Future<void> clearTokens();
}
```

- Impl `SecureAuthTokenStore`: in-memory cache + `FlutterSecureStorage`,
  mirroring the token caching/persistence currently in
  `SecureStorageAuthDataSource` (keys `auth.access_token`, `auth.refresh_token`).
- Registered via `storage`'s injectable micro-package module.
- No new workspace dependency (uses `FlutterSecureStorage` already wrapped here).

### 2. `network` (layer rank 2) — receives the authenticated transport

- Move into `network`: `AuthInterceptor`, `TokenRefresher`, `RefreshOutcome`.
  They depend on `storage.AuthTokenStore` (not on `feature_auth`).
- `NetworkModule` gains a provider for the **authenticated `Dio`** (the unnamed
  `Dio`), assembled with the exact current interceptor order: performance
  (non-dev) → auth → retry → dev-log (dev). The existing `@Named('plain')` Dio
  provider stays.
- `TokenRefresher` parses the refresh response inline
  (`access_token` / `refresh_token`) so `network` does not depend on
  `feature_auth`'s DTOs.
- `network` adds a dependency on `storage`. Edge `network (2) → storage (1)` is
  downward and valid; the layering test now enforces it.

### 3. `feature_auth` (layer rank 4) — narrows to feature scope

- `SecureStorageAuthDataSource` keeps **user** persistence and **delegates
  token** operations to an injected `AuthTokenStore`. The `AuthLocalDataSource`
  interface is unchanged, so `AuthRepositoryImpl` is essentially untouched:
  - `accessToken` / `refreshToken` getters → delegate to the token store.
  - `setSession(...)` → persist user (own storage) + `tokenStore.updateTokens`.
  - `clearSession()` → clear user (own storage) + `tokenStore.clearTokens`.
  - `load()` → load user; the token store loads its own tokens.
- Delete the moved files: `auth_interceptor.dart`, `token_refresher.dart`, and
  the `provideDio` part of `auth_network_module.dart`
  (`provideAuthRemoteDataSource` stays — it now consumes `network`'s Dio).
- `AuthRepositoryImpl` uses `TokenRefresher` / `RefreshOutcome` from `network`
  (already a declared dependency). Add `clearSession()` in the `invalidSession`
  branch of `restoreSession` (hygiene).

### 4. DI / composition root

- The unnamed authenticated `Dio` is now provided by `network`, which every API
  feature already declares — the hidden edge is gone.
- Remove the "auth before other features (for Dio)" ordering constraint. Only
  the `shared_contracts` → features ordering (for `ActivityNotifier`) remains.
- Update `lib/app/di/injection.dart` ordering comment; move `Storage` before
  `Network` in `externalPackageModulesBefore` for clarity (all are
  `lazySingleton`, so resolution order is not load-bearing, but the list should
  read top-down).
- Update `test/architecture/di_module_ordering_test.dart` to drop the removed
  constraint.

### 5. Clock (data/domain only)

- Add the `clock` package to `feature_bookmarks` and `feature_collections`.
- Replace `DateTime.now()` with `clock.now()` in:
  - `packages/features/bookmarks/lib/src/data/repositories/bookmarks_repository_impl.dart`
  - `packages/features/collections/lib/src/data/repositories/collections_repository_impl.dart`
  - `packages/features/bookmarks/lib/src/domain/services/bookmark_stats_service.dart`
- Ambient idiom: no DI registration, no constructor threading, no new hidden
  edges. Tests wrap calls in `withClock(Clock.fixed(t), () => ...)`.

## Testing strategy (test-first for the sensitive paths)

- Move `token_refresher_test` from `feature_auth/test` to `network/test`; fake
  the `AuthTokenStore` instead of `AuthLocalDataSource`.
- Add `auth_interceptor_test` in `network/test` — the interceptor is currently
  untested; cover token attach, 401 → refresh → retry once, and the
  `__auth_retried__` loop guard.
- Update `auth_repository_impl_test` — the `AuthLocalDataSource` fake keeps the
  same interface, so changes are minimal.
- Add a small guardrail: after `configureDependencies()`, `getIt<Dio>()`
  resolves (smoke). `package_layering_test` now naturally covers
  `network → storage`.
- Clock: update affected repository/service tests to assert deterministic
  timestamps under `withClock`.

## Risks & mitigations

- **Auth regression on token/session paths** — pre-release (no prod users) and
  done test-first; behavior is preserved by keeping the `AuthLocalDataSource`
  interface and interceptor/refresher logic intact, only relocating them.
- **Orphaned persisted user after invalid-session token clear** — handled by the
  existing `refreshToken == null` guard in `restoreSession`, plus the optional
  full `clearSession()` in that branch.
- **DI resolution order** — all relevant providers are `lazySingleton`, so the
  reorder is cosmetic; the smoke + layering tests catch a real break.

## Affected files (summary)

- `packages/storage/` — new `auth_token_store.dart` (port + impl) + module wiring.
- `packages/network/` — new `auth_interceptor.dart`, `token_refresher.dart`;
  `network_module.dart` gains authenticated `Dio`; pubspec adds `storage`.
- `packages/features/auth/` — `SecureStorageAuthDataSource` delegates tokens;
  delete interceptor/refresher + `provideDio`; repo imports refresher from
  `network`.
- `lib/app/di/injection.dart` + `test/architecture/di_module_ordering_test.dart`
  — ordering comment/constraint update.
- `packages/features/bookmarks/`, `packages/features/collections/` — `clock`
  dep + `clock.now()`; tests under `withClock`.
- Test moves/additions as above.
