/// Bookmarks feature: data, domain, and presentation layers.
///
/// The host app wires `FeatureBookmarksPackageModule` via
/// `externalPackageModulesBefore`, mounts the exported screens in its router,
/// and drives background sync through `BookmarksSyncController`. The domain
/// layer (entities, use cases, contracts) is exported as the feature's public
/// API; data and presentation internals stay private.
library;

export 'src/di.module.dart' show FeatureBookmarksPackageModule;
export 'src/domain/entities/bookmark.dart';
export 'src/domain/repositories/bookmarks_repository.dart';
export 'src/domain/services/bookmarks_sync_controller.dart';
export 'src/domain/usecases/create_bookmark.dart';
export 'src/domain/usecases/delete_bookmark.dart';
export 'src/domain/usecases/get_bookmark.dart';
export 'src/domain/usecases/list_bookmarks.dart';
export 'src/domain/usecases/list_local_bookmarks.dart';
export 'src/domain/usecases/update_bookmark.dart';
export 'src/presentation/bookmarks_routes.dart';
export 'src/presentation/screens/bookmark_detail_screen.dart';
export 'src/presentation/screens/bookmark_form_screen.dart';
export 'src/presentation/screens/bookmarks_list_screen.dart';
