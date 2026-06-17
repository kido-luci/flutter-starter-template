import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:localization/localization.dart';

class SplashContent extends StatelessWidget {
  const SplashContent({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(AppRadius.xl),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.shadow.withValues(alpha: 0.15),
                    blurRadius: 30,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Image.asset(
                'assets/icons/logo.png',
                width: 72,
                height: 72,
                fit: BoxFit.cover,
              ),
            ).animateScale(),
            const SizedBox(height: AppSpacing.xxl),
            Text(
              context.l10n.appTitle,
              style: context.textTheme.headlineSmall?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ).animateSlideUp(delay: AppDurations.medium),
            const SizedBox(height: AppSpacing.xxxl),
            const _LoadingDots().animateFadeIn(delay: AppDurations.slow),
          ],
        ),
      ),
    );
  }
}

/// Three dots that pulse in sequence, a softer loading cue than a spinner.
class _LoadingDots extends StatelessWidget {
  const _LoadingDots();

  static const int _count = 3;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme.primary;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < _count; i++) ...[
          if (i > 0) const SizedBox(width: AppSpacing.sm),
          _Dot(
            color: color,
            delay: Duration(milliseconds: i * 160),
          ),
        ],
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.color, required this.delay});

  final Color color;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    return Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        )
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .scaleXY(
          begin: 0.6,
          end: 1,
          duration: AppDurations.xslow,
          delay: delay,
          curve: Curves.easeInOut,
        )
        .fadeIn(begin: 0.4, duration: AppDurations.xslow);
  }
}
