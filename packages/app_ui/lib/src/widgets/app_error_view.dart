import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../app_ui.dart';

/// Full-screen error placeholder with an icon, message, and optional retry.
class AppErrorView extends StatelessWidget {
  const AppErrorView({
    super.key,
    required this.message,
    this.title,
    this.onRetry,
    this.retryLabel,
    this.icon = FontAwesomeIcons.circleExclamation,
  });

  final String message;
  final String? title;
  final VoidCallback? onRetry;
  final String? retryLabel;
  final FaIconData icon;

  @override
  Widget build(BuildContext context) {
    final effectiveOnRetry = onRetry != null
        ? () {
            HapticFeedback.lightImpact();
            onRetry!();
          }
        : null;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FaIcon(
              icon,
              size: AppIconSize.xxxl,
              color: context.colorScheme.error,
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
              style: context.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ).animateFadeIn(delay: AppDurations.fast),
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.xxl),
              FilledButton.tonalIcon(
                onPressed: effectiveOnRetry,
                icon: const FaIcon(FontAwesomeIcons.rotateRight),
                label: Text(retryLabel ?? 'Retry'),
              ).animateSlideUp(delay: AppDurations.medium),
            ],
          ],
        ),
      ),
    );
  }
}
