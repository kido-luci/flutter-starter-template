/// Collections feature: data, domain, and presentation layers.
///
/// The host app wires `FeatureCollectionsPackageModule` via
/// `externalPackageModulesBefore`, mounts the exported screens in its router,
/// and drives background sync through `CollectionsSyncController`. The bookmarks
/// feature consumes the two exported capability widgets (`CollectionsListView`
/// and `AddToCollectionSheet`). The domain layer is exported as the feature's
/// public API; data and presentation internals stay private.
library;

export 'src/di.module.dart' show FeatureCollectionsPackageModule;
export 'src/domain/entities/collection.dart';
export 'src/domain/repositories/collections_repository.dart';
export 'src/domain/services/collections_sync_controller.dart';
export 'src/domain/usecases/create_collection.dart';
export 'src/domain/usecases/delete_collection.dart';
export 'src/domain/usecases/get_collection.dart';
export 'src/domain/usecases/list_collections.dart';
export 'src/domain/usecases/list_local_collections.dart';
export 'src/domain/usecases/update_collection.dart';
export 'src/presentation/collections_routes.dart';
export 'src/presentation/screens/collection_detail_screen.dart';
export 'src/presentation/screens/collection_form_screen.dart';
export 'src/presentation/screens/collections_list_screen.dart';
export 'src/presentation/widgets/add_to_collection_sheet.dart';
export 'src/presentation/widgets/collections_list_view.dart';
