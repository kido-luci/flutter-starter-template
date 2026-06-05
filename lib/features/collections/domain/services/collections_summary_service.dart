import 'package:architecture/architecture.dart';
import 'package:injectable/injectable.dart';

import '../../../../shared/domain/collections.dart';
import '../entities/collection.dart';
import '../usecases/list_collections.dart';

/// Projects each [Collection] to a [CollectionSummary].
///
/// Implements the shared [CollectionsReader] so other features can display
/// collections without depending on the collections domain.
@LazySingleton(as: CollectionsReader)
class CollectionsSummaryService extends CollectionsReader {
  const CollectionsSummaryService(this._listCollections);

  final ListCollections _listCollections;

  @override
  Future<Result<List<CollectionSummary>>> call([
    NoParams param = noParams,
  ]) async {
    final result = await _listCollections();
    return switch (result) {
      Ok(value: final items) => Ok(
        items.map(_toSummary).toList(growable: false),
      ),
      Err(:final failure) => Err(failure),
    };
  }

  CollectionSummary _toSummary(Collection collection) => CollectionSummary(
    id: collection.id,
    name: collection.name,
    icon: collection.icon,
    color: collection.color,
    itemCount: collection.itemCount,
  );
}
