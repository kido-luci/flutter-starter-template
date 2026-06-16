import 'package:architecture/architecture.dart';
import 'package:injectable/injectable.dart';

import '../entities/collection.dart';
import '../repositories/collections_repository.dart';

@injectable
class GetCollectionUseCase extends UseCase<String, Collection> {
  const GetCollectionUseCase(this._repository);

  final CollectionsRepository _repository;

  @override
  Future<Result<Collection>> call(String param) {
    return runResultGuarded(() => _repository.get(param));
  }
}
