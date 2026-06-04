import 'dart:io';

import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

import '../../../../core/extensions/build_context_extensions.dart';
import '../../domain/entities/bookmark.dart';
import '../bloc/bookmarks_list/bookmarks_list_bloc.dart';

part 'bookmarks_list_card_content.dart';
part 'bookmarks_list_card_actions.dart';

/// A bento-style bookmark card used in the responsive bookmarks grid.
///
/// Shows an optional hero image, a domain/meta row, the title, an optional
/// description, and tag chips. Tapping opens the detail screen; long-pressing
/// (or the meta-row menu button) opens the share/delete actions.
class BookmarkCard extends StatelessWidget {
  const BookmarkCard({
    super.key,
    required this.bookmark,
    required this.index,
    required this.onTap,
  });

  final Bookmark bookmark;
  final int index;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final hasImage = bookmark.imageUrls.isNotEmpty;
    final shadowColor = colorScheme.shadow.withValues(
      alpha: context.isDark ? 0.35 : 0.08,
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        clipBehavior: Clip.antiAlias,
        color: colorScheme.surfaceContainerLowest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.4),
          ),
        ),
        child: InkWell(
          onTap: onTap,
          onLongPress: () => _showCardMenu(context, bookmark),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (hasImage)
                _BookmarkCardImage(imagePath: bookmark.imageUrls.first),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _BookmarkCardMeta(bookmark: bookmark),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      bookmark.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    if (bookmark.description.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        bookmark.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                    ],
                    if (bookmark.tags.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.md),
                      _BookmarkCardTags(tags: bookmark.tags),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ).animateStaggerItem(index);
  }
}
