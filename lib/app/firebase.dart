/// Whether the app wires the Firebase *platform* (core, remote config,
/// messaging, performance) at startup.
///
/// `true` by default. `fst create --no-firebase` flips this to `false` and
/// strips the native Firebase config, so the app builds and runs without a
/// Firebase project. Tracking (analytics and crash reporting) is selected
/// independently via the `// fst:analytics-impl` and `// fst:crash-impl`
/// bindings in the `analytics` and `app_platform` packages.
const bool kFirebaseEnabled = true;
