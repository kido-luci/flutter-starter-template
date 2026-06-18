import 'package:feature_bookmarks/feature_bookmarks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  group('bookmarksRoutes', () {
    final paths = bookmarksRoutes
        .whereType<GoRoute>()
        .map((route) => route.path)
        .toList();

    test("contributes the feature's non-shell paths", () {
      expect(paths, [
        BookmarksRoutes.create,
        BookmarksRoutes.detailPattern,
        BookmarksRoutes.editPattern,
      ]);
    });

    test('orders the literal create path before the :id template', () {
      // go_router matches in order, so `/bookmarks/new` must precede
      // `/bookmarks/:id` or the literal segment would be swallowed.
      expect(
        paths.indexOf(BookmarksRoutes.create),
        lessThan(paths.indexOf(BookmarksRoutes.detailPattern)),
      );
    });
  });
}
