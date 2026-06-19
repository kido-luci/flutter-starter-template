# Changelog

All notable changes to this template are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.5.0] - 2026-06-19

Sharpens the scaffolding path so a project generated with `fst create` comes out
as a true clean slate, and trims CI wall-clock. No behavior change to the running
app.

### Added

- **Clean-slate generation** — `fst create` now removes the vendored submodules
  (the demo backend and the CLI's own source) and the template's git history,
  then runs `git init` so a new project starts from its own first commit, and
  writes a minimal, project-specific `README.md` (via the `tool/cli` submodule).
- **Firebase reconfigure warning** — after scaffolding, `fst create` warns that
  `lib/firebase_options.dart` still points at the template's Firebase project and
  prints the `flutterfire configure` steps to fix it.
- **Widget test coverage** for the splash redirect, home, and profile screens.

### Changed

- **CI skips heavy jobs for non-build changes** — the job-level path filter now
  uses `predicate-quantifier: every`, so docs-, tooling-, and submodule-only PRs
  actually skip the Android/iOS/golden/test jobs instead of always running them.
- **Faster native builds** — the Android job caches `~/.gradle` and the iOS job
  caches `ios/Pods` + the CocoaPods download cache.
- **Gradle wrapper** bumped 8.11.1 → 9.6.0, plus GitHub Actions dependency
  bumps.
- The identifier rewriter no longer walks `.git/`.
- README documents the `fst add-feature` generator.

### Fixed

- **iOS flavor display names** aligned with Android so `fst create` renames them
  cleanly — the prod iOS app no longer keeps a stray "Template" in its name.
- **Auth** — malformed sign-in/register responses now map to a failure, and a
  malformed token-refresh body no longer throws.

## [1.4.0] - 2026-06-18

Adds the `fst add-feature` generator and the seams it builds on, making a new
feature a one-command operation. No behavior change to the running app.

### Added

- **`fst add-feature` generator** — a new CLI command (in
  `flutter-starter-template-cli`, adopted here via the `tool/cli` submodule and
  the `# fst:` / `// fst:` wiring markers) that scaffolds a presentation-only
  feature package and wires it into the workspace, the dependency list, the
  injectable DI graph, and `enabledFeatures` in one step.
- **Pluggable feature routing** — `FeatureModule` gains a `routes` getter, so a
  feature contributes its own non-shell routes (plain `GoRoute` lists built from
  its path constants) instead of the app router declaring them.
- **DI module-ordering guard** — a pure file-scan architecture test that locks
  the load-bearing order of `externalPackageModulesBefore` (`shared_contracts`
  before `notifications`, `auth` before the other features), so a reorder that
  would only fail at runtime fails fast in CI.

### Changed

- **Non-shell routes relocated to their features** — the bookmark, collection,
  and auth (login/register) route classes moved out of `lib/app/router.dart`
  into their owning packages. The app shell keeps only the typed bottom-nav
  `StatefulShellRoute` (tabs plus the nested change-password route) and the boot
  splash route, so adding a feature's screens no longer edits the router.
- **Feature barrels narrowed to the consumed surface** — `bookmarks`,
  `collections`, and `notifications` stop exporting their domain repositories
  and use cases (resolved only through DI). Each package's public API is now the
  entity, sync controller, screens, and routes the app actually uses; in-package
  tests reach the now-internal types through `src/` imports, matching the
  existing `collections` convention.

## [1.3.0] - 2026-06-18

Structure cleanup that sharpens the package boundaries and co-locates tests with
the code they exercise. No behavior change.

### Changed

- **`Session` contract relocated** — moved from `shared_ui` to
  `shared_contracts`, alongside the other cross-feature business contracts.
  `SessionScope` (the `InheritedWidget`) stays in `shared_ui` and reads the
  contract across the boundary. `shared_contracts` gains a Flutter dependency
  for `Session`'s `Listenable`.
- **Feature tests moved beside their packages** — each feature's tests now live
  under `packages/features/<name>/test/` with a self-contained
  `test/support.dart`. Cross-feature test doubles (`FakeSession`, the
  `shared_contracts` reader mocks) and shared fixtures (`testUser`,
  `testFailure`) are promoted into the `test_utils` package. The root `test/`
  keeps only the app-level `widget_test` and the `architecture/` layering and
  feature-boundary suites.
- **Docs reconciled** — `CLAUDE.md`, `packages/README.md`, `test/README.md`, and
  `lib/core/README.md` updated for the new `Session` location, the
  package-owned test convention, and the corrected DI composition-root path
  (`lib/app/di/injection.dart`).

### Fixed

- Three feature tests imported the root app package solely for `getIt`; they now
  resolve it from each feature's own locator, removing a cross-layer coupling.

## [1.2.0] - 2026-06-17

Completes the move to a fully package-based architecture. Every feature now
lives in its own workspace package; the root app (`lib/`) holds no feature code.

### Changed

- **Feature packages** — `home`, `profile`, and `splash` extracted from
  `lib/features/` into `packages/features/`, joining `auth`, `notifications`,
  `bookmarks`, and `collections`. `lib/features/` is removed and the app is now
  a pure composition root (routing, DI, Firebase bootstrap).
- **Splash decoupling** — the splash screen no longer reaches into app routing.
  It restores the session and hands control back through an `onRestored`
  callback the app wires, and resolves its logo against its own package asset
  bundle so the package is self-contained.
- **App shell** — the three per-feature sync wrappers collapsed into one
  closure-based adapter, and the `bookmarks → collections` capability imports
  are annotated as the documented single-consumer exception.

### Added

- **Architecture guardrails for feature packages** — `package_layering_test`
  now ranks and direction-checks the nested `packages/features/*` packages, and
  `feature_boundaries_test` enforces the cross-feature capability allowlist
  (`bookmarks → collections`, `profile → auth`) at the package level.

### Removed

- Unused app-level `freezed` dev-dependency — the app declares no `@freezed`
  types (feature packages keep their own generator).

## [1.1.0] - 2026-06-17

Began the move to a package-based architecture and hardened CI.

### Added

- **Feature packages** — `auth`, `notifications`, `bookmarks`, and `collections`
  extracted into `packages/features/`, with prerequisite packages
  `shared_contracts` (cross-feature domain projections and reader interfaces),
  `shared_ui` (the app-wide `Session`/`SessionScope` and shared widgets),
  `database` (centralized ObjectBox entities and bindings), and `localization`
  (ARB sources + gen-l10n `AppLocalizations`).
- **CI build smoke-tests** — Android and iOS debug builds, an l10n guard,
  lockfile enforcement, golden tests, and Codecov coverage reporting.
- **Scaffold CLI** — a `flutter-starter-template-cli` tool for generating new
  projects from the template.

### Changed

- Removed the `lib/shared/` shim layer in favor of the `shared_contracts` /
  `shared_ui` packages, and pruned app-level dependencies now owned by packages.
- Aligned per-package DI module naming to `<Name>PackageModule`.

### Removed

- `lib/shared/` (replaced by the `shared_contracts` and `shared_ui` packages).

## [1.0.0] - 2026-06-08

First stable release of the Flutter starter template.

### Added

- **Project foundation** — Flutter SDK pinned to 3.44.0 via FVM, lints via
  `very_good_analysis`, and a feature-first `core` / `ui` / `shared` / `features`
  layout (see `CLAUDE.md`).
- **State management & routing** — `flutter_bloc` (+ `bloc_concurrency`) for app
  state and `go_router` for declarative navigation.
- **Dependency injection** — `injectable`/`get_it` wiring, including the
  per-package micro-DI pattern.
- **Workspace packages** — extracted into `packages/`: `analytics`,
  `app_platform`, `app_ui`, `architecture`, `config`, `network`, `storage`,
  `sync`, `theme`, plus `test_utils`.
- **Features** — `splash`, `auth`, `home`, `profile`, `bookmarks`,
  `collections`, and `notifications`, with a shared `Session` contract for
  app-wide auth state.
- **Theming & design system** — centralized light/dark `ThemeData` with a
  `ThemeBloc` toggle and the `app_ui` design-system widgets.
- **Local persistence** — ObjectBox storage with tracked schema bindings.
- **Flavors** — `dev` / `staging` / `prod` build flavors driven by
  `--dart-define-from-file env/<flavor>.json`.
- **Firebase** — integration with Crashlytics and analytics (CocoaPods on iOS;
  SPM disabled, see `CLAUDE.md`).
- **Internationalization** — `flutter_localizations` + `intl` with ARB-based
  localizations.
- **CI/CD** — GitHub Actions for analyze/test with coverage gating (`ci.yml`),
  CodeQL (`codeql.yml`), and a manual-dispatch Fastlane release pipeline
  (`release.yml`) for TestFlight and Google Play.
- **Bootstrap CLI** — `tool/setup.sh`, a one-command idempotent setup
  (submodules, FVM SDK, SPM disable on macOS, `pub get`, code generation,
  backend deps, and the pre-push hook).
- **Tooling** — Dart & CodeGraph MCP servers and vendored agent skills.

[1.5.0]: https://github.com/kido-luci/flutter-starter-template/releases/tag/v1.5.0
[1.4.0]: https://github.com/kido-luci/flutter-starter-template/releases/tag/v1.4.0
[1.3.0]: https://github.com/kido-luci/flutter-starter-template/releases/tag/v1.3.0
[1.2.0]: https://github.com/kido-luci/flutter-starter-template/releases/tag/v1.2.0
[1.1.0]: https://github.com/kido-luci/flutter-starter-template/releases/tag/v1.1.0
[1.0.0]: https://github.com/kido-luci/flutter-starter-template/releases/tag/v1.0.0
