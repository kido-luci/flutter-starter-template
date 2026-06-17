/// Cross-feature domain contracts shared between optional features and the
/// core app. Features implement these interfaces; the home feature and
/// cross-feature widgets consume them without depending on each other directly.
library;

export 'src/activity_notifier.dart';
export 'src/auth_user.dart';
export 'src/bookmark_stats.dart';
export 'src/bookmark_summaries.dart';
export 'src/collections.dart';
export 'src/di.module.dart' show SharedContractsPackageModule;
export 'src/session.dart';
