import 'package:injectable/injectable.dart';

import 'crash_reporter.dart';

@module
abstract class CrashModule {
  /// Binds the app's [CrashReporter].
  ///
  /// `fst create --no-firebase` rewrites the expression at the
  /// `// fst:crash-impl` marker to `const NoOpCrashReporter()`. To use a
  /// non-Firebase backend, replace it with your own [CrashReporter].
  @lazySingleton
  CrashReporter provideCrashReporter() => FirebaseCrashReporter(); // fst:crash-impl
}
