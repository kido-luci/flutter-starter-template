import 'package:flutter/material.dart';

/// Centralized elevation scale and shadow tokens.
///
/// Use these tokens instead of hardcoded elevation/shadow values so depth
/// stays consistent across cards, buttons, and overlays, and can be tuned in
/// one place.
abstract final class AppElevation {
  /// 0 - flat surfaces (e.g. app bars, flush content).
  static const double none = 0;

  /// 1 - barely-there separation (e.g. resting cards, list tiles).
  static const double sm = 1;

  /// 3 - default raised surfaces (e.g. buttons, chips, sheets).
  static const double md = 3;

  /// 6 - prominently lifted surfaces (e.g. dialogs, FABs, overlays).
  static const double lg = 6;

  /// A soft, multi-layered "lifted" shadow for cards and overlays.
  ///
  /// Combines a tight, low-opacity layer for contact shadow with a broader,
  /// softer layer for ambient depth, so elevated surfaces read as gently
  /// floating rather than harshly dropped. Based on the shadow originally
  /// inlined in `AppScaffold`'s loading overlay.
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black12,
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
    BoxShadow(
      color: Colors.black12,
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
  ];
}
