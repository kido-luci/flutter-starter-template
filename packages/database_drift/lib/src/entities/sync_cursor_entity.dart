/// Mutable persistence row for the sync cursor store.
///
/// One row per sync resource, tracking the highest server revision applied.
class SyncCursorEntity {
  SyncCursorEntity({required this.resource, required this.rev, this.id = 0});

  int id;
  String resource;
  int rev;
}
