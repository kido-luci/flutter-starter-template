import 'package:architecture/architecture.dart';
import '../../../domain/usecases/get_bookmark.dart';
import 'bookmark_form_state.dart';

class BookmarkFormLoader {
  const BookmarkFormLoader(this._get);

  final GetBookmarkUseCase _get;

  Future<Result<BookmarkFormState>> load(String id) async {
    final result = await _get(id);
    switch (result) {
      case Ok(value: final bookmark):
        return Ok(
          BookmarkFormState(
            id: bookmark.id,
            status: BookmarkFormStatus.idle,
            title: bookmark.title,
            url: bookmark.url,
            description: bookmark.description,
            tags: List.of(bookmark.tags),
            imageUrls: List.of(bookmark.imageUrls),
            videoUrl: bookmark.videoUrl,
          ),
        );
      case Err(:final failure):
        return Err(failure);
    }
  }
}
