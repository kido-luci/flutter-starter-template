import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../app/di/injection.dart';
import '../../../../app/router.dart';
import '../../../../core/extensions/build_context_extensions.dart';
import '../../../../shared/domain/bookmark_stats.dart';
import '../../../../shared/presentation/collection_visuals.dart';
import '../bloc/collection_detail/collection_detail_cubit.dart';
import '../bloc/collection_detail/collection_detail_state.dart';
import '../widgets/add_bookmarks_sheet.dart';

class CollectionDetailScreen extends StatelessWidget {
  const CollectionDetailScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<CollectionDetailCubit>()..load(id),
      child: _CollectionDetailView(id: id),
    );
  }
}

class _CollectionDetailView extends StatelessWidget {
  const _CollectionDetailView({required this.id});

  final String id;

  Future<void> _confirmDelete(BuildContext context, String name) async {
    final l10n = context.l10n;
    final confirmed = await AppConfirmDialog.show(
      context,
      title: l10n.collectionDeleteDialogTitle,
      message: l10n.collectionDeleteDialogMessage(name),
      confirmLabel: l10n.collectionDeleteAction,
      cancelLabel: l10n.commonCancel,
    );
    if (confirmed && context.mounted) {
      await context.read<CollectionDetailCubit>().delete();
    }
  }

  Future<void> _addBookmarks(BuildContext context) async {
    final cubit = context.read<CollectionDetailCubit>();
    final selected = await AddBookmarksSheet.show(
      context,
      candidates: cubit.state.candidates,
    );
    if (selected != null && selected.isNotEmpty) {
      await cubit.addBookmarks(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CollectionDetailCubit, CollectionDetailState>(
      listener: (context, state) {
        if (state.deleted) Navigator.of(context).pop();
        if (state.failure != null) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(state.failure!.message)));
        }
      },
      builder: (context, state) {
        final collection = state.collection;
        return AppScaffold(
          title: collection?.name ?? context.l10n.collectionsTitle,
          padding: EdgeInsets.zero,
          isLoading: state.isLoading && collection == null,
          actions: collection == null
              ? null
              : [
                  IconButton(
                    icon: const FaIcon(FontAwesomeIcons.penToSquare),
                    iconSize: AppIconSize.sm,
                    tooltip: context.l10n.collectionsEditTitle,
                    onPressed: () =>
                        CollectionEditRoute(id).push<void>(context),
                  ),
                  IconButton(
                    icon: const FaIcon(FontAwesomeIcons.trash),
                    iconSize: AppIconSize.sm,
                    tooltip: context.l10n.collectionDeleteAction,
                    onPressed: () => _confirmDelete(context, collection.name),
                  ),
                ],
          floatingActionButton: collection == null
              ? null
              : FloatingActionButton.extended(
                  heroTag: 'collection-add-bookmarks-fab',
                  onPressed: () => _addBookmarks(context),
                  icon: const FaIcon(FontAwesomeIcons.plus),
                  label: Text(context.l10n.collectionAddBookmarks),
                ),
          body: collection == null
              ? const SizedBox.shrink()
              : _MembersList(
                  color: collection.color,
                  icon: collection.icon,
                  itemCount: collection.itemCount,
                  members: state.members,
                ),
        );
      },
    );
  }
}

class _MembersList extends StatelessWidget {
  const _MembersList({
    required this.color,
    required this.icon,
    required this.itemCount,
    required this.members,
  });

  final int color;
  final String icon;
  final int itemCount;
  final List<BookmarkSummary> members;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Container(
            margin: const EdgeInsets.all(AppSpacing.lg),
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: collectionGradientFor(color),
              ),
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Row(
              children: [
                FaIcon(
                  collectionIconFor(icon),
                  color: Colors.white,
                  size: AppIconSize.lg,
                ),
                const SizedBox(width: AppSpacing.md),
                Text(
                  context.l10n.collectionItemsCount(itemCount),
                  style: context.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (members.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: AppEmptyView(
              icon: FontAwesomeIcons.bookmark,
              message: context.l10n.collectionEmptyBookmarks,
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              0,
              AppSpacing.lg,
              96,
            ),
            sliver: SliverList.builder(
              itemCount: members.length,
              itemBuilder: (context, index) {
                final bookmark = members[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: ListTile(
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
                    trailing: IconButton(
                      icon: const FaIcon(FontAwesomeIcons.xmark),
                      iconSize: AppIconSize.sm,
                      tooltip: context.l10n.collectionRemoveBookmark,
                      onPressed: () => context
                          .read<CollectionDetailCubit>()
                          .removeBookmark(bookmark.id),
                    ),
                    onTap: () =>
                        BookmarkDetailRoute(bookmark.id).push<void>(context),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
