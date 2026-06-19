# Make Firebase optional — tracking ports + platform toggle

- **Date:** 2026-06-19
- **Status:** Approved (design)
- **Scope:** template (main repo: `lib/`, `packages/analytics`, `packages/app_platform`,
  `android/`, native config) **and** `tool/cli` (the `fst create` command)
- **Owner:** kido-luci
- **Related:** builds on the non-interactive `fst create` work
  (`2026-06-19-fst-create-non-interactive-design.md`)

## Problem

Firebase is wired into the template unconditionally and can't be turned off:

- `main.dart` initialises Firebase core, Crashlytics, Remote Config, and
  Messaging in a fixed sequence with no guard.
- Tracking is hard-coupled to Firebase: `FirebaseAnalyticsService` is the only
  `AnalyticsService` binding, and `CrashReportingService` is a concrete
  Crashlytics class with no interface.
- The Android build applies three Firebase Gradle plugins
  (`google-services`, `firebase-perf`, `crashlytics`); `google-services`
  *requires* `google-services.json` at build time, and `firebase-core`
  auto-initialises the bundled (template) project natively.
- Deps span five packages: `firebase_core` (root), `firebase_crashlytics` +
  `firebase_messaging` (`app_platform`), `firebase_analytics` (`analytics`),
  `firebase_performance` (`network`), `firebase_remote_config` (`config`).

A user who doesn't want Firebase — or wants only some of it — has no supported
path. Detailed Firebase setup is already handled by `flutterfire configure`; the
template just needs to let users *choose*.

## Goals

