import 'package:architecture/architecture.dart';

import 'bookmark_stats.dart';

/// Reads every bookmark as a lightweight [BookmarkSummary].
///
/// Implemented by the bookmarks feature and consumed through `shared` by the
/// collections feature, so collections can resolve its member bookmark ids and
/// offer an "add bookmarks" picker without depending on the bookmarks domain.
abstract class BookmarkSummariesReader
    extends NoParamUseCase<List<BookmarkSummary>> {
  const BookmarkSummariesReader();
}
