part of 'home_widgets.dart';

class _WelcomeSection extends StatelessWidget {
  const _WelcomeSection({required this.totalBookmarks});

  final int totalBookmarks;

  @override
  Widget build(BuildContext context) {
    final session = SessionScope.of(context);
    return ListenableBuilder(
      listenable: session,
      builder: (context, _) {
        final username = session.currentUser?.username ?? '';
        return Material(
          clipBehavior: Clip.antiAlias,
          color: context.colorScheme.primaryContainer.withValues(
            alpha: context.isDark ? 0.34 : 0.7,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            side: BorderSide(
              color: context.colorScheme.primary.withValues(alpha: 0.12),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: context.colorScheme.primary,
                  child: FaIcon(
                    FontAwesomeIcons.solidUser,
                    size: AppIconSize.lg,
                    color: context.colorScheme.onPrimary,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppAnimatedText(
                        text: context.l10n.homeWelcome(username),
                        type: AppAnimatedTextType.fade,
                        textStyle: context.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: context.colorScheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        context.l10n.homeSignedInBody,
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: context.colorScheme.onPrimaryContainer
                              .withValues(alpha: 0.78),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                _BookmarkCountBadge(count: totalBookmarks),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _BookmarkCountBadge extends StatelessWidget {
  const _BookmarkCountBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 48),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: context.colorScheme.surface.withValues(alpha: 0.76),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            count.toString(),
            style: context.textTheme.titleMedium?.copyWith(
              color: context.colorScheme.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            context.l10n.homeStatsTotal,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.labelSmall?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryActionPanel extends StatelessWidget {
  const _PrimaryActionPanel({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      clipBehavior: Clip.antiAlias,
      color: context.colorScheme.surfaceContainerHighest.withValues(
        alpha: context.isDark ? 0.28 : 0.5,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: BorderSide(
          color: context.colorScheme.outlineVariant.withValues(alpha: 0.36),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: context.colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: FaIcon(
                FontAwesomeIcons.solidBookmark,
                size: AppIconSize.md,
                color: context.colorScheme.onSecondaryContainer,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                context.l10n.homeMyBookmarks,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            AppButton(
              label: context.l10n.homeViewAllBookmarks,
              icon: FontAwesomeIcons.arrowRight,
              variant: AppButtonVariant.tonal,
              size: AppButtonSize.small,
              onPressed: onPressed,
            ),
          ],
        ),
      ),
    );
  }
}
