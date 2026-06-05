import 'package:architecture/architecture.dart';
import 'package:injectable/injectable.dart';

import '../entities/collection.dart';
import '../repositories/collections_repository.dart';
import '_collection_validation.dart';

/// Parameters for [UpdateCollection]: the collection id plus the new input.
class UpdateCollectionParams {
  const UpdateCollectionParams({required this.id, required this.input});

  final String id;
  final CollectionInput input;
}

@injectable
class UpdateCollection extends UseCase<UpdateCollectionParams, Collection> {
  const UpdateCollection(this._repository);

  final CollectionsRepository _repository;

  @override
  Future<Result<Collection>> call(UpdateCollectionParams param) {
    final failure = validateCollectionInput(param.input);
    if (failure != null) return Future.value(Err(failure));
    return runResultGuarded(() => _repository.update(param.id, param.input));
  }
}
