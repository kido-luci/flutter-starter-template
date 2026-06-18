# Tests

This directory contains the automated tests for the Flutter Starter Template.

The testing strategy emphasizes unit tests for logic and widget tests for UI components, following the feature-first Clean Architecture pattern used in the `lib` directory.

## Directory Structure

This `test/` directory holds **app-level tests only**. Each feature and infra
package owns its own tests under `packages/<name>/test` (each feature with a
`test/support.dart` for its mocks/fixtures), so there are no `features/` or
`core/` suites here — they live beside the packages they exercise.

- `architecture/`: Guardrail tests over the whole workspace —
  `package_layering_test.dart` (dependency direction) and
  `feature_boundaries_test.dart` (no cross-feature imports outside the
  capability allowlist).
- `test_utils/`
  - `mocks.dart`: The few cross-feature mocks the app-level `widget_test` needs
    (auth use-case mocks, `MockNotificationsBloc`). Feature-local mocks live in
    each feature package's `test/support.dart`; shared doubles
    (`FakeSession`, the reader mocks) and fixtures (`testUser`, `testFailure`)
    come from `package:test_utils`.
- `test_utils.dart`: Barrel re-exporting `package:test_utils/test_utils.dart`
  alongside the local `mocks.dart`.
- `widget_test.dart`: An integration-style widget test that exercises the full
  app startup and sign-in flow.

## Mocking Dependencies

This project uses [`mocktail`](https://pub.dev/packages/mocktail) for mocking
dependencies. `mocktail` is runtime-based, so mocks are **written by hand** and
require **no code generation** — declare them directly:

```dart
class MockAuthRepository extends Mock implements AuthRepository {}
```

The `Mock`/`Fake` base classes come from `package:test_utils/test_utils.dart`,
re-exported through the `test_utils.dart` barrel.

## Running Tests

Since this project pins Flutter to a specific version via FVM, always run tests using `fvm flutter`.

Run all tests:
```bash
fvm flutter test
```

Run tests in a specific file:
```bash
fvm flutter test test/widget_test.dart
```

Run a specific test by name (substring match):
```bash
fvm flutter test --name "signs in and lands on home screen"
```
