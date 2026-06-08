part of 'bookmarks_list_card.dart';

enum _CardAction { share, delete }

/// Shows the share/delete actions for [bookmark] in a bottom sheet.
///
/// Delete is confirmed with a dialog before the bloc event is dispatched.
Future<void> _showCardMenu(BuildContext context, Bookmark bookmark) async {
  final l10n = context.l10n;
  final colorScheme = context.colorScheme;
  final bloc = context.read<BookmarksListBloc>();

  final action = await showModalBottomSheet<_CardAction>(
    context: context,
    builder: (sheetContext) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const FaIcon(FontAwesomeIcons.shareNodes),
            title: Text(l10n.commonShare),
            onTap: () => Navigator.pop(sheetContext, _CardAction.share),
          ),
          ListTile(
            leading: FaIcon(FontAwesomeIcons.trash, color: colorScheme.error),
            title: Text(
              l10n.commonDelete,
              style: TextStyle(color: colorScheme.error),
            ),
            onTap: () => Navigator.pop(sheetContext, _CardAction.delete),
          ),
        ],
      ),
    ),
  );

  if (action == null || !context.mounted) return;

  switch (action) {
    case _CardAction.share:
      bloc.add(BookmarksListShareRequested(bookmark));
    case _CardAction.delete:
      final shouldDelete = await _confirmDelete(context);
      if (!shouldDelete) return;
      bloc.add(BookmarksListDeleteRequested(bookmark.id));
  }
}

Future<bool> _confirmDelete(BuildContext context) async {
  final l10n = context.l10n;
  return AppConfirmDialog.show(
    context,
    title: l10n.bookmarkDeleteDialogTitle,
    message: l10n.bookmarkDeleteDialogBody,
    confirmLabel: l10n.commonDelete,
    cancelLabel: l10n.commonCancel,
  );
}
