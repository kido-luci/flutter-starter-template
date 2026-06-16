import 'package:path_provider/path_provider.dart';

import '../objectbox.g.dart';

/// Owns the lifecycle of the ObjectBox [Store]. There must be exactly one
/// store per database path per process — opening twice throws — so this is
/// constructed once during DI init (see the host app's `ObjectBoxModule`) and
/// held as a singleton.
class ObjectBox {
  ObjectBox._(this.store);

  final Store store;

  static Future<ObjectBox> open() async {
    final docsDir = await getApplicationDocumentsDirectory();
    final store = await openStore(directory: '${docsDir.path}/objectbox');
    return ObjectBox._(store);
  }

  void close() => store.close();
}
