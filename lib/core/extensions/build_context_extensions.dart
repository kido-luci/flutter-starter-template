/// Re-exports the localization accessors (`AppLocalizations` and the
/// `context.l10n` extension) from `package:localization`.
///
/// Kept as a thin shim so existing in-app imports of this path keep working;
/// feature packages import `package:localization` directly.
library;

export 'package:localization/localization.dart';
