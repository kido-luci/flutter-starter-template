import 'package:flutter/material.dart';

import '../../app_ui.dart';

/// Animates a bright highlight sweeping across its [child] subtree.
///
/// Wrap one or more [AppSkeleton] shapes in a single [AppShimmer] so they all
/// share one synchronized sweep. The highlight is painted over the opaque parts
/// of the subtree using [BlendMode.srcATop], so the shapes' own color only acts
/// as a fallback when [enabled] is `false`.
class AppShimmer extends StatefulWidget {
  const AppShimmer({
    super.key,
    required this.child,
    this.enabled = true,
    this.duration = const Duration(milliseconds: 1400),
  });

  final Widget child;

  /// When `false`, the static placeholder shapes are shown without animation.
  final bool enabled;

  /// Time for one full left-to-right sweep.
  final Duration duration;

  @override
  State<AppShimmer> createState() => _AppShimmerState();
}

class _AppShimmerState extends State<AppShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  );

  @override
  void initState() {
    super.initState();
    if (widget.enabled) _controller.repeat();
  }

  @override
  void didUpdateWidget(AppShimmer oldWidget) {
    super.didUpdateWidget(oldWidget);
    _controller.duration = widget.duration;
    if (widget.enabled && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.enabled && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;

    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final base = colorScheme.surfaceContainerHighest;
    final highlight = Color.alphaBlend(
      Colors.white.withValues(alpha: isDark ? 0.10 : 0.55),
      base,
    );

    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) => LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [base, highlight, base],
            stops: const [0.2, 0.5, 0.8],
            transform: _SlidingGradientTransform(_controller.value),
          ).createShader(bounds),
          child: child,
        );
      },
    );
  }
}

/// Translates a gradient horizontally to drive the shimmer sweep.
class _SlidingGradientTransform extends GradientTransform {
  const _SlidingGradientTransform(this.slidePercent);

  final double slidePercent;

  @override
  Matrix4 transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(
      bounds.width * (slidePercent * 2 - 1),
      0,
      0,
    );
  }
}

/// A single placeholder shape used to compose loading skeletons.
///
/// Place these inside an [AppShimmer] to animate them. Use [AppSkeleton.line]
/// for text rows, [AppSkeleton.circle] for avatars, and the default
/// constructor for blocks such as images or cards.
class AppSkeleton extends StatelessWidget {
  const AppSkeleton({
    super.key,
    this.width,
    this.height = 16,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
  }) : shape = BoxShape.rectangle;

  /// A thin rounded bar approximating a line of text.
  const AppSkeleton.line({super.key, this.width, this.height = 12})
    : shape = BoxShape.rectangle,
      borderRadius = const BorderRadius.all(Radius.circular(6));

  /// A circular placeholder, e.g. an avatar.
  const AppSkeleton.circle({super.key, required double size})
    : width = size,
      height = size,
      shape = BoxShape.circle,
      borderRadius = null;

  final double? width;
  final double height;
  final BoxShape shape;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        shape: shape,
        borderRadius: shape == BoxShape.circle ? null : borderRadius,
      ),
    );
  }
}

/// A skeleton placeholder shaped like a [ListTile]: a leading square, a wide
/// title line, and a shorter subtitle line.
class AppSkeletonListTile extends StatelessWidget {
  const AppSkeletonListTile({super.key, this.hasLeading = true});

  /// Whether to render the leading square placeholder.
  final bool hasLeading;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          if (hasLeading) ...[
            const AppSkeleton(width: 40, height: 40),
            const SizedBox(width: AppSpacing.lg),
          ],
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppSkeleton.line(width: 180),
                SizedBox(height: AppSpacing.sm),
                AppSkeleton.line(width: 120),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A shimmering list of [AppSkeletonListTile]s for full-screen list loading.
class AppSkeletonList extends StatelessWidget {
  const AppSkeletonList({
    super.key,
    this.itemCount = 8,
    this.hasLeading = true,
  });

  final int itemCount;
  final bool hasLeading;

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: itemCount,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (_, _) => AppSkeletonListTile(hasLeading: hasLeading),
      ),
    ).animateFadeIn(duration: AppDurations.fast);
  }
}
