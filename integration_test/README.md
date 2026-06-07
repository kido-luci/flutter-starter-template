# Integration tests

This suite boots the real, assembled `App` widget tree — router, DI-resolved
blocs, theming, the bottom-nav shell, **real Firebase, and the real local
backend** (`simple_backend_server`, `http://localhost:8080` by default) — and
drives it through `WidgetTester` like a user would: filling in forms, tapping
nav destinations, scrolling, asserting on rendered text.

Unlike the project's unit/widget/bloc tests, **nothing here is mocked**. The
single journey in `e2e_test.dart` registers a fresh user, then walks every
feature end-to-end through the real Dio client → repositories → use cases →
backend → SQLite, proving the assembled app actually talks to a real backend —
not just that each screen renders against a stub.

## Running

```bash
tool/run_e2e.sh                 # one shot: reset + start backend, run, tear down
tool/run_e2e.sh <device-id>     # target a specific `flutter devices` id
```

The script resets `simple_backend_server/data.db`, starts the backend, waits
for `/health`, runs the suite against a connected iOS Simulator with
`--dart-define=API_BASE_URL=...`, then stops the backend.

To run manually (e.g. against a backend you're already running):

```bash
cd simple_backend_server && go run .   # in one terminal

fvm flutter test integration_test/e2e_test.dart \
  -d <device-id> \
  --dart-define=API_BASE_URL=http://localhost:8080 \
  --dart-define=FLAVOR=dev
```

`flutter test integration_test` always runs against a real platform target —
never the headless `flutter_tester` surface widget tests use — so you need a
platform enabled. We target the **iOS Simulator** specifically: it reaches the
backend at `localhost` directly, and (unlike macOS, in this repo) ships a
`GoogleService-Info.plist`, so the real Firebase bootstrap succeeds.

**This suite intentionally does not run in CI** — it needs a running backend, a
booted simulator, and emits real Firebase telemetry. Run it locally — and
**always before cutting a release** — as the final check that the assembled app
actually boots, registers, persists data through a real backend, and wires its
features together correctly.

## Layout

- **`support/e2e_app.dart`** — `E2eApp`, the bootstrap helper. Mirrors
  `lib/main.dart`'s production startup (`configureDependencies()`, real
  Firebase/RemoteConfig/Notifications init) once per suite via
  `E2eApp.bootstrap()`, then `E2eApp.pumpApp` boots `const App()` with **no
  constructor overrides** — every dependency resolves through `getIt` to its
  real implementation. Also provides the UI-driving helpers `settle`,
  `pumpUntil`, and `waitForLoginScreen` (splash → login, including its
  2-second minimum-display guard).
- **`e2e_test.dart`** — the one journey: register a unique user → reach Home →
  create a bookmark and open its detail → create a collection and open its
  detail → check the Notifications tab → sign out from Profile, back to login.
  Each run uses a timestamp-unique email/username, so it's order-independent
  and self-cleaning — no DB pre-seed, no teardown, safe to re-run against the
  same `data.db`.

## Why one journey, not one file per feature

A previous version of this suite had a shared mock harness (`AppHarness`) and
one file per feature, each independently signing in as a stubbed user and
asserting against hardcoded fixtures. That caught wiring regressions cheaply,
but proved nothing about the app talking to a real backend, and running it
meant several independent app boots. Folding everything into a single
real-backend journey means **one run** exercises every feature against the real
stack, in the order a user would actually encounter them — register once, then
carry that authenticated session through bookmarks, collections, notifications,
and sign-out.

## Gotchas worth knowing before editing this test

- **Lazy sliver building**: `ListView`/`SliverList` only build elements that
  are within (or near) the visible viewport — even for the plain
  `ListView(children: [...])` constructor. A widget that's the last item in a
  long list may simply not exist in the tree until you
  `tester.scrollUntilVisible(finder, delta)` it into view. A `pumpUntil` that
  "times out" on such a finder looks identical to one that "succeeds" unless
  you check its result — see the next point.
- **`E2eApp.pumpUntil` doesn't distinguish success from timeout**: its loop
  condition is `i < maxTries && finder.evaluate().isEmpty`, which exits on
  *either* the finder becoming non-empty *or* `maxTries` being exhausted. Don't
  assume a `pumpUntil` that "returned" means the finder was found — follow it
  with an `expect(finder, findsOneWidget)` (as the journey does at each step).
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
- **Real network calls are slower and more variable than mocks** — they're
  subject to actual latency, JSON (de)serialization, and SQLite writes on the
  backend. `E2eApp.pumpUntil` defaults to a longer budget
  (100 tries × 200 ms = 20 s) than the old mock-tuned harness; raise it further
  for steps that round-trip more (e.g. registration, which also hits bcrypt).
