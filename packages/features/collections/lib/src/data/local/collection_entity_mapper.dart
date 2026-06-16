import 'package:database/database.dart';
import 'package:sync/sync.dart';

import '../../domain/entities/collection.dart';

/// Maps the persistence [CollectionEntity] to/from the domain [Collection].
///
/// Lives in the feature data layer (not on the entity) so the dependency
/// direction stays `feature → database` and the entity stays domain-free.
extension CollectionEntityMapper on CollectionEntity {
  Collection toDomain() => Collection(
    id: uuid,
    name: name,
    icon: icon,
    color: color,
    bookmarkIds: List.unmodifiable(bookmarkIds),
    createdAt: createdAt,
    updatedAt: updatedAt,
    isPendingSync: syncState.isPending,
    isConflicted: syncState == SyncState.conflicted,
    isFailed: syncState == SyncState.failed,
  );

  /// Mutates this entity from a [CollectionInput] for create/update flows.
  /// Bumps `updatedAt`; leaves `createdAt` alone so updates preserve it.
  void applyInput(CollectionInput input, {required DateTime now}) {
    name = input.name;
    icon = input.icon;
    color = input.color;
    bookmarkIds = List.of(input.bookmarkIds);
    updatedAt = now;
  }
}
