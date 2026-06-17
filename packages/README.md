# Workspace packages

Reusable infrastructure for the Flutter starter template, split out of
`lib/core/` into [Dart pub workspace](https://dart.dev/tools/pub/workspaces)
members. The root app depends on these through their entry points (e.g.
`package:network/network.dart`) rather than on the third-party
packages directly, so implementation details and versions stay owned in one
place.

| Package | Responsibility |
|---|---|
| `app_ui` | Design system — theming, generic widgets, layout, animation |
| `architecture` | Pure-Dart architecture primitives (`Failure`, `Result`, `UseCase`) |
| `network` | `Dio`/`Retrofit` client + retry/performance interceptors |
| `analytics` | Firebase-backed analytics service + route observer |
| `config` | Environment config + Firebase Remote Config |
| `storage` | `SharedPreferences` provisioning + iOS Keychain reinstall reset |
| `sync` | Offline-first sync engine — scheduler + revision-based delta CRUD with conflict detection (pure Dart) |
| `app_platform` | Device integrations — media, notifications, permissions, share |
| `theme` | `ThemeBloc` + persisted theme state |
| `shared_contracts` | Cross-feature *business* vocabulary (`AuthUser`, reader interfaces, the app-wide `Session` lifecycle) used by 2+ features |
| `shared_ui` | Cross-feature *presentation* widgets needing Flutter — the `SessionScope` accessor + shared visuals |
| `test_utils` | Shared `mocktail` export, cross-package mocks/fakes, shared fixtures, test images |

Dependency direction is `app → features → shared_contracts / shared_ui →
app_ui / infra → architecture`. A package must not depend on the root app, and
a feature must not depend on another feature outside the documented capability
allowlist (enforced by `test/architecture/`).

## Dependency injection — the micro-package pattern

Each package that registers `@injectable`/`@module` types carries its own DI
wiring so the app doesn't have to know its internals:

- `lib/src/di.dart` holds an empty top-level function annotated with
  `@InjectableInit.microPackage()` — the codegen anchor.
- Running `build_runner` **inside the package** generates `lib/src/di.module.dart`
  containing a `class <PackageName>PackageModule extends MicroPackageModule`
  (e.g. `analytics` → `CoreAnalyticsPackageModule`).
- The barrel exports that module class.

The app composes them in `lib/app/di/injection.dart` via
`@InjectableInit(externalPackageModulesBefore: [ExternalModule(...), ...])`.
**Order matters**: a package whose types depend on another's must be listed
after it (e.g. `network` after `config` because `NetworkModule` reads
`EnvConfig`). Build-time "depends on unregistered type" warnings for
cross-package dependencies are expected and resolve at runtime.

After changing injectable types in a package, rerun `build_runner` in that
package, then at the repo root to regenerate `injection.config.dart`.

## Conventions

- **All package-owned tests live beside their package** under
  `packages/<name>/test` — infra packages and feature packages alike. Each
  feature carries a `test/support.dart` with its own mocks/fixtures, re-exporting
  `package:test_utils/test_utils.dart` for the shared doubles
  (`FakeSession`, the `shared_contracts` reader mocks) and fixtures
  (`testUser`, `testFailure`). Only genuinely app-level suites stay in the root
  `test/` — the full-app `widget_test.dart` and the `architecture/` layering
  and feature-boundary tests.
- A type graduates from a feature into a workspace package / `shared` location only on
  the **rule of three** — when ≥2 consumers actually depend on it today.
