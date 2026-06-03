import 'dart:io';

import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../core/extensions/build_context_extensions.dart';
import '../../../../gen/assets.gen.dart';
import '../../domain/entities/bookmark.dart';
import '../bloc/bookmarks_list/bookmarks_list_bloc.dart';

class BookmarksListTile extends StatelessWidget {
  const BookmarksListTile({
    super.key,
    required this.bookmark,
    required this.index,
    required this.selected,
    required this.onTap,
    required this.onDeleteSelectedBookmark,
  });

  final Bookmark bookmark;
  final int index;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onDeleteSelectedBookmark;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final selectedColor = colorScheme.secondaryContainer.withValues(
      alpha: context.isDark ? 0.45 : 0.6,
    );
    final defaultColor = colorScheme.surfaceContainerHighest.withValues(
      alpha: context.isDark ? 0.28 : 0.42,
    );
    final borderColor = selected
        ? colorScheme.primary.withValues(alpha: 0.6)
        : colorScheme.outlineVariant.withValues(alpha: 0.35);

    return AppSlidable(
      key: ValueKey(bookmark.id),
      groupTag: 'bookmarks',
      endActions: [
        AppSlidableAction.delete(
          borderRadius: const BorderRadius.horizontal(
            right: Radius.circular(AppRadius.lg),
          ),
          onPressed: (_) async {
            final shouldDelete = await _confirmDelete(context, bookmark.title);
            if (!shouldDelete || !context.mounted) return;
            if (selected) onDeleteSelectedBookmark();
            context.read<BookmarksListBloc>().add(
              BookmarksListDeleteRequested(bookmark.id),
            );
          },
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.xs,
        ),
        child: Material(
          clipBehavior: Clip.antiAlias,
          color: selected ? selectedColor : defaultColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            side: BorderSide(color: borderColor),
          ),
          child: InkWell(
            onTap: onTap,
            onLongPress: () => _showItemMenu(context, bookmark),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _BookmarkIcon(selected: selected),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                bookmark.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: context.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: selected
                                      ? colorScheme.onSecondaryContainer
                                      : colorScheme.onSurface,
                                ),
                              ),
                            ),
                            if (bookmark.isPendingSync) ...[
                              const SizedBox(width: AppSpacing.sm),
                              _StatusIcon(
                                icon: FontAwesomeIcons.cloudArrowUp,
                                color: colorScheme.onSurfaceVariant,
                                tooltip: context.l10n.bookmarksNotYetSynced,
                              ),
                            ],
                            if (selected) ...[
                              const SizedBox(width: AppSpacing.sm),
                              _StatusIcon(
                                icon: FontAwesomeIcons.check,
                                color: colorScheme.primary,
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        _BookmarkUrl(url: bookmark.url),
                        if (bookmark.description.isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            bookmark.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: context.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                        if (bookmark.tags.isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.sm),
                          _BookmarkTags(tags: bookmark.tags),
                        ],
                        if (bookmark.imageUrls.isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.md),
                          _ReadOnlyMedia(imageUrls: bookmark.imageUrls),
                        ],
                        const SizedBox(height: AppSpacing.md),
                        AppLinkPreview(
                          url: bookmark.url,
                          onTap: (_) => onTap(),
                          minWidth: double.infinity,
                          maxWidth: double.infinity,
                          maxTitleLines: 1,
                          maxDescriptionLines: 2,
                          enableAnimation: false,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ).animateStaggerItem(index);
  }
}

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

Future<bool> _confirmDelete(BuildContext context, String title) async {
  final l10n = context.l10n;
  return await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l10n.bookmarkDeleteDialogTitle),
          content: Text(l10n.bookmarkDeleteDialogMessage(title)),
          actions: [
            AppButton(
              label: l10n.commonCancel,
              variant: AppButtonVariant.text,
              onPressed: () => Navigator.of(ctx).pop(false),
            ),
            AppButton(
              label: l10n.commonDelete,
              variant: AppButtonVariant.tonal,
              onPressed: () => Navigator.of(ctx).pop(true),
            ),
          ],
        ),
      ) ??
      false;
}

Future<void> _showItemMenu(BuildContext context, Bookmark bookmark) async {
  final l10n = context.l10n;
  final result = await showModalBottomSheet<String>(
    context: context,
    builder: (sheetContext) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const FaIcon(FontAwesomeIcons.shareNodes),
            title: Text(l10n.commonShare),
            onTap: () => Navigator.pop(sheetContext, 'share'),
          ),
        ],
      ),
    ),
  );
  if (result != 'share' || !context.mounted) return;
  context.read<BookmarksListBloc>().add(BookmarksListShareRequested(bookmark));
}
