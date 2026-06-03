part of 'home_widgets.dart';

class _RecentBookmarksSection extends StatelessWidget {
  const _RecentBookmarksSection({
    required this.recentItems,
    required this.isEmpty,
    required this.animationDelay,
  });

  static const double _carouselHeight = 188;

  final List<BookmarkSummary> recentItems;
  final bool isEmpty;
  final Duration animationDelay;

  @override
  Widget build(BuildContext context) {
    if (isEmpty) {
      return Material(
        clipBehavior: Clip.antiAlias,
        color: context.colorScheme.surfaceContainerHighest.withValues(
          alpha: context.isDark ? 0.28 : 0.46,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: BorderSide(
            color: context.colorScheme.outlineVariant.withValues(alpha: 0.36),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Row(
            children: [
              FaIcon(
                FontAwesomeIcons.bookmark,
                color: context.colorScheme.outline,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  context.l10n.homeNoBookmarks,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ).animateFadeIn(delay: animationDelay);
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            FaIcon(
              FontAwesomeIcons.clockRotateLeft,
              size: AppIconSize.sm,
              color: context.colorScheme.primary,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                context.l10n.homeRecentBookmarks,
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ).animateFadeIn(delay: animationDelay),
        const SizedBox(height: AppSpacing.md),
        AppCarousel(
          items: recentItems
              .map((b) => _BookmarkCarouselCard(bookmark: b))
              .toList(),
          showIndicators: recentItems.length > 1,
          height: _carouselHeight,
          viewportFraction: 0.92,
        ).animateFadeIn(delay: animationDelay + 200.ms),
      ],
    );
  }
}

class _BookmarkCarouselCard extends StatelessWidget {
  const _BookmarkCarouselCard({required this.bookmark});

  final BookmarkSummary bookmark;

  @override
  Widget build(BuildContext context) {
    final visibleTags = bookmark.tags.take(3).toList();
    final hiddenCount = bookmark.tags.length - visibleTags.length;

    return Material(
      clipBehavior: Clip.antiAlias,
      color: context.colorScheme.surfaceContainerHighest.withValues(
        alpha: context.isDark ? 0.32 : 0.52,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: BorderSide(
          color: context.colorScheme.outlineVariant.withValues(alpha: 0.36),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: () => BookmarkDetailRoute(bookmark.id).push<void>(context),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                bookmark.title,
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                bookmark.url,
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.md),
              Expanded(
                child: Text(
                  bookmark.description.isNotEmpty
                      ? bookmark.description
                      : context.l10n.homeNoDescription,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                    height: 1.35,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (visibleTags.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: [
                    for (final tag in visibleTags) _RecentTag(label: tag),
                    if (hiddenCount > 0) _RecentTag(label: '+$hiddenCount'),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentTag extends StatelessWidget {
  const _RecentTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: context.colorScheme.secondaryContainer.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: context.textTheme.labelSmall?.copyWith(
          color: context.colorScheme.onSecondaryContainer,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
