import 'package:architecture/architecture.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../domain/entities/bookmark.dart';

part 'bookmark_detail_state.freezed.dart';

@freezed
sealed class BookmarkDetailState with _$BookmarkDetailState {
  const factory BookmarkDetailState.loading() = BookmarkDetailLoading;
  const factory BookmarkDetailState.ready(Bookmark bookmark) =
      BookmarkDetailReady;
  const factory BookmarkDetailState.deleting(Bookmark bookmark) =
      BookmarkDetailDeleting;
  const factory BookmarkDetailState.deleted() = BookmarkDetailDeleted;
  const factory BookmarkDetailState.failure(Failure failure) =
      BookmarkDetailFailure;
}
