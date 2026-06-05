import 'package:architecture/architecture.dart';
import 'package:injectable/injectable.dart';

import '../entities/collection.dart';
import '../repositories/collections_repository.dart';

@injectable
class ListCollections extends NoParamUseCase<List<Collection>> {
  const ListCollections(this._repository);

  final CollectionsRepository _repository;

  @override
  Future<Result<List<Collection>>> call([NoParams param = noParams]) {
    return runResultGuarded(_repository.list);
  }
}
