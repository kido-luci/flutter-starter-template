import 'package:architecture/architecture.dart';
import 'package:injectable/injectable.dart';

import '../entities/collection.dart';
import '../repositories/collections_repository.dart';

/// Reads collections from the local store without triggering a sync.
///
/// Used to refresh the list after a sync cycle completes, avoiding the
/// read-triggers-sync feedback loop that `ListCollections` would cause.
@injectable
class ListLocalCollections extends NoParamUseCase<List<Collection>> {
  const ListLocalCollections(this._repository);

  final CollectionsRepository _repository;

  @override
  Future<Result<List<Collection>>> call([NoParams param = noParams]) {
    return runResultGuarded(_repository.listLocal);
  }
}
