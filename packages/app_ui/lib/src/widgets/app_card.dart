import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app_ui.dart';

/// Themed surface for grouping related content, with consistent radius,
/// elevation, padding, and an optional tap interaction.
///
/// Wraps Material [Card] (which already inherits radius and elevation from
/// the theme's `cardTheme`, see `_componentThemes` in `app_theme.dart`) and
/// adds an [InkWell] with haptic feedback when [onTap] is provided, so
/// feature code gets a consistent "lifted" card without re-styling it inline.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.onTap,
    this.margin,
    this.color,
  });

  /// Content laid out inside the card's padding.
  final Widget child;

  /// Padding applied between the card's edge and [child].
  final EdgeInsetsGeometry padding;

  /// Called when the card is tapped. When non-null, the card becomes
  /// interactive (ink ripple + light haptic feedback on press).
  final VoidCallback? onTap;

  /// Outer margin around the card. Defaults to [Card]'s own margin.
  final EdgeInsetsGeometry? margin;

  /// Overrides the card's background color. Defaults to the theme's
  /// `cardTheme` color.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppRadius.lg);

    return Card(
      margin: margin,
      color: color,
      shape: RoundedRectangleBorder(borderRadius: radius),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        borderRadius: radius,
        onTap: onTap != null
            ? () {
                HapticFeedback.lightImpact();
                onTap!();
              }
            : null,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}
