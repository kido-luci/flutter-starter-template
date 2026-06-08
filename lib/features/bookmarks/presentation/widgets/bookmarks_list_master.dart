import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../core/extensions/build_context_extensions.dart';
import '../../../collections/presentation/widgets/collections_list_view.dart';
import '../../domain/entities/bookmark.dart';
import '../bloc/bookmarks_list/bookmarks_list_bloc.dart';
import '../bloc/bookmarks_list/bookmarks_list_state.dart';
import 'bookmark_failure_messages.dart';
import 'bookmarks_list_card.dart';

/// The bookmark browsing tabs shown above the grid.
///
/// [collections] embeds the collections feature's self-contained list view (a
/// single-consumer capability); [recent] filters to bookmarks created within
/// the last week.
enum BookmarkTab { all, recent, collections }

/// How recent a bookmark must be to appear under [BookmarkTab.recent].
const Duration _recentWindow = Duration(days: 7);

class BookmarksListMaster extends StatelessWidget {
  const BookmarksListMaster({
    super.key,
    required this.searchController,
    required this.activeTab,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.onTabChanged,
    required this.onReload,
    required this.onItemTap,
  });

  final TextEditingController searchController;
  final BookmarkTab activeTab;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;
  final ValueChanged<BookmarkTab> onTabChanged;
  final Future<void> Function() onReload;
  final ValueChanged<Bookmark> onItemTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _BookmarksSearchField(
          controller: searchController,
          onChanged: onSearchChanged,
          onClear: onClearSearch,
        ),
        _BookmarkFilterTabs(activeTab: activeTab, onTabChanged: onTabChanged),
        Expanded(
          child: BlocBuilder<BookmarksListBloc, BookmarksListState>(
            builder: (context, state) {
              // The collections tab owns its own data/state, so it short-
              // circuits before the bookmark loading/error guards below.
              if (activeTab == BookmarkTab.collections) {
                return const CollectionsListView();
              }

              if (state.isLoading && state.items.isEmpty) {
                return const AppSkeletonList(hasLeading: false);
              }
              if (state.failure != null && state.items.isEmpty) {
                return AppErrorView(
                  message: bookmarkFailureMessage(context, state.failure!),
                  onRetry: () => context.read<BookmarksListBloc>().add(
                    const BookmarksListLoadRequested(),
                  ),
                );
              }

              final visible = _itemsForTab(state.visibleItems, activeTab);
              if (visible.isEmpty) {
                return _BookmarksEmptyState(
                  tab: activeTab,
                  query: state.query,
                );
              }

              return _BookmarksGrid(
                items: visible,
                onReload: onReload,
                onItemTap: onItemTap,
              );
            },
          ),
        ),
      ],
    );
  }

  List<Bookmark> _itemsForTab(List<Bookmark> items, BookmarkTab tab) {
    if (tab != BookmarkTab.recent) return items;
    final cutoff = DateTime.now().subtract(_recentWindow);
    return items.where((b) => b.createdAt.isAfter(cutoff)).toList();
  }
}

/// A responsive masonry grid: a single lazy column on phones and 2-3
/// height-balanced columns on wider screens.
///
/// Backed by [MasonryGridView.builder] so cards are built lazily and each is
/// placed in the currently shortest column, keeping variable-height bento
/// cards balanced.
class _BookmarksGrid extends StatelessWidget {
  const _BookmarksGrid({
    required this.items,
    required this.onReload,
    required this.onItemTap,
  });

  static const EdgeInsets _padding = EdgeInsets.fromLTRB(
    AppSpacing.lg,
    AppSpacing.sm,
    AppSpacing.lg,
    96,
  );

  final List<Bookmark> items;
  final Future<void> Function() onReload;
  final ValueChanged<Bookmark> onItemTap;

  int _columnsFor(double width) {
    if (width >= AppBreakpoints.expanded) return 3;
    if (width >= AppBreakpoints.medium) return 2;
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = _columnsFor(constraints.maxWidth);
        return RefreshIndicator(
          onRefresh: onReload,
          child: MasonryGridView.builder(
            padding: _padding,
            physics: const AlwaysScrollableScrollPhysics(),
            gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
            ),
            mainAxisSpacing: AppSpacing.md,
            crossAxisSpacing: AppSpacing.md,
            itemCount: items.length,
            itemBuilder: (context, index) => BookmarkCard(
              bookmark: items[index],
              index: index,
              onTap: () => onItemTap(items[index]),
            ),
          ),
        );
      },
    );
  }
}

class _BookmarkFilterTabs extends StatelessWidget {
  const _BookmarkFilterTabs({
    required this.activeTab,
    required this.onTabChanged,
  });

  final BookmarkTab activeTab;
  final ValueChanged<BookmarkTab> onTabChanged;

  String _labelFor(BuildContext context, BookmarkTab tab) => switch (tab) {
    BookmarkTab.all => context.l10n.bookmarksTabAll,
    BookmarkTab.recent => context.l10n.bookmarksTabRecent,
    BookmarkTab.collections => context.l10n.bookmarksTabCollections,
  };

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        children: [
          for (final tab in BookmarkTab.values) ...[
            _FilterChip(
              label: _labelFor(context, tab),
              selected: tab == activeTab,
              onTap: () => onTabChanged(tab),
            ),
            const SizedBox(width: AppSpacing.sm),
          ],
        ],
      ),
    ).animateSlideDown(duration: AppDurations.medium);
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return Material(
      color: selected
          ? colorScheme.primaryContainer
          : colorScheme.surfaceContainerHigh,
      shape: const StadiumBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          child: Center(
            child: Text(
              label,
              style: context.textTheme.labelLarge?.copyWith(
                color: selected
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BookmarksSearchField extends StatelessWidget {
  const _BookmarksSearchField({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: AppTextField(
        controller: controller,
        hint: context.l10n.bookmarksSearchHint,
        prefixIcon: FontAwesomeIcons.magnifyingGlass,
        onChanged: onChanged,
        suffix: ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (context, value, _) {
            if (value.text.isEmpty) return const SizedBox.shrink();
            return IconButton(
              icon: const FaIcon(FontAwesomeIcons.xmark),
              tooltip: context.l10n.bookmarksSearchClear,
              onPressed: onClear,
            );
          },
        ),
      ),
    ).animateSlideDown(duration: AppDurations.medium);
  }
}

class _BookmarksEmptyState extends StatelessWidget {
  const _BookmarksEmptyState({required this.tab, required this.query});

  final BookmarkTab tab;
  final String query;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isFiltered = query.trim().isNotEmpty;

    if (isFiltered) {
      return AppEmptyView(
        icon: FontAwesomeIcons.magnifyingGlassMinus,
        title: l10n.bookmarksNoMatchesTitle,
        message: l10n.bookmarksNoMatchesMessage,
      );
    }

    if (tab == BookmarkTab.recent) {
      return AppEmptyView(
        icon: FontAwesomeIcons.clock,
        title: l10n.bookmarksRecentEmptyTitle,
        message: l10n.bookmarksRecentEmptyMessage,
      );
    }

    return AppEmptyView(
      icon: FontAwesomeIcons.bookmark,
      title: l10n.bookmarksEmptyTitle,
      message: l10n.bookmarksEmptyMessage,
    );
  }
}
