part of 'home_widgets.dart';

class _RecentBookmarksSection extends StatelessWidget {
  const _RecentBookmarksSection({
    required this.recentItems,
    required this.isEmpty,
    required this.hasMatches,
    required this.animationDelay,
  });

  final List<BookmarkSummary> recentItems;
  final bool isEmpty;
  final bool hasMatches;
  final Duration animationDelay;

  @override
  Widget build(BuildContext context) {
    if (isEmpty || !hasMatches) {
      return _EmptyBookmarksPanel(
        message: isEmpty
            ? context.l10n.homeNoBookmarks
            : context.l10n.homeNoMatches,
      ).animateFadeIn(delay: animationDelay);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionHeader(
          title: context.l10n.homeRecentBookmarks,
        ).animateFadeIn(delay: animationDelay),
        const SizedBox(height: AppSpacing.md),
        LayoutBuilder(
          builder: (context, constraints) {
            final twoColumns = constraints.maxWidth >= 620;
            if (!twoColumns) {
              return Column(
                children: [
                  for (final (index, item) in recentItems.indexed) ...[
                    if (index > 0) const SizedBox(height: AppSpacing.md),
                    _BookmarkFeedCard(
                      bookmark: item,
                      featured: index == 0,
                    ),
                  ],
                ],
              ).animateFadeIn(delay: animationDelay + 160.ms);
            }

            return Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.md,
              children: [
                for (final (index, item) in recentItems.indexed)
                  SizedBox(
                    width: index == 0
                        ? constraints.maxWidth
                        : (constraints.maxWidth - AppSpacing.md) / 2,
                    child: _BookmarkFeedCard(
                      bookmark: item,
                      featured: index == 0,
                    ),
                  ),
              ],
            ).animateFadeIn(delay: animationDelay + 160.ms);
          },
        ),
      ],
    );
  }
}

class _EmptyBookmarksPanel extends StatelessWidget {
  const _EmptyBookmarksPanel({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return _ElevatedSurface(
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
                message,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BookmarkFeedCard extends StatelessWidget {
  const _BookmarkFeedCard({
    required this.bookmark,
    required this.featured,
  });

  final BookmarkSummary bookmark;
  final bool featured;

  @override
  Widget build(BuildContext context) {
    final visibleTags = bookmark.tags.take(3).toList();
    final hiddenCount = bookmark.tags.length - visibleTags.length;
    final tagLabel = visibleTags.isNotEmpty
        ? visibleTags.first
        : context.l10n.homeStatsRecent;

    return _ElevatedSurface(
      child: InkWell(
        onTap: () => BookmarkDetailRoute(bookmark.id).push<void>(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _BookmarkVisual(
              icon: featured
                  ? FontAwesomeIcons.bookOpenReader
                  : FontAwesomeIcons.link,
              label: tagLabel,
              height: featured ? 192 : 144,
              colors: featured
                  ? [
                      context.colorScheme.primaryContainer,
                      context.colorScheme.tertiaryContainer,
                    ]
                  : [
                      context.colorScheme.surfaceContainerHigh,
                      context.colorScheme.secondaryContainer,
                    ],
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bookmark.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style:
                        (featured
                                ? context.textTheme.titleLarge
                                : context.textTheme.titleMedium)
                            ?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: context.colorScheme.onSurface,
                            ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    bookmark.description.isNotEmpty
                        ? bookmark.description
                        : context.l10n.homeNoDescription,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      FaIcon(
                        FontAwesomeIcons.link,
                        size: AppIconSize.sm,
                        color: context.colorScheme.outline,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          bookmark.url,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.textTheme.labelSmall?.copyWith(
                            color: context.colorScheme.outline,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (visibleTags.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.md),
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
          ],
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
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: context.colorScheme.outlineVariant.withValues(alpha: 0.54),
        ),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: context.textTheme.labelSmall?.copyWith(
          color: context.colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
