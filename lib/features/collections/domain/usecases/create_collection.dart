import 'package:architecture/architecture.dart';
import 'package:injectable/injectable.dart';

import '../entities/collection.dart';
import '../repositories/collections_repository.dart';
import '_collection_validation.dart';

@injectable
class CreateCollection extends UseCase<CollectionInput, Collection> {
  const CreateCollection(this._repository);

  final CollectionsRepository _repository;

  @override
  Future<Result<Collection>> call(CollectionInput param) {
    final failure = validateCollectionInput(param);
    if (failure != null) return Future.value(Err(failure));
    return runResultGuarded(() => _repository.create(param));
  }
}
