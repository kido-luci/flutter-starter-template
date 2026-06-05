import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../app/di/injection.dart';
import '../../../../core/extensions/build_context_extensions.dart';
import '../../../../shared/presentation/collection_visuals.dart';
import '../bloc/add_to_collection/add_to_collection_cubit.dart';
import '../bloc/add_to_collection/add_to_collection_state.dart';

/// Bottom sheet that toggles a single bookmark's membership across the user's
/// collections.
///
/// This is the collections feature's capability surfaced inside the bookmarks
/// detail screen — the single-consumer exception in the architecture rules.
class AddToCollectionSheet extends StatelessWidget {
  const AddToCollectionSheet({super.key, required this.bookmarkId});

  final String bookmarkId;

  static Future<void> show(BuildContext context, {required String bookmarkId}) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => AddToCollectionSheet(bookmarkId: bookmarkId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AddToCollectionCubit>()..load(bookmarkId),
      child: _AddToCollectionBody(bookmarkId: bookmarkId),
    );
  }
}

class _AddToCollectionBody extends StatelessWidget {
  const _AddToCollectionBody({required this.bookmarkId});

  final String bookmarkId;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocBuilder<AddToCollectionCubit, AddToCollectionState>(
        builder: (context, state) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    context.l10n.addToCollectionTitle,
                    style: context.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              if (state.isLoading)
                const Padding(
                  padding: EdgeInsets.all(AppSpacing.xxl),
                  child: AppLoading(),
                )
              else if (state.failure != null && state.collections.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.xxl),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        context.l10n.collectionsLoadError,
                        textAlign: TextAlign.center,
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      AppButton(
                        label: context.l10n.commonRetry,
                        variant: AppButtonVariant.tonal,
                        onPressed: () => context
                            .read<AddToCollectionCubit>()
                            .load(bookmarkId),
                      ),
                    ],
                  ),
                )
              else if (state.collections.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.xxl),
                  child: Text(
                    context.l10n.addToCollectionEmpty,
                    textAlign: TextAlign.center,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                )
              else
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: state.collections.length,
                    itemBuilder: (context, index) {
                      final collection = state.collections[index];
                      final isMember = state.memberOf.contains(collection.id);
                      final isBusy = state.busyIds.contains(collection.id);
                      return ListTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: collectionGradientFor(collection.color),
                            ),
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                          child: FaIcon(
                            collectionIconFor(collection.icon),
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                        title: Text(
                          collection.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: isBusy
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : FaIcon(
                                isMember
                                    ? FontAwesomeIcons.solidCircleCheck
                                    : FontAwesomeIcons.circlePlus,
                                color: isMember
                                    ? context.colorScheme.primary
                                    : context.colorScheme.onSurfaceVariant,
                              ),
                        onTap: isBusy
                            ? null
                            : () => context.read<AddToCollectionCubit>().toggle(
                                collection.id,
                                bookmarkId,
                              ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: AppSpacing.lg),
            ],
          );
        },
      ),
    );
  }
}
