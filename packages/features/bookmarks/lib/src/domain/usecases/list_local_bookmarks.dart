import 'package:architecture/architecture.dart';
import 'package:injectable/injectable.dart';

import '../entities/bookmark.dart';
import '../repositories/bookmarks_repository.dart';

/// Reads bookmarks from the local store without triggering a sync.
///
/// Used to refresh the list after a sync cycle completes, avoiding the
/// read-triggers-sync feedback loop that `ListBookmarksUseCase` would cause.
@injectable
class ListLocalBookmarksUseCase extends NoParamUseCase<List<Bookmark>> {
  const ListLocalBookmarksUseCase(this._repository);

  final BookmarksRepository _repository;

  @override
  Future<Result<List<Bookmark>>> call([NoParams param = noParams]) {
    return runResultGuarded(_repository.listLocal);
  }
}
