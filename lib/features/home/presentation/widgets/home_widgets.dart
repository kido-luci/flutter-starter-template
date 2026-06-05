import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../app/router.dart';
import '../../../../core/extensions/build_context_extensions.dart';
import '../../../../shared/domain/bookmark_stats.dart';
import '../../../../shared/domain/collections.dart';
import '../../../../shared/presentation/collection_visuals.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_state.dart';
part 'home_welcome.dart';
part 'home_recent.dart';

/// Entry widget for the Home feature dashboard.
class HomeBody extends StatefulWidget {
  /// Creates the dashboard body used by the home screen.
  const HomeBody({super.key});

  @override
  State<HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<HomeBody> {
  static const double _contentMaxWidth = 720;
  static const double _bottomInset = 112;

  final TextEditingController _searchController = TextEditingController();
  String _selectedFilterId = 'all';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: context.l10n.homeAppBarTitle,
      padding: EdgeInsets.zero,
      backgroundColor: context.colorScheme.surfaceContainerLow,
      floatingActionButton: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.sizeOf(context).width < AppBreakpoints.medium
              ? 32 + MediaQuery.paddingOf(context).bottom
              : 0,
        ),
        child: FloatingActionButton(
          heroTag: 'home-add-bookmark-fab',
          onPressed: () => const BookmarkNewRoute().push<void>(context),
          tooltip: context.l10n.bookmarksAddTooltip,
          child: const FaIcon(FontAwesomeIcons.plus),
        ).animateScale(delay: 500.ms),
      ),
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          return LayoutBuilder(
            builder: (context, constraints) {
              final filters = _filters(context);
              final filteredItems = _filterItems(state.recentItems, filters);
              final hasActiveFilters =
                  _searchController.text.trim().isNotEmpty ||
                  _selectedFilterId != 'all';

              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  AppSpacing.lg,
                  AppSpacing.xl,
                  _bottomInset,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: _contentMaxWidth,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _SearchSection(
                          controller: _searchController,
                          onChanged: (_) => setState(() {}),
                        ).animateFadeIn(delay: 100.ms),
                        const SizedBox(height: AppSpacing.md),
                        _QuickActions(
                          onAdd: () =>
                              const BookmarkNewRoute().push<void>(context),
                          onLibrary: () =>
                              const BookmarksListRoute().push<void>(context),
                          onTags: () =>
                              const BookmarksListRoute().push<void>(context),
                        ).animateSlideUp(delay: 160.ms),
                        const SizedBox(height: AppSpacing.md),
                        _FilterChips(
                          filters: filters,
                          selectedId: _selectedFilterId,
                          onSelected: (filter) {
                            setState(() => _selectedFilterId = filter.id);
                          },
                        ).animateFadeIn(delay: 220.ms),
                        const SizedBox(height: AppSpacing.xl),
                        _SuggestedBookmarksSection(
                          items: filteredItems,
                        ).animateFadeIn(delay: 320.ms),
                        const SizedBox(height: AppSpacing.xl),
                        _FeaturedCollectionsSection(
                          collections: state.collections,
                        ).animateFadeIn(delay: 380.ms),
                        const SizedBox(height: AppSpacing.xl),
                        _RecentBookmarksSection(
                          recentItems: filteredItems,
                          isEmpty: state.totalBookmarks == 0,
                          hasMatches:
                              !hasActiveFilters || filteredItems.isNotEmpty,
                          animationDelay: 440.ms,
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        _WeeklyDigestPanel(
                          recentCount: state.recentBookmarks,
                          onPressed: () =>
                              const BookmarksListRoute().push<void>(context),
                        ).animateSlideUp(delay: 520.ms),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  List<BookmarkSummary> _filterItems(
    List<BookmarkSummary> items,
    List<_HomeFilter> filters,
  ) {
    final query = _searchController.text.trim().toLowerCase();
    final selectedFilter = filters.firstWhere(
      (filter) => filter.id == _selectedFilterId,
      orElse: () => filters.first,
    );

    return items.where((bookmark) {
      final searchable = [
        bookmark.title,
        bookmark.url,
        bookmark.description,
        ...bookmark.tags,
      ].join(' ').toLowerCase();
      final matchesSearch = query.isEmpty || searchable.contains(query);
      final matchesFilter =
          selectedFilter.id == 'all' ||
          selectedFilter.keywords.any(searchable.contains);
      return matchesSearch && matchesFilter;
    }).toList();
  }

  List<_HomeFilter> _filters(BuildContext context) => [
    _HomeFilter(
      id: 'all',
      label: context.l10n.homeFilterAll,
      keywords: const [],
    ),
    _HomeFilter(
      id: 'design',
      label: context.l10n.homeFilterDesign,
      keywords: const ['design', 'ui', 'ux', 'figma'],
    ),
    _HomeFilter(
      id: 'articles',
      label: context.l10n.homeFilterArticles,
      keywords: const ['article', 'blog', 'medium', 'read'],
    ),
    _HomeFilter(
      id: 'inspiration',
      label: context.l10n.homeFilterInspiration,
      keywords: const ['inspiration', 'idea', 'creative', 'gallery'],
    ),
    _HomeFilter(
      id: 'tools',
      label: context.l10n.homeFilterTools,
      keywords: const ['tool', 'app', 'extension', 'package'],
    ),
  ];
}

class _HomeFilter {
  const _HomeFilter({
    required this.id,
    required this.label,
    required this.keywords,
  });

  final String id;
  final String label;
  final List<String> keywords;
}