- Let `fst create` scaffold a project with Firebase on (today's behaviour) or
  cleanly off (no Firebase project required to build and run).
- Decouple the two **tracking** concerns (analytics, crash reporting) from
  Firebase via ports, so each can be Firebase-backed, no-op, or user-supplied —
  independently.
- Keep "detailed setup is the user's job via `flutterfire configure`": the
  template provides the seams and a ready Firebase adapter; it does not manage
  credentials.

## Non-goals

- No removal of the Firebase Dart dependencies. They stay in `pubspec` (inert
  when unused). Removing them would force no-op implementations to live in
  separate dependency-free packages — out of scope.
- No port/adapter treatment for the **platform** services (messaging, remote
  config, performance). Those stay Firebase-only, gated as a block by the
  platform toggle. Only the two tracking services get the port treatment.
- No CLI prompt for per-service tracking. Fine-grained "Firebase crash but no-op
  analytics" is achieved by the user swapping one composition-root line
  (documented), not by the CLI.

## Decisions

- **Default is ON.** `fst create` without a Firebase flag keeps Firebase fully
  wired (platform + Firebase tracking adapters) — today's batteries-included
  identity, backward-compatible.
- **"Yes" auto-wires Firebase tracking** (analytics + crash adapters), matching
  today. "No" leaves the no-op tracking bindings.
- **Tracking is no-op-capable but ships ON by default**, so the template's
  default composition root wires the Firebase tracking adapters; the CLI's `off`
  path swaps them to no-op.
- **Firebase tracking adapters require the platform on** (they need
  `Firebase.initializeApp`). Platform off ⇒ tracking is forced to no-op.

## Architecture

### Tracking ports

**Analytics** (`packages/analytics`):

- Keep the existing `AnalyticsService` interface, events, extensions, and
  `AnalyticsRouteObserver` (backend-agnostic).
- Add `NoOpAnalyticsService implements AnalyticsService` (every method returns a
  completed future).
- Provide two selectable DI modules in the package:
  - `AnalyticsPackageModule` — binds `NoOpAnalyticsService` as `AnalyticsService`.
  - `AnalyticsFirebaseModule` — binds `FirebaseAnalyticsService` and provides
    `FirebaseAnalytics.instance`.
- `firebase_analytics` stays a dependency of the package (inert under no-op).

**Crash** (`packages/app_platform`):

- Extract an interface `CrashReporter` (`install()` and `recordError(error,
  stack, {fatal})`) from the current concrete `CrashReportingService`. Export it
  from the `app_platform` barrel.
- Add `NoOpCrashReporter implements CrashReporter` (no-ops).
- Provide two selectable DI modules:
  - the default module binds `NoOpCrashReporter`,
  - a Firebase module binds the Crashlytics-backed implementation (today's
    `CrashReportingService` logic behind the interface).
- `firebase_crashlytics` stays a dependency of the package (inert under no-op).

### Platform gate

- Add a compile-time flag `const bool kFirebaseEnabled = true;` in a small,
  CLI-flippable file (`lib/app/firebase.dart`).
- `main.dart`: wrap the **platform** inits — `FirebaseService.init()`,
  `RemoteConfigService.init()`, `FirebaseMessagingService.init()` (and anything
  else requiring `Firebase.initializeApp`) — in `if (kFirebaseEnabled) { … }`.
- `NotificationsService` (local notifications, no Firebase) runs unconditionally.
- Crash reporting runs through `getIt<CrashReporter>().install()` **after** the
  platform block (so the Firebase crash adapter, when wired, sees an initialised
  Firebase app; the no-op does nothing regardless).
- `_reportBootstrapFailure` routes through `CrashReporter.recordError` when the
  locator is available, instead of calling `FirebaseCrashlytics` directly.

### Composition root

`lib/app/di/injection.dart` selects the tracking modules via sentinel-marked
slots, mirroring the existing `// fst:` marker convention:

```dart
// fst:analytics-module
ExternalModule(AnalyticsFirebaseModule), // default ON; off swaps to AnalyticsPackageModule
// fst:crash-module
ExternalModule(AppPlatformCrashFirebaseModule), // default ON; off swaps to the no-op module
```

Only one analytics module and one crash module are included at a time (two
`as: AnalyticsService` registrations would collide). The default template ships
the Firebase modules wired.

> **DI mechanism caveat.** The exact injectable realisation of "two modules,
> pick one" (two `@InjectableInit.microPackage()` anchors in one package vs.
> `@Environment` tags vs. explicit composition-root registration) must be
> validated against `build_runner` during implementation. The plan pins it; this
> spec fixes only the intent: the composition root chooses no-op vs. Firebase
> tracking, default Firebase, swappable by one line per service.

## Template default state

The template on `main` ships **Firebase ON**: `kFirebaseEnabled = true`, Firebase
tracking modules wired, native config and Gradle plugins present. With the flag
true the gated `main.dart` behaves exactly as today, so existing tests and
behaviour are unchanged.

## CLI behaviour (`fst create`)

One Firebase question, integrated into the existing flag/prompt resolution:

- Add `--firebase` / `--no-firebase` (defaults to **on**).
- Interactive and flag not passed → `Confirm('Use Firebase?', default: true)`.
- `--yes` and flag not passed → default on (no error; unlike name/bundle/org,
  Firebase has a safe default).

**Yes (default):** no transformation — the cloned template is already ON. Print
today's `flutterfire configure` warning and steps.

**No (`--no-firebase`):** apply the *disable* transformation, then continue
(setup, etc.). Replace the Firebase warning in "next steps" with a Firebase-free
note (how to re-enable later: flip `kFirebaseEnabled`, swap the tracking modules
back, run `flutterfire configure`).

### The disable transformation (CLI, `--no-firebase` only)

1. Flip `kFirebaseEnabled` `true → false` in `lib/app/firebase.dart` (pure text
   transform).
2. Swap the two composition-root module slots to the no-op modules
   (`AnalyticsFirebaseModule → AnalyticsPackageModule`, crash Firebase → no-op),
   editing at the `// fst:analytics-module` / `// fst:crash-module` markers
   (pure text transform).
