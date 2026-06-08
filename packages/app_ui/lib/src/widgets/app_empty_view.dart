import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../app_ui.dart';

/// Full-screen placeholder for empty lists or states with no data yet.
class AppEmptyView extends StatelessWidget {
  const AppEmptyView({
    super.key,
    required this.message,
    this.title,
    this.icon = FontAwesomeIcons.inbox,
    this.action,
  });

  final String message;
  final String? title;
  final FaIconData icon;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FaIcon(
              icon,
              size: AppIconSize.xxxl,
              color: context.colorScheme.onSurfaceVariant,
            ).animateScale(),
            const SizedBox(height: AppSpacing.lg),
            if (title != null) ...[
              Text(
                title!,
                style: context.textTheme.titleLarge,
                textAlign: TextAlign.center,
              ).animateFadeIn(delay: AppDurations.fast),
              const SizedBox(height: AppSpacing.sm),
            ],
            Text(
              message,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ).animateFadeIn(delay: AppDurations.fast),
            if (action != null) ...[
              const SizedBox(height: AppSpacing.xxl),
              action!.animateSlideUp(delay: AppDurations.medium),
            ],
          ],
        ),
      ),
    );
  }
}
