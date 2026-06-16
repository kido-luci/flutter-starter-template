import 'package:architecture/architecture.dart';
import 'package:injectable/injectable.dart';

import '../entities/bookmark.dart';
import '../repositories/bookmarks_repository.dart';
import '_bookmark_validation.dart';

typedef UpdateBookmarkParams = ({String id, BookmarkInput input});

@injectable
class UpdateBookmarkUseCase extends UseCase<UpdateBookmarkParams, Bookmark> {
  const UpdateBookmarkUseCase(this._repository);

  final BookmarksRepository _repository;

  @override
  Future<Result<Bookmark>> call(UpdateBookmarkParams param) {
    final failure = validateBookmarkInput(param.input);
    if (failure != null) return Future.value(Err(failure));
    return runResultGuarded(() => _repository.update(param.id, param.input));
  }
}
