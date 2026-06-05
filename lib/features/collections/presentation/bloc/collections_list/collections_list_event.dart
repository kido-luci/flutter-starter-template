part of 'collections_list_bloc.dart';

sealed class CollectionsListEvent {
  const CollectionsListEvent();
}

final class CollectionsListLoadRequested extends CollectionsListEvent {
  const CollectionsListLoadRequested();
}

final class CollectionsListDeleteRequested extends CollectionsListEvent {
  const CollectionsListDeleteRequested(this.id);

  final String id;
}

final class _CollectionsSyncStatusChanged extends CollectionsListEvent {
  const _CollectionsSyncStatusChanged(this.status);

  final CollectionsSyncStatus status;
}

final class _CollectionsReloadSilentlyRequested extends CollectionsListEvent {
  const _CollectionsReloadSilentlyRequested();
}
