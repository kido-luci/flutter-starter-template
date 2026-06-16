part of 'bookmarks_list_card.dart';

/// The card's hero image.
///
/// Prefers an uploaded image, then the URL's link-preview image, and finally a
/// branded gradient with the domain favicon so a card never looks empty.
class _BookmarkCardHero extends StatelessWidget {
  const _BookmarkCardHero({required this.bookmark});

  static const double _height = 150;

  final Bookmark bookmark;

  @override
  Widget build(BuildContext context) {
    final uploaded = bookmark.imageUrls.isNotEmpty
        ? bookmark.imageUrls.first
        : null;

    final Widget child;
    if (uploaded != null) {
      child = uploaded.startsWith('http')
          ? AppNetworkImage(
              imageUrl: uploaded,
              fit: BoxFit.cover,
              width: double.infinity,
              height: _height,
              errorWidget: (context, _, _) => _HeroFallback(url: bookmark.url),
            )
          : Image.file(
              File(uploaded),
              fit: BoxFit.cover,
              width: double.infinity,
              height: _height,
              errorBuilder: (context, _, _) => _HeroFallback(url: bookmark.url),
            );
    } else {
      child = AppLinkPreviewThumbnail(
        url: bookmark.url,
        fallbackBuilder: (context) => _HeroFallback(url: bookmark.url),
      );
    }

    return SizedBox(height: _height, width: double.infinity, child: child);
  }
}

/// Gradient placeholder shown when no preview or uploaded image is available.
///
/// Centers the domain favicon in an app-icon-style tile so the hero still
/// signals the bookmark's source.
class _HeroFallback extends StatelessWidget {
  const _HeroFallback({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primaryContainer.withValues(alpha: 0.55),
            colorScheme.tertiaryContainer.withValues(alpha: 0.55),
          ],
        ),
      ),
      child: Center(
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withValues(alpha: 0.12),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: _Favicon(url: url, size: 30),
        ),
      ),
    );
  }
}

/// The favicon + domain + timestamp row, with a trailing actions menu button.
class _BookmarkCardMeta extends StatelessWidget {
  const _BookmarkCardMeta({required this.bookmark});

  final Bookmark bookmark;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return Row(
      children: [
        _Favicon(url: bookmark.url),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            _displayDomain(bookmark.url),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        if (bookmark.isPendingSync) ...[
          Tooltip(
            message: context.l10n.bookmarksNotYetSynced,
            child: FaIcon(
              FontAwesomeIcons.cloudArrowUp,
              size: 11,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
        Text(
          _relativeLabel(context, bookmark.createdAt),
          style: context.textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        _CardMenuButton(bookmark: bookmark),
      ],
    );
  }
}

class _CardMenuButton extends StatelessWidget {
  const _CardMenuButton({required this.bookmark});

  final Bookmark bookmark;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: () => _showCardMenu(context, bookmark),
      radius: 18,
      child: Padding(
        padding: const EdgeInsets.only(left: AppSpacing.xs),
        child: FaIcon(
          FontAwesomeIcons.ellipsisVertical,
          size: 14,
          color: context.colorScheme.onSurfaceVariant,
          semanticLabel: context.l10n.bookmarkMoreActions,
        ),
      ),
    );
  }
}

/// A small rounded favicon for the bookmark's domain.
///
/// Loads the favicon through Google's public favicon service and falls back to
/// a generic globe glyph when the domain can't be resolved or fetched.
class _Favicon extends StatelessWidget {
  const _Favicon({required this.url, this.size = 18});

  final String url;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final host = Uri.tryParse(url)?.host ?? '';
    final fallback = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      color: colorScheme.surfaceContainerHighest,
      child: FaIcon(
        FontAwesomeIcons.globe,
        size: size * 0.55,
        color: colorScheme.onSurfaceVariant,
      ),
    );

    if (host.isEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.xs),
        child: fallback,
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.xs),
      child: AppNetworkImage(
        imageUrl: 'https://www.google.com/s2/favicons?domain=$host&sz=64',
        width: size,
        height: size,
        placeholder: (_, _) => fallback,
        errorWidget: (_, _, _) => fallback,
      ),
    );
  }
}

class _BookmarkCardTags extends StatelessWidget {
  const _BookmarkCardTags({required this.tags});

  static const int _maxVisibleTags = 3;

  final List<String> tags;

  @override
  Widget build(BuildContext context) {
    final visibleTags = tags.take(_maxVisibleTags).toList();
    final hiddenCount = tags.length - visibleTags.length;

    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: [
        for (final tag in visibleTags) _BookmarkCardTag(label: tag),
        if (hiddenCount > 0) _BookmarkCardTag(label: '+$hiddenCount'),
      ],
    );
  }
}

class _BookmarkCardTag extends StatelessWidget {
  const _BookmarkCardTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: context.textTheme.labelSmall?.copyWith(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// The bookmark's domain, stripped of a leading `www.` and any path.
String _displayDomain(String url) {
  final host = Uri.tryParse(url)?.host ?? '';
  if (host.isEmpty) return url;
  return host.startsWith('www.') ? host.substring(4) : host;
}

/// A compact, scan-friendly relative time such as `now`, `5m`, `2h`, or `3d`.
///
/// Older timestamps fall back to a locale-aware short date drawn from the
/// active [MaterialLocalizations], which is always initialized for the app's
/// supported locales.
String _relativeLabel(BuildContext context, DateTime time) {
  final diff = DateTime.now().difference(time);
  if (diff.inMinutes < 1) return 'now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m';
  if (diff.inHours < 24) return '${diff.inHours}h';
  if (diff.inDays < 7) return '${diff.inDays}d';
  return MaterialLocalizations.of(context).formatShortMonthDay(time);
}
