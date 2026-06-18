/// Collections feature: data, domain, and presentation layers.
///
/// The host app wires `FeatureCollectionsPackageModule` via
/// `externalPackageModulesBefore`, mounts the exported screens in its router,
/// and drives background sync through `CollectionsSyncController`. The bookmarks
/// feature consumes the two exported capability widgets (`CollectionsListView`
/// and `AddToCollectionSheet`). Only the `Collection` entity is exported from
/// the domain layer; repositories and use cases are internal, resolved through
/// dependency injection. Data and the remaining presentation internals stay
/// private.
library;

export 'src/di.module.dart' show FeatureCollectionsPackageModule;
export 'src/domain/entities/collection.dart';
export 'src/domain/services/collections_sync_controller.dart';
export 'src/presentation/collections_routes.dart';
export 'src/presentation/screens/collection_detail_screen.dart';
export 'src/presentation/screens/collection_form_screen.dart';
export 'src/presentation/screens/collections_list_screen.dart';
export 'src/presentation/widgets/add_to_collection_sheet.dart';
export 'src/presentation/widgets/collections_list_view.dart';
