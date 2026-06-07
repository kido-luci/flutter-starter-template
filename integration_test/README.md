# Integration tests

These tests boot the real, assembled `App` widget tree — router, DI-resolved
blocs, theming, the bottom-nav shell — and drive it through `WidgetTester` like
a user would: filling in forms, tapping nav destinations, scrolling, asserting
on rendered text. They run **headless**, with no backend, Firebase, or native
storage: every plugin boundary (auth use-cases, sync controllers, analytics,
package info, image picker, share, video player, …) is mocked via `App`'s
nullable constructor overrides and `getIt` factory registrations.

This catches wiring regressions that isolated unit/widget/bloc tests miss —
router misconfiguration, missing DI registrations, session-gating bugs,
bloc↔screen integration — without the cost or flakiness of running on a real
device or emulator.

## Running

```bash
fvm flutter test integration_test                              # whole suite
fvm flutter test integration_test/bookmarks_flow_test.dart     # one file
```

Unlike plain widget tests, `flutter test integration_test` boots the real
assembled `App` and always runs it against an actual platform target — never
the headless `flutter_tester` surface widget tests use. Locally that means it
builds and launches a real desktop app window (e.g. macOS), so you need a
desktop platform enabled (`flutter config --enable-macos-desktop` or the
equivalent for your OS).

**This suite intentionally does not run in CI** — the Ubuntu runner has no
platform target set up for it (no Linux/web desktop scaffold, no
emulator/simulator), and wiring one up is significant infrastructure (native
toolchains, build dependencies, platform-specific flakiness) for a test suite
whose job is to catch wiring regressions, not run on every push. Run it
locally — and **always before cutting a release** — as the final check that
the assembled app actually boots, navigates, and wires its features together
correctly.

## Layout

- **`support/harness.dart`** — `AppHarness`, the shared test harness. Each test
  file creates one in `setUp`, calls `harness.setUp()`, optionally registers
  additional feature blocs in `getIt`, then drives the UI with `pumpApp` /
  `signInToHome` / `settle` / `pumpUntil`. `harness.tearDown()` closes every
  bloc and resets `getIt`. See the doc comment on `AppHarness` for the full
  usage pattern.
- **`app_test.dart`** — the original end-to-end smoke test: unauthenticated →
  splash → login → home, asserting the sync controllers start once signed in.
  Predates the harness extraction; kept as a self-contained reference for the
  full boot sequence.
- **`auth_flow_test.dart`** — login failure (wrong credentials surface
  `l10n.errorUnknown` and stay on the login screen) and Login → Register
  navigation.
- **`bookmarks_flow_test.dart`** — list renders fixture bookmarks, the FAB opens
  the create form, and tapping a card opens the detail screen (verifying
  `GetBookmark` is invoked).
- **`collections_flow_test.dart`** — list renders the fixture collection (via
  the home screen's "Featured Collections" → "View all"), the FAB opens the
  create form, and tapping a collection opens its detail screen.
- **`notifications_flow_test.dart`** — the Notifications tab renders the feed
  and activity sections, an unread notification appears, and tapping it invokes
  `MarkNotificationRead`.
- **`profile_flow_test.dart`** — the Profile screen shows the Appearance and
  Account sections, and signing out returns to the login screen and stops all
  three sync controllers.

## Why a shared harness

Booting the app for an integration test means wiring a lot of things that have
nothing to do with any one feature: `getIt.reset()`, `SharedPreferences` mock
values, `PackageInfo` stubs, the auth/session/sync-controller mocks, `AuthBloc`
and `ThemeBloc`, plus the splash → login → home sign-in sequence (which is
timing-sensitive — it has to wait out the splash screen's minimum-display guard
and poll for the home screen to appear). `AppHarness` extracts all of that once
so each feature file only registers the blocs and use-case mocks it actually
cares about, then calls `harness.signInToHome(tester)` and starts asserting.

## Gotchas worth knowing before editing these tests

- **Lazy sliver building**: `ListView`/`SliverList` only build elements that
  are within (or near) the visible viewport — even for the plain
  `ListView(children: [...])` constructor. A widget that's the last item in a
  long list may simply not exist in the tree until you
  `tester.scrollUntilVisible(finder, delta)` it into view. A `pumpUntil` that
  "times out" on such a finder looks identical to one that "succeeds" unless
  you check its result — see the next point.
- **`AppHarness.pumpUntil` doesn't distinguish success from timeout**: its loop
  condition is `i < maxTries && finder.evaluate().isEmpty`, which exits on
  *either* the finder becoming non-empty *or* `maxTries` being exhausted. Don't
  assume a `pumpUntil` that "returned" means the finder was found — follow it
  with an `expect(finder, findsOneWidget)` (as every test here does).
- **Floating bottom-nav pill overlap**: `AppAdaptiveScaffold`'s floating pill
  bar is an overlay docked to the bottom of the screen. At the integration test
  viewport size it can visually cover the last item in scrollable content (e.g.
  the Profile screen's "Sign out" button), so a coordinate-based `tester.tap`
  lands on the pill instead of the button — not a finder bug, a real layout
  characteristic. When that happens, grab the widget directly
  (`tester.widget<FilledButton>(find.byType(FilledButton))`) and invoke its
  callback (`.onPressed!()`), bypassing hit-testing entirely.
- **`find.ancestor`/`find.widgetWithText` can't traverse `FilledButton.icon`
  variants**: in Flutter 3.44.0, `_FilledButtonWithIconChild` wraps its label in
  a `Flexible`, which breaks ancestor-finder traversal from the label up to the
  button. Use a bare `find.text(...)` or look the button up directly by type
  when it's the only one of its kind on the screen.
