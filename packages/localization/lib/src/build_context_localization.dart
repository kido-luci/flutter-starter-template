import 'package:flutter/widgets.dart';

import '../l10n/app_localizations.dart';

/// Localization accessor for a [BuildContext].
extension BuildContextLocalization on BuildContext {
  /// The generated [AppLocalizations] for the current locale.
  AppLocalizations get l10n => AppLocalizations.of(this);
}
