import 'package:go_router/go_router.dart';

import 'screens/bookmark_detail_screen.dart';
import 'screens/bookmark_form_screen.dart';

/// Canonical navigation paths owned by the bookmarks feature.
///
/// The feature navigates by pushing these via `go_router`'s `context.push`, so
/// it doesn't depend on the app shell. The `*Pattern` entries are the matching
/// templates the route table below mounts; the helper methods build concrete
/// locations to navigate to.
abstract final class BookmarksRoutes {
  /// The bookmarks list (a shell tab).
  static const list = '/bookmarks';

  /// The create-bookmark form, shown outside the app shell.
  static const create = '/bookmarks/new';

  /// Path template for the bookmark detail screen.
  static const detailPattern = '/bookmarks/:id';

  /// Path template for the edit-bookmark form.
  static const editPattern = '/bookmarks/:id/edit';

  /// The detail screen for the bookmark with [id].
  static String detail(String id) => '/bookmarks/$id';

  /// The edit form for the bookmark with [id].
  static String edit(String id) => '/bookmarks/$id/edit';
}

/// The bookmarks feature's non-shell routes, mounted by the host app.
///
/// The list tab itself lives in the app shell; these are the full-screen
/// routes the feature owns. `create` precedes the `:id` template so the literal
/// `/bookmarks/new` segment matches before the parameterized one.
List<RouteBase> get bookmarksRoutes => [
  GoRoute(
    path: BookmarksRoutes.create,
    builder: (context, state) => const BookmarkFormScreen(),
  ),
  GoRoute(
    path: BookmarksRoutes.detailPattern,
    builder: (context, state) =>
        BookmarkDetailScreen(id: state.pathParameters['id']!),
  ),
  GoRoute(
    path: BookmarksRoutes.editPattern,
    builder: (context, state) =>
        BookmarkFormScreen(id: state.pathParameters['id']),
  ),
];