3. Delete native credential files: `android/app/google-services.json`,
   `ios/Runner/GoogleService-Info.plist`, `firebase.json`.
4. Remove the three Firebase Gradle plugin lines from
   `android/app/build.gradle.kts` (`google-services`, `firebase-perf`,
   `crashlytics`); leave the `apply false` declarations in
   `android/build.gradle.kts` / `settings.gradle.kts` (inert) for a surgical
   edit. (Pure text transform.)
5. Keep `lib/firebase_options.dart` (inert; never referenced when the platform
   is gated off) so `firebase_service.dart` still compiles. Keep all Firebase
   deps (inert).

Result of "No": the project builds and runs with no Firebase project, no leaked
credentials, no native auto-init, and the toggle is reversible.

## Fine-grained tracking (documentation only)

Independent of the create-time choice, a user keeps one of analytics/crash on
Firebase and the other no-op by swapping that service's module line in
`injection.dart` (and, if turning a service on, ensuring the platform is on +
`flutterfire configure` has run). Documented in the project README and the
`analytics` / `app_platform` package READMEs.

## Files touched

**Template (main repo):**

- `packages/analytics/lib/src/` — `NoOpAnalyticsService`; split modules
  (no-op default + Firebase); keep interface/events/observer.
- `packages/app_platform/lib/src/crash/` — `CrashReporter` interface,
  `NoOpCrashReporter`, Firebase adapter behind the interface; module split;
  barrel export.
- `lib/app/firebase.dart` *(new)* — `const bool kFirebaseEnabled`.
- `lib/main.dart` — platform-init gate; crash via `CrashReporter`;
  `_reportBootstrapFailure` via the interface.
- `lib/app/di/injection.dart` — sentinel-marked tracking module slots; default
  wires Firebase modules.
- READMEs (project + `analytics` + `app_platform`) — the toggle and the
  fine-grained swap.

**CLI (`tool/cli`):**

- `lib/src/commands/create_command.dart` — `--firebase`/`--no-firebase`, prompt,
  `--yes` default-on; call the disable transformation on "No".
- `lib/src/rewrite/firebase.dart` *(new)* — pure transforms
  (`setFirebaseEnabled`, `swapTrackingModulesToNoOp`,
  `removeFirebaseGradlePlugins`) + `disableFirebase(projectDir)` (IO: deletions
  + applying the transforms).
- `README.md`, `CHANGELOG.md`, `pubspec.yaml` (bump to 0.5.0).

## Testing

- **CLI pure transforms** (unit, no TTY): `setFirebaseEnabled` flips and is
  idempotent; `removeFirebaseGradlePlugins` removes exactly the three plugin
  lines and leaves the Flutter plugin intact, idempotent;
  `swapTrackingModulesToNoOp` rewrites both marker slots, idempotent.
- **Template**: `NoOpAnalyticsService` / `NoOpCrashReporter` unit tests
  (methods complete, no throw). With `kFirebaseEnabled = true` (default) the
  existing suite and `flutter analyze` stay green — no behaviour change.
- The fully-disabled build (compile + run without Firebase) is validated
  manually / in CI once the template change is on `main` (see ordering).

## Ordering / two-repo dependency

The CLI clones the template from `origin/main` at runtime, so the **template
refactor must land on `main` first**; only then does the CLI's `--no-firebase`
path work end-to-end. The CLI's pure-transform unit tests do not depend on this.
Implementation phases: (1) template refactor (default ON, no behaviour change),
(2) CLI toggle.

## Risks

- **DI module selection** is the main unknown (injectable + `build_runner`); the
  plan must prototype it before the rest. If "two modules, pick one" proves
  awkward, fall back to explicit composition-root registration of the tracking
  bindings.
- **Crash interface extraction** touches `app_platform` (a multi-concern
  package); scope the change to the `crash/` subtree and its barrel export only.
- Default ON keeps risk low for existing users: the disable path is opt-in via
  `--no-firebase`.
