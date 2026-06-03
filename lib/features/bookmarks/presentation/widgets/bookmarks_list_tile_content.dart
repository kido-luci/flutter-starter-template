part of 'bookmarks_list_tile.dart';

class _BookmarkIcon extends StatelessWidget {
  const _BookmarkIcon({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: selected
            ? colorScheme.primary
            : colorScheme.primaryContainer.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xs),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.xs),
          child: Assets.icons.logo.image(
            width: 28,
            height: 28,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}

class _StatusIcon extends StatelessWidget {
  const _StatusIcon({
    required this.icon,
    required this.color,
    this.tooltip,
  });

  final FaIconData icon;
  final Color color;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final child = Container(
      width: 28,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: FaIcon(icon, size: 14, color: color),
    );

    final tooltip = this.tooltip;
    if (tooltip == null) return child;
    return Tooltip(message: tooltip, child: child);
  }
}

class _BookmarkUrl extends StatelessWidget {
  const _BookmarkUrl({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        FaIcon(
          FontAwesomeIcons.link,
          size: 12,
          color: context.colorScheme.primary,
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(
            _displayUrl(url),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _BookmarkTags extends StatelessWidget {
  const _BookmarkTags({required this.tags});

  static const int _maxVisibleTags = 4;

  final List<String> tags;

  @override
  Widget build(BuildContext context) {
    final visibleTags = tags.take(_maxVisibleTags).toList();
    final hiddenCount = tags.length - visibleTags.length;

    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: [
        for (final tag in visibleTags) _BookmarkTag(label: '#$tag'),
        if (hiddenCount > 0) _BookmarkTag(label: '+$hiddenCount'),
      ],
    );
  }
}

class _BookmarkTag extends StatelessWidget {
  const _BookmarkTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: context.colorScheme.secondaryContainer.withValues(alpha: 0.65),
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

String _displayUrl(String url) {
  final uri = Uri.tryParse(url);
  if (uri == null || uri.host.isEmpty) return url;

  final path = uri.path;
  final trimmedPath = path == '/' ? '' : path;
  return '${uri.host}$trimmedPath';
}

class _ReadOnlyMedia extends StatelessWidget {
  const _ReadOnlyMedia({required this.imageUrls});

  static const double _imageSize = 72;
  static const int _maxVisibleImages = 4;

  final List<String> imageUrls;

  @override
  Widget build(BuildContext context) {
    final visibleUrls = imageUrls.take(_maxVisibleImages).toList();
    final hiddenCount = imageUrls.length - visibleUrls.length;

    return SizedBox(
      height: _imageSize,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: visibleUrls.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final path = visibleUrls[index];
          return Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                child: path.startsWith('http')
                    ? AppNetworkImage(
                        imageUrl: path,
                        fit: BoxFit.cover,
                        width: _imageSize,
                        height: _imageSize,
                      )
                    : Image.file(
                        File(path),
                        fit: BoxFit.cover,
                        width: _imageSize,
                        height: _imageSize,
                      ),
              ),
              if (index == visibleUrls.length - 1 && hiddenCount > 0)
                Positioned.fill(
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.48),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Text(
                      '+$hiddenCount',
                      style: context.textTheme.titleSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
