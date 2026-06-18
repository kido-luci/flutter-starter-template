import 'package:feature_collections/feature_collections.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  group('collectionsRoutes', () {
    final paths = collectionsRoutes
        .whereType<GoRoute>()
        .map((route) => route.path)
        .toList();

    test("contributes all of the feature's routes", () {
      expect(paths, [
        CollectionsRoutes.list,
        CollectionsRoutes.create,
        CollectionsRoutes.detailPattern,
        CollectionsRoutes.editPattern,
      ]);
    });

    test('orders the literal create path before the :id template', () {
      // go_router matches in order, so `/collections/new` must precede
      // `/collections/:id` or the literal segment would be swallowed.
      expect(
        paths.indexOf(CollectionsRoutes.create),
        lessThan(paths.indexOf(CollectionsRoutes.detailPattern)),
      );
    });
  });
}
