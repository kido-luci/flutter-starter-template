/// Canonical navigation paths owned by the collections feature.
///
/// The app router wires these same paths to the feature's screens; the feature
/// navigates by pushing them via `go_router`'s `context.push`, so it doesn't
/// depend on the app shell's typed-route classes.
abstract final class CollectionsRoutes {
  /// The collections list (a shell tab).
  static const list = '/collections';

  /// The create-collection form, shown outside the app shell.
  static const create = '/collections/new';

  /// The detail screen for the collection with [id].
  static String detail(String id) => '/collections/$id';

  /// The edit form for the collection with [id].
  static String edit(String id) => '/collections/$id/edit';
}
