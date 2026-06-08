import 'package:analytics/analytics.dart';
import 'package:architecture/architecture.dart';

import '../../../domain/entities/bookmark.dart';
import '../../../domain/usecases/create_bookmark.dart';
import '../../../domain/usecases/update_bookmark.dart';
import 'bookmark_form_state.dart';

class BookmarkFormSubmitter {
  const BookmarkFormSubmitter(this._create, this._update, this._analytics);

  final CreateBookmark _create;
  final UpdateBookmark _update;
  final AnalyticsService _analytics;

  Future<Result<void>> submit(BookmarkFormState state) async {
    final input = BookmarkInput(
      title: state.title.trim(),
      url: state.url.trim(),
      description: state.description.trim(),
      tags: state.tags,
      imageUrls: state.imageUrls,
      videoUrl: state.videoUrl,
    );
    final isEditing = state.id != null;
    final result = !isEditing
        ? await _create(input)
        : await _update((id: state.id!, input: input));

    switch (result) {
      case Ok(value: final bookmark):
        _trackChange(bookmark, isEditing: isEditing);
        return const Ok(null);
      case Err(:final failure):
        return Err(failure);
    }
  }

  void _trackChange(Bookmark bookmark, {required bool isEditing}) {
    final trackChange = isEditing
        ? _analytics.trackBookmarkUpdated
        : _analytics.trackBookmarkCreated;
    trackChange(
      bookmarkId: bookmark.id,
      tagCount: bookmark.tags.length,
      hasDescription: bookmark.description.isNotEmpty,
    ).fire();
  }
}
