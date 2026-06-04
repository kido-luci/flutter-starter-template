part of 'bookmarks_list_card.dart';

class _BookmarkCardImage extends StatelessWidget {
  const _BookmarkCardImage({required this.imagePath});

  static const double _height = 160;

  final String imagePath;

  @override
  Widget build(BuildContext context) {
    final image = imagePath.startsWith('http')
        ? AppNetworkImage(
            imageUrl: imagePath,
            fit: BoxFit.cover,
            width: double.infinity,
            height: _height,
          )
        : Image.file(
            File(imagePath),
            fit: BoxFit.cover,
            width: double.infinity,
            height: _height,
            errorBuilder: (context, _, _) =>
                const _ImageFallback(height: _height),
          );

    return SizedBox(height: _height, width: double.infinity, child: image);
  }
}

class _ImageFallback extends StatelessWidget {
  const _ImageFallback({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      color: context.colorScheme.surfaceContainerHighest,
      alignment: Alignment.center,
      child: FaIcon(
        FontAwesomeIcons.image,
        size: AppIconSize.lg,
        color: context.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
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
        Flexible(
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
  const _Favicon({required this.url});

  static const double _size = 18;

  final String url;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final host = Uri.tryParse(url)?.host ?? '';
    final fallback = Container(
      width: _size,
      height: _size,
      alignment: Alignment.center,
      color: colorScheme.surfaceContainerHighest,
      child: FaIcon(
        FontAwesomeIcons.globe,
        size: 10,
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
        width: _size,
        height: _size,
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
