import 'package:objectbox/objectbox.dart';

/// One stored delta cursor: the highest server revision a pull has applied for
/// a given resource (e.g. `bookmarks`). One row per resource.
@Entity()
class SyncCursorEntity {
  SyncCursorEntity({required this.resource, required this.rev, this.id = 0});

  @Id()
  int id;

  @Unique()
  String resource;

  int rev;
}
