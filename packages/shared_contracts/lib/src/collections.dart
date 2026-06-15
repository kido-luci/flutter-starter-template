import 'package:architecture/architecture.dart';

/// Lightweight projection of a collection for cross-feature display (e.g. the
/// home dashboard and the bookmarks "Collections" tab), so consumers don't
/// depend on the collections feature's `Collection` aggregate.
class CollectionSummary {
  const CollectionSummary({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.itemCount,
  });

  final String id;
  final String name;

  /// Stable token mapped to an icon by the shared collection visuals (see
  /// `collectionIconFor`). Stored as a string so it survives JSON and ObjectBox
  /// round-trips without depending on icon-font internals.
  final String icon;

  /// ARGB color value used as the seed for the card gradient.
  final int color;

  /// Number of bookmarks in the collection.
  final int itemCount;
}

/// Reads collection summaries. Implemented by the collections feature (which
/// owns the data) and consumed through `shared` by `home` and `bookmarks`.
abstract class CollectionsReader
    extends NoParamUseCase<List<CollectionSummary>> {
  const CollectionsReader();
}
