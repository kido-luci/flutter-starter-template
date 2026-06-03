part of 'home_widgets.dart';

class _SearchSection extends StatelessWidget {
  const _SearchSection({
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.homeSearchTitle,
          style: context.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: context.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          context.l10n.homeSearchSubtitle,
          style: context.textTheme.bodySmall?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
            height: 1.35,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Material(
          clipBehavior: Clip.antiAlias,
          color: context.colorScheme.surface,
          elevation: context.isDark ? 0 : 3,
          shadowColor: context.colorScheme.shadow.withValues(alpha: 0.08),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: context.l10n.homeSearchHint,
              prefixIcon: const Center(
                widthFactor: 1,
                child: FaIcon(
                  FontAwesomeIcons.magnifyingGlass,
                  size: AppIconSize.sm,
                ),
              ),
              suffixIcon: controller.text.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        controller.clear();
                        onChanged('');
                      },
                      icon: const FaIcon(
                        FontAwesomeIcons.xmark,
                        size: AppIconSize.sm,
                      ),
                      tooltip: context.l10n.bookmarksSearchClear,
                    )
                  : null,
              filled: true,
              fillColor: context.colorScheme.surface,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.lg,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                borderSide: BorderSide(
                  color: context.colorScheme.primary,
                  width: 2,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({
    required this.onAdd,
    required this.onLibrary,
    required this.onTags,
  });

  final VoidCallback onAdd;
  final VoidCallback onLibrary;
  final VoidCallback onTags;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuickActionTile(
            icon: FontAwesomeIcons.plus,
            label: context.l10n.homeQuickAdd,
            onTap: onAdd,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _QuickActionTile(
            icon: FontAwesomeIcons.layerGroup,
            label: context.l10n.homeQuickLibrary,
            onTap: onLibrary,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _QuickActionTile(
            icon: FontAwesomeIcons.tags,
            label: context.l10n.homeQuickTags,
            onTap: onTags,
          ),
        ),
      ],
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final FaIconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      clipBehavior: Clip.antiAlias,
      color: context.colorScheme.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: BorderSide(
          color: context.colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 80,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FaIcon(
                  icon,
                  size: AppIconSize.lg,
                  color: context.colorScheme.primary,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: context.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: context.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  const _FilterChips({
    required this.filters,
    required this.selectedId,
    required this.onSelected,
  });

  final List<_HomeFilter> filters;
  final String selectedId;
  final ValueChanged<_HomeFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: Row(
        children: [
          for (final (index, filter) in filters.indexed) ...[
            if (index > 0) const SizedBox(width: AppSpacing.sm),
            ChoiceChip(
              label: Text(filter.label),
              selected: filter.id == selectedId,
              onSelected: (_) => onSelected(filter),
              labelStyle: context.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
              shape: StadiumBorder(
                side: BorderSide(
                  color: filter.id == selectedId
                      ? context.colorScheme.primary
                      : context.colorScheme.outlineVariant,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SuggestedBookmarksSection extends StatelessWidget {
  const _SuggestedBookmarksSection({required this.items});

  final List<BookmarkSummary> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionHeader(title: context.l10n.homeSuggestedTitle),
        const SizedBox(height: AppSpacing.md),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          child: Row(
            children: [
              for (final (index, item) in items.take(3).indexed) ...[
                if (index > 0) const SizedBox(width: AppSpacing.md),
                SizedBox(
                  width: 240,
                  child: _SuggestedBookmarkCard(bookmark: item),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _SuggestedBookmarkCard extends StatelessWidget {
  const _SuggestedBookmarkCard({required this.bookmark});

  final BookmarkSummary bookmark;

  @override
  Widget build(BuildContext context) {
    final label = bookmark.tags.isNotEmpty
        ? bookmark.tags.first
        : context.l10n.homeBookmarkVisualFallback;

    return _ElevatedSurface(
      child: InkWell(
        onTap: () => BookmarkDetailRoute(bookmark.id).push<void>(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _BookmarkVisual(
              icon: FontAwesomeIcons.clockRotateLeft,
              label: label,
              height: 96,
              linkUrl: bookmark.url,
              fallbackImageUrl: bookmark.fallbackThumbnailUrl,
              colors: [
                context.colorScheme.tertiaryContainer,
                context.colorScheme.secondaryContainer,
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bookmark.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: context.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    bookmark.url,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.labelSmall?.copyWith(
                      color: context.colorScheme.outline,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeaturedCollectionsSection extends StatelessWidget {
  const _FeaturedCollectionsSection({required this.items});

  final List<BookmarkSummary> items;

  @override
  Widget build(BuildContext context) {
    final collections = _collections(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionHeader(
          title: context.l10n.homeFeaturedCollections,
          actionLabel: context.l10n.homeViewAllBookmarks,
          onActionPressed: () => const BookmarksListRoute().push<void>(context),
        ),
        const SizedBox(height: AppSpacing.md),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          child: Row(
            children: [
              for (final (index, collection) in collections.indexed) ...[
                if (index > 0) const SizedBox(width: AppSpacing.md),
                _CollectionCard(collection: collection),
              ],
            ],
          ),
        ),
      ],
    );
  }

  List<_CollectionData> _collections(BuildContext context) {
    final tagCounts = <String, int>{};
    for (final item in items) {
      for (final tag in item.tags) {
        final normalized = tag.trim();
        if (normalized.isNotEmpty) {
          tagCounts.update(normalized, (value) => value + 1, ifAbsent: () => 1);
        }
      }
    }

    final tagCollections = tagCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final fromTags = tagCollections.take(3).map((entry) {
      return _CollectionData(
        title: entry.key,
        icon: FontAwesomeIcons.hashtag,
        colors: [
          context.colorScheme.primaryContainer,
          context.colorScheme.primary,
        ],
      );
    }).toList();

    if (fromTags.length >= 3) return fromTags;

    return [
      ...fromTags,
      _CollectionData(
        title: context.l10n.homeFilterDesign,
        icon: FontAwesomeIcons.palette,
        colors: [
          context.colorScheme.primary,
          context.colorScheme.tertiary,
        ],
      ),
      _CollectionData(
        title: context.l10n.homeFilterArticles,
        icon: FontAwesomeIcons.bookOpen,
        colors: [
          context.colorScheme.tertiaryContainer,
          context.colorScheme.tertiary,
        ],
      ),
      _CollectionData(
        title: context.l10n.homeFilterTools,
        icon: FontAwesomeIcons.screwdriverWrench,
        colors: [
          context.colorScheme.secondary,
          context.colorScheme.inverseSurface,
        ],
      ),
    ].take(3).toList();
  }
}

class _CollectionData {
  const _CollectionData({
    required this.title,
    required this.icon,
    required this.colors,
  });

  final String title;
  final FaIconData icon;
  final List<Color> colors;
}

class _CollectionCard extends StatelessWidget {
  const _CollectionCard({required this.collection});

  final _CollectionData collection;

  @override
  Widget build(BuildContext context) {
    return Material(
      clipBehavior: Clip.antiAlias,
      color: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Ink(
        width: 160,
        height: 104,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: collection.colors,
          ),
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: InkWell(
          onTap: () => const BookmarksListRoute().push<void>(context),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FaIcon(
                  collection.icon,
                  color: context.colorScheme.onPrimary,
                  size: AppIconSize.md,
                ),
                const Spacer(),
                Text(
                  collection.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.labelMedium?.copyWith(
                    color: context.colorScheme.onPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WeeklyDigestPanel extends StatelessWidget {
  const _WeeklyDigestPanel({
    required this.recentCount,
    required this.onPressed,
  });

  final int recentCount;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      clipBehavior: Clip.antiAlias,
      color: context.colorScheme.secondaryContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Stack(
        children: [
          PositionedDirectional(
            top: -16,
            end: -8,
            child: FaIcon(
              FontAwesomeIcons.wandMagicSparkles,
              size: 112,
              color: context.colorScheme.onSecondaryContainer.withValues(
                alpha: 0.08,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.homeWeeklyDigestEyebrow,
                  style: context.textTheme.labelSmall?.copyWith(
                    color: context.colorScheme.onSecondaryContainer,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  context.l10n.homeWeeklyDigestHeadline,
                  style: context.textTheme.titleLarge?.copyWith(
                    color: context.colorScheme.onSecondaryContainer,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  context.l10n.homeWeeklyDigestBody(recentCount),
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colorScheme.onSecondaryContainer.withValues(
                      alpha: 0.78,
                    ),
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                FilledButton(
                  onPressed: onPressed,
                  child: Text(context.l10n.homeReadDigest),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    this.actionLabel,
    this.onActionPressed,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onActionPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: context.colorScheme.onSurface,
            ),
          ),
        ),
        if (actionLabel != null && onActionPressed != null)
          TextButton(
            onPressed: onActionPressed,
            child: Text(actionLabel!),
          ),
      ],
    );
  }
}

class _ElevatedSurface extends StatelessWidget {
  const _ElevatedSurface({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      clipBehavior: Clip.antiAlias,
      color: context.colorScheme.surface,
      elevation: context.isDark ? 0 : 3,
      shadowColor: context.colorScheme.shadow.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: BorderSide(
          color: context.colorScheme.outlineVariant.withValues(alpha: 0.24),
        ),
      ),
      child: child,
    );
  }
}

class _BookmarkVisual extends StatelessWidget {
  const _BookmarkVisual({
    required this.icon,
    required this.label,
    required this.height,
    required this.colors,
    required this.linkUrl,
    this.fallbackImageUrl,
  });

  final FaIconData icon;
  final String label;
  final double height;
  final List<Color> colors;
  final String linkUrl;
  final String? fallbackImageUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: AppLinkPreviewThumbnail(
              url: linkUrl,
              fallbackImageUrl: fallbackImageUrl,
              semanticLabel: label,
              fallbackBuilder: (context) => Center(
                child: FaIcon(
                  icon,
                  size: AppIconSize.xl,
                  color: context.colorScheme.primary.withValues(alpha: 0.7),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0),
                      Colors.black.withValues(alpha: 0.24),
                    ],
                  ),
                ),
              ),
            ),
          ),
          PositionedDirectional(
            top: AppSpacing.sm,
            end: AppSpacing.sm,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: context.colorScheme.surface.withValues(alpha: 0.82),
                borderRadius: BorderRadius.circular(AppRadius.sm),
                border: Border.all(
                  color: context.colorScheme.outlineVariant.withValues(
                    alpha: 0.5,
                  ),
                ),
              ),
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.labelSmall?.copyWith(
                  color: context.colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
