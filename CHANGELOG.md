# Changelog

All notable changes to this template are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
- **Tooling** — Dart & CodeGraph MCP servers and vendored agent skills.

[1.0.0]: https://github.com/kido-luci/flutter-starter-template/releases/tag/v1.0.0
