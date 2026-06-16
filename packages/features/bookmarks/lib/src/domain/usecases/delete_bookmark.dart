import 'package:architecture/architecture.dart';
import 'package:injectable/injectable.dart';

import '../repositories/bookmarks_repository.dart';

@injectable
class DeleteBookmarkUseCase extends UseCase<String, void> {
  const DeleteBookmarkUseCase(this._repository);

  final BookmarksRepository _repository;

  @override
  Future<Result<void>> call(String param) {
    return runResultGuarded(() => _repository.delete(param));
  }
}
