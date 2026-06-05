import 'package:architecture/architecture.dart';
import 'package:injectable/injectable.dart';

import '../repositories/collections_repository.dart';

@injectable
class DeleteCollection extends UseCase<String, void> {
  const DeleteCollection(this._repository);

  final CollectionsRepository _repository;

  @override
  Future<Result<void>> call(String param) {
    return runResultGuarded(() => _repository.delete(param));
  }
}
