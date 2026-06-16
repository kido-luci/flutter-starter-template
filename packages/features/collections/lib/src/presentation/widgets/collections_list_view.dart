import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:localization/localization.dart';
import 'package:shared_contracts/shared_contracts.dart';

import '../../locator.dart';
import '../bloc/collections_list/collections_list_bloc.dart';
import '../bloc/collections_list/collections_list_state.dart';
import '../collections_routes.dart';
import 'collection_card.dart';

/// Self-contained collections grid: provides its own [CollectionsListBloc],
/// handles loading/error/empty states, and renders a responsive grid of
/// [CollectionCard]s. Reused by the standalone screen and the bookmarks
/// "Collections" tab.
class CollectionsListView extends StatelessWidget {
  const CollectionsListView({super.key, this.padding});

  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<CollectionsListBloc>()
            ..add(const CollectionsListLoadRequested()),
      child: _CollectionsListBody(padding: padding),
    );
  }
}

class _CollectionsListBody extends StatelessWidget {
  const _CollectionsListBody({this.padding});

  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CollectionsListBloc, CollectionsListState>(
      builder: (context, state) {
        if (state.isLoading && state.items.isEmpty) {
          return const Center(child: AppLoading());
        }
        if (state.failure != null && state.items.isEmpty) {
          return AppErrorView(
            message: context.l10n.collectionsLoadError,
            onRetry: () => context.read<CollectionsListBloc>().add(
              const CollectionsListLoadRequested(),
            ),
          );
        }
        if (state.items.isEmpty) {
          return AppEmptyView(
            icon: FontAwesomeIcons.layerGroup,
            title: context.l10n.collectionsEmptyTitle,
            message: context.l10n.collectionsEmptyMessage,
            action: AppButton(
              label: context.l10n.collectionsCreate,
              icon: FontAwesomeIcons.plus,
              onPressed: () => _createCollection(context),
            ),
          );
        }

        return GridView.builder(
          padding:
              padding ??
              const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.sm,
                AppSpacing.lg,
                96,
              ),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 220,
            mainAxisExtent: 116,
            crossAxisSpacing: AppSpacing.md,
            mainAxisSpacing: AppSpacing.md,
          ),
          itemCount: state.items.length,
          itemBuilder: (context, index) {
            final collection = state.items[index];
            final summary = CollectionSummary(
              id: collection.id,
              name: collection.name,
              icon: collection.icon,
              color: collection.color,
              itemCount: collection.itemCount,
            );
            return CollectionCard(
              collection: summary,
              width: double.infinity,
              onTap: () =>
                  context.push<void>(CollectionsRoutes.detail(collection.id)),
            ).animateStaggerItem(index);
          },
        );
      },
    );
  }

  Future<void> _createCollection(BuildContext context) =>
      context.push<void>(CollectionsRoutes.create);
}
