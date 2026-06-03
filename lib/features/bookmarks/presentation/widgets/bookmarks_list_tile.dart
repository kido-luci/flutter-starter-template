import 'dart:io';

import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../core/extensions/build_context_extensions.dart';
import '../../../../gen/assets.gen.dart';
import '../../domain/entities/bookmark.dart';
import '../bloc/bookmarks_list/bookmarks_list_bloc.dart';
part 'bookmarks_list_tile_content.dart';
part 'bookmarks_list_tile_actions.dart';

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
