import 'dart:async';

import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../app/router.dart';
import '../../../../core/extensions/build_context_extensions.dart';
import '../../domain/entities/bookmark.dart';
import '../../domain/services/bookmarks_sync_controller.dart';
import '../bloc/bookmarks_list/bookmarks_list_bloc.dart';
import '../bloc/bookmarks_list/bookmarks_list_state.dart';
import 'bookmarks_list_master.dart';

class BookmarksListView extends StatefulWidget {
  const BookmarksListView({super.key});

  @override
  State<BookmarksListView> createState() => _BookmarksListViewState();
}

class _BookmarksListViewState extends State<BookmarksListView> {
  final _searchController = TextEditingController();
  Timer? _debounce;
  BookmarkTab _activeTab = BookmarkTab.all;

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
      body: BookmarksListMaster(
        searchController: _searchController,
        activeTab: _activeTab,
        onSearchChanged: _onSearchChanged,
        onClearSearch: _clearSearch,
        onTabChanged: (tab) => setState(() => _activeTab = tab),
        onReload: _reload,
        onItemTap: _openDetail,
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

  FaIconData _iconFor(BookmarkSort value) => switch (value) {
    BookmarkSort.newest => FontAwesomeIcons.calendarDay,
    BookmarkSort.oldest => FontAwesomeIcons.calendar,
    BookmarkSort.titleAz => FontAwesomeIcons.arrowDownAZ,
  };

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final showLabel = MediaQuery.sizeOf(context).width >= AppBreakpoints.medium;

    return PopupMenuButton<BookmarkSort>(
      padding: EdgeInsets.zero,
      tooltip: context.l10n.bookmarksSortTooltip,
      initialValue: sort,
      color: colorScheme.surface,
      elevation: 8,
      shadowColor: colorScheme.shadow.withValues(alpha: 0.18),
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      offset: const Offset(0, AppSpacing.sm),
      position: PopupMenuPosition.under,
      onSelected: (value) => context.read<BookmarksListBloc>().add(
        BookmarksListSortChanged(value),
      ),
      child: Semantics(
        button: true,
        label: context.l10n.bookmarksSortTooltip,
        child: Container(
          height: 56,
          width: showLabel ? 116 : 56,
          margin: const EdgeInsets.only(right: AppSpacing.sm),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(AppRadius.sm),
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FaIcon(
                FontAwesomeIcons.filter,
                size: 20,
                color: colorScheme.primary,
              ),
              if (showLabel) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  context.l10n.bookmarksSortMenuLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.labelLarge?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      itemBuilder: (context) => [
        for (final value in BookmarkSort.values)
          PopupMenuItem<BookmarkSort>(
            value: value,
            padding: EdgeInsets.zero,
            child: _SortMenuItem(
              icon: _iconFor(value),
              label: _labelFor(context, value),
              selected: value == sort,
            ),
          ),
      ],
    );
  }
}

class _SortMenuItem extends StatelessWidget {
  const _SortMenuItem({
    required this.icon,
    required this.label,
    required this.selected,
  });

  final FaIconData icon;
  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Container(
      width: 220,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      color: selected
          ? colorScheme.primaryContainer.withValues(alpha: 0.38)
          : Colors.transparent,
      child: Row(
        children: [
          SizedBox(
            width: 22,
            child: FaIcon(
              icon,
              size: 16,
              color: selected ? colorScheme.primary : colorScheme.onSurface,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.titleMedium?.copyWith(
                color: selected ? colorScheme.primary : colorScheme.onSurface,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                letterSpacing: 0,
              ),
            ),
          ),
        ],
      ),
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
