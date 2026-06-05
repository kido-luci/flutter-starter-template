import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../core/extensions/build_context_extensions.dart';
import '../../../../shared/domain/bookmark_stats.dart';

/// Multi-select sheet for adding bookmarks to a collection.
///
/// Returns the set of selected bookmark ids, or null if dismissed.
class AddBookmarksSheet extends StatefulWidget {
  const AddBookmarksSheet({super.key, required this.candidates});

  final List<BookmarkSummary> candidates;

  static Future<Set<String>?> show(
    BuildContext context, {
    required List<BookmarkSummary> candidates,
  }) {
    return showModalBottomSheet<Set<String>>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => AddBookmarksSheet(candidates: candidates),
    );
  }

  @override
  State<AddBookmarksSheet> createState() => _AddBookmarksSheetState();
}

class _AddBookmarksSheetState extends State<AddBookmarksSheet> {
  final _selected = <String>{};

  @override
  Widget build(BuildContext context) {
    if (widget.candidates.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Text(
          context.l10n.collectionPickerEmpty,
          textAlign: TextAlign.center,
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Text(
              context.l10n.collectionAddBookmarks,
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: widget.candidates.length,
              itemBuilder: (context, index) {
                final bookmark = widget.candidates[index];
                final checked = _selected.contains(bookmark.id);
                return CheckboxListTile(
                  value: checked,
                  title: Text(
                    bookmark.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    bookmark.url,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onChanged: (value) => setState(() {
                    if (value ?? false) {
                      _selected.add(bookmark.id);
                    } else {
                      _selected.remove(bookmark.id);
                    }
                  }),
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              0,
              AppSpacing.lg,
              AppSpacing.lg,
            ),
            child: AppButton(
              label: context.l10n.collectionPickerAddCount(_selected.length),
              icon: FontAwesomeIcons.plus,
              expand: true,
              onPressed: _selected.isEmpty
                  ? null
                  : () => Navigator.of(context).pop(_selected),
            ),
          ),
        ],
      ),
    );
  }
}
