/// Canonical navigation paths owned by the bookmarks feature.
///
/// The app router wires these same paths to the feature's screens; the feature
/// navigates by pushing them via `go_router`'s `context.push`, so it doesn't
/// depend on the app shell's typed-route classes.
abstract final class BookmarksRoutes {
  /// The bookmarks list (a shell tab).
  static const list = '/bookmarks';

  /// The create-bookmark form, shown outside the app shell.
  static const create = '/bookmarks/new';

  /// The detail screen for the bookmark with [id].
  static String detail(String id) => '/bookmarks/$id';

  /// The edit form for the bookmark with [id].
  static String edit(String id) => '/bookmarks/$id/edit';
}
