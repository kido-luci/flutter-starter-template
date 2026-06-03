import 'dart:async';

import 'package:app_ui/app_ui.dart';
import 'package:architecture/architecture.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../app/router.dart';
import '../../../../core/extensions/build_context_extensions.dart';
import '../../domain/entities/bookmark.dart';
import '../../domain/services/bookmarks_sync_controller.dart';
import '../bloc/bookmarks_list/bookmarks_list_bloc.dart';
import '../bloc/bookmarks_list/bookmarks_list_state.dart';
import 'bookmark_detail_widgets.dart';
import 'bookmarks_list_master.dart';

class BookmarksListView extends StatefulWidget {
  const BookmarksListView({super.key});

  @override
  State<BookmarksListView> createState() => _BookmarksListViewState();
}

class _BookmarksListViewState extends State<BookmarksListView> {
  static const double _twoPaneMinWidth = 700;

  final _searchController = TextEditingController();
  Timer? _debounce;
  String? _selectedId;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () {
      context.read<BookmarksListBloc>().add(BookmarksListQueryChanged(value));
    });
  }

  void _clearSearch() {
    _debounce?.cancel();
    _searchController.clear();
    context.read<BookmarksListBloc>().add(const BookmarksListQueryChanged(''));
  }

  Future<void> _reload() {
    final bloc = context.read<BookmarksListBloc>();
    final completion = bloc.stream.firstWhere((state) => !state.isLoading);
    bloc.add(const BookmarksListLoadRequested());
    return completion.then((_) {});
  }

  Future<void> _openNew() async {
    final changed = await const BookmarkNewRoute().push<bool>(context);
    if (changed == true && mounted) {
      await _reload();
    }
  }

  Future<void> _openDetail(Bookmark bookmark) async {
    final changed = await BookmarkDetailRoute(bookmark.id).push<bool>(context);
    if (changed == true && mounted) {
      await _reload();
    }
  }

  void _onItemTap(Bookmark bookmark, {required bool twoPane}) {
    if (twoPane) {
      setState(() => _selectedId = bookmark.id);
    } else {
      _openDetail(bookmark);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: context.l10n.bookmarksAppBarTitle,
      padding: EdgeInsets.zero,
      actions: [
        BlocBuilder<BookmarksListBloc, BookmarksListState>(
          buildWhen: (a, b) => a.syncStatus != b.syncStatus,
          builder: (context, state) =>
              _SyncStatusIcon(status: state.syncStatus),
        ),
        BlocBuilder<BookmarksListBloc, BookmarksListState>(
          buildWhen: (a, b) => a.sort != b.sort,
          builder: (context, state) => _SortMenuButton(sort: state.sort),
        ),
      ],
      floatingActionButton: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.sizeOf(context).width < AppBreakpoints.medium
              ? 32 + MediaQuery.paddingOf(context).bottom
              : 0,
        ),
        child: FloatingActionButton(
          heroTag: 'bookmarks-add-bookmark-fab',
          onPressed: _openNew,
          tooltip: context.l10n.bookmarksAddTooltip,
          child: const FaIcon(FontAwesomeIcons.plus),
        ).animateScale(delay: 300.ms),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final twoPane = constraints.maxWidth >= _twoPaneMinWidth;
          return AppListDetailPane(
            twoPaneMinWidth: _twoPaneMinWidth,
            master: BookmarksListMaster(
              searchController: _searchController,
              selectedId: _selectedId,
              twoPane: twoPane,
              onSearchChanged: _onSearchChanged,
              onClearSearch: _clearSearch,
              onReload: _reload,
              onItemTap: (bookmark) => _onItemTap(bookmark, twoPane: twoPane),
              onDeletedSelected: () => setState(() => _selectedId = null),
            ),
            detail: twoPane && _selectedId != null
                ? BookmarkDetailPane(
                    key: ValueKey(_selectedId),
                    id: _selectedId!,
                    onDeleted: () {
                      setState(() => _selectedId = null);
                      _reload().uw();
                    },
                    onEdited: _reload,
                  )
                : null,
            placeholder: const _DetailPlaceholder(),
          );
        },
      ),
    );
  }
}

class _DetailPlaceholder extends StatelessWidget {
  const _DetailPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FaIcon(
            FontAwesomeIcons.bookmark,
            size: AppIconSize.xxxl,
            color: context.colorScheme.outline,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            context.l10n.bookmarksDetailPlaceholder,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _SortMenuButton extends StatelessWidget {
  const _SortMenuButton({required this.sort});

  final BookmarkSort sort;

  String _labelFor(BuildContext context, BookmarkSort value) => switch (value) {
    BookmarkSort.newest => context.l10n.bookmarksSortNewest,
    BookmarkSort.oldest => context.l10n.bookmarksSortOldest,
    BookmarkSort.titleAz => context.l10n.bookmarksSortTitleAz,
  };

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<BookmarkSort>(
      icon: const FaIcon(FontAwesomeIcons.sort),
      tooltip: context.l10n.bookmarksSortTooltip,
      initialValue: sort,
      onSelected: (value) => context.read<BookmarksListBloc>().add(
        BookmarksListSortChanged(value),
      ),
      itemBuilder: (context) => [
        for (final value in BookmarkSort.values)
          CheckedPopupMenuItem<BookmarkSort>(
            value: value,
            checked: value == sort,
            child: Text(_labelFor(context, value)),
          ),
      ],
    );
  }
}

class _SyncStatusIcon extends StatelessWidget {
  const _SyncStatusIcon({required this.status});

  static const double _slotSize = 18;
  static const double _spinnerSize = 16;

  final BookmarksSyncStatus status;

  @override
  Widget build(BuildContext context) {
    return switch (status) {
      BookmarksSyncStatus.syncing => const Padding(
        padding: EdgeInsets.only(right: AppSpacing.md),
        child: SizedBox(
          width: _slotSize,
          height: _slotSize,
          child: Center(
            child: SizedBox(
              width: _spinnerSize,
              height: _spinnerSize,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
      ),
      BookmarksSyncStatus.error => IconButton(
        tooltip: context.l10n.bookmarksSyncFailedRetryTooltip,
        icon: const FaIcon(FontAwesomeIcons.cloudArrowUp),
        onPressed: () => context.read<BookmarksListBloc>().add(
          const BookmarksListSyncRetried(),
        ),
      ),
      BookmarksSyncStatus.idle => const SizedBox.shrink(),
    };
  }
}
