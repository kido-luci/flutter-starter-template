import 'package:go_router/go_router.dart';

import 'screens/collection_detail_screen.dart';
import 'screens/collection_form_screen.dart';
import 'screens/collections_list_screen.dart';

/// Canonical navigation paths owned by the collections feature.
///
/// The feature navigates by pushing these via `go_router`'s `context.push`, so
/// it doesn't depend on the app shell. The `*Pattern` entries are the matching
/// templates the route table below mounts; the helper methods build concrete
/// locations to navigate to.
abstract final class CollectionsRoutes {
  /// The standalone collections browser.
  static const list = '/collections';

  /// The create-collection form, shown outside the app shell.
  static const create = '/collections/new';

  /// Path template for the collection detail screen.
  static const detailPattern = '/collections/:id';

  /// Path template for the edit-collection form.
  static const editPattern = '/collections/:id/edit';

  /// The detail screen for the collection with [id].
  static String detail(String id) => '/collections/$id';

  /// The edit form for the collection with [id].
  static String edit(String id) => '/collections/$id/edit';
}

/// The collections feature's routes, mounted by the host app.
///
/// Collections is not a shell tab, so the feature owns all of its routes.
/// `create` precedes the `:id` template so the literal `/collections/new`
/// segment matches before the parameterized one.
List<RouteBase> get collectionsRoutes => [
  GoRoute(
    path: CollectionsRoutes.list,
    builder: (context, state) => const CollectionsListScreen(),
  ),
  GoRoute(
    path: CollectionsRoutes.create,
    builder: (context, state) => const CollectionFormScreen(),
  ),
  GoRoute(
    path: CollectionsRoutes.detailPattern,
    builder: (context, state) =>
        CollectionDetailScreen(id: state.pathParameters['id']!),
  ),
  GoRoute(
    path: CollectionsRoutes.editPattern,
    builder: (context, state) =>
        CollectionFormScreen(id: state.pathParameters['id']),
  ),
];
