import 'package:architecture/architecture.dart';
import 'package:injectable/injectable.dart';

import '../entities/bookmark.dart';
import '../repositories/bookmarks_repository.dart';

@injectable
class GetBookmarkUseCase extends UseCase<String, Bookmark> {
  const GetBookmarkUseCase(this._repository);

  final BookmarksRepository _repository;

  @override
  Future<Result<Bookmark>> call(String param) {
    return runResultGuarded(() => _repository.get(param));
  }
}
