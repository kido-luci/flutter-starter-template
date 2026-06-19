# app_platform

Device and platform integrations for the Flutter starter template, grouped
behind app-facing services. Exported through
`package:app_platform/app_platform.dart`.

The barrel re-exports the underlying plugins (`camera`, `image_picker`,
`video_player`, `permission_handler`, `share_plus`, `flutter_local_notifications`,
`firebase_messaging`, `firebase_crashlytics`), so the app consumes their types
through this single package.

## Public API

Organized by capability under `lib/src/`:

- **`crash/`** — `CrashReporter` port with a `FirebaseCrashReporter` adapter and
  a `NoOpCrashReporter`. `CrashModule` binds it at the `// fst:crash-impl`
  marker; `fst create --no-firebase` swaps it to the no-op. `main.dart` installs
  the global error handlers through this port.
- **`media/`** — `CameraService`, `ImagePickerService`, `VideoPlayerService`.
- **`notifications/`** — `NotificationsService` (on-device scheduling +
  tap-to-navigate) and `FirebaseMessagingService` (FCM).
- **`permissions/`** — `PermissionService`, a thin wrapper over
  `permission_handler`.
- **`share/`** — `ShareService`, a wrapper over `share_plus`.
- `CorePlatformPackageModule` — the injectable micro-package module the app
  registers via `externalPackageModulesBefore`.

## Notes

`FirebaseMessagingService` depends on `AnalyticsService`, so `analytics`
must be registered **before** `app_platform` in the app's DI composition. The
Firebase *bootstrap* (`Firebase.initializeApp`, the `@pragma('vm:entry-point')`
background handler) stays in the app under `lib/core/platform/firebase/` because
it is coupled to the app-generated `firebase_options.dart`.
