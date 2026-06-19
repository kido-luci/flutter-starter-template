# analytics

Firebase-backed analytics for the Flutter starter template.

Wraps Firebase Analytics behind an app-facing service so feature code logs
events without depending on the SDK directly. Exported through
`package:analytics/analytics.dart`.

## Public API

- `AnalyticsService` — logs events, screen views, and user properties.
- `AnalyticsEvents` — the catalog of named events the app emits.
- `analytics_extensions.dart` — convenience helpers for logging.
- `AnalyticsRouteObserver` — a `NavigatorObserver` that auto-logs screen views;
  wire it into `MaterialApp.router`'s `observers`.
- `CoreAnalyticsPackageModule` — the injectable micro-package module the app
  registers via `externalPackageModulesBefore`.

## Notes

`AnalyticsService` is consumed by other packages (e.g. `theme`'s
`ThemeBloc` and `app_platform`'s messaging service), so this module must be
registered **before** them in the app's DI composition. See
[`packages/README.md`](../README.md) for the micro-package DI pattern.

## Swapping the backend

`AnalyticsService` is a port. The DI module binds it at the
`// fst:analytics-impl` marker in `lib/src/analytics_module.dart` —
`FirebaseAnalyticsService` by default, `NoOpAnalyticsService` when analytics is
off. Change that one expression (or point it at your own adapter) to switch
backends; `fst create --no-firebase` swaps it to the no-op automatically. The
firebase_analytics dependency stays but is inert under the no-op binding.
