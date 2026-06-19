import 'package:architecture/architecture.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_contracts/shared_contracts.dart';

/// Registers Null-Object readers for the cross-feature data sources that the
/// bookmarks and collections features normally provide.
///
/// `home`'s dashboard reads bookmark stats and collection summaries through the
/// `shared_contracts` reader interfaces; the bookmarks/collections features own
/// the implementations. When `fst create --exclude-feature` drops those
/// features, these fallbacks keep `home` working with empty data instead of
/// failing to resolve the readers. Each registers only if the owning feature
/// didn't — when the feature is present, its real reader wins.
void registerReaderFallbacks(GetIt getIt) {
  if (!getIt.isRegistered<BookmarkStatsReader>()) {
    getIt.registerLazySingleton<BookmarkStatsReader>(
      NoOpBookmarkStatsReader.new,
    );
  }
  if (!getIt.isRegistered<CollectionsReader>()) {
    getIt.registerLazySingleton<CollectionsReader>(NoOpCollectionsReader.new);
  }
}

/// A [BookmarkStatsReader] that reports no bookmarks.
class NoOpBookmarkStatsReader extends BookmarkStatsReader {
  const NoOpBookmarkStatsReader();

  @override
  Future<Result<BookmarkStats>> call([NoParams param = noParams]) async =>
      const Ok(BookmarkStats());
}

/// A [CollectionsReader] that reports no collections.
class NoOpCollectionsReader extends CollectionsReader {
  const NoOpCollectionsReader();

  @override
  Future<Result<List<CollectionSummary>>> call([
    NoParams param = noParams,
  ]) async => const Ok(<CollectionSummary>[]);
}
