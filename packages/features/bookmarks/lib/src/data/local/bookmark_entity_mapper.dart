import 'package:database/database.dart';
import 'package:rev_sync/rev_sync.dart';

import '../../domain/entities/bookmark.dart';

/// Maps the persistence [BookmarkEntity] to/from the domain [Bookmark].
///
/// Lives in the feature data layer (not on the entity) so the dependency
/// direction stays `feature → database` and the entity stays domain-free.
extension BookmarkEntityMapper on BookmarkEntity {
  Bookmark toDomain() => Bookmark(
    id: uuid,
    title: title,
    url: url,
    description: description,
    tags: List.unmodifiable(tags),
    imageUrls: List.unmodifiable(imageUrls),
    videoUrl: videoUrl,
    createdAt: createdAt,
    updatedAt: updatedAt,
    isPendingSync: syncState.isPending,
    isConflicted: syncState == SyncState.conflicted,
    isFailed: syncState == SyncState.failed,
  );

  /// Mutates this entity from a [BookmarkInput] for create/update flows.
  /// Bumps `updatedAt`; leaves `createdAt` alone so updates preserve it.
  void applyInput(BookmarkInput input, {required DateTime now}) {
    title = input.title;
    url = input.url;
    description = input.description;
    tags = List.of(input.tags);
    imageUrls = List.of(input.imageUrls);
    videoUrl = input.videoUrl;
    updatedAt = now;
  }
}
