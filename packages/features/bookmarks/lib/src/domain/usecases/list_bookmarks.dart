import 'package:architecture/architecture.dart';
import 'package:injectable/injectable.dart';

import '../entities/bookmark.dart';
import '../repositories/bookmarks_repository.dart';

@injectable
class ListBookmarksUseCase extends NoParamUseCase<List<Bookmark>> {
  const ListBookmarksUseCase(this._repository);

  final BookmarksRepository _repository;

  @override
  Future<Result<List<Bookmark>>> call([NoParams param = noParams]) {
    return runResultGuarded(_repository.list);
  }
}
