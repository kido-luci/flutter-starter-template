import 'dart:async';

import 'package:injectable/injectable.dart';

/// A simple shared event bus to notify interested listeners (like the NotificationsBloc)
/// that some user activity occurred (like creating a bookmark) so they can refresh.
///
/// This lives in the shared layer so that features can communicate without violating
/// cross-feature dependency boundaries.
@lazySingleton
class ActivityNotifier {
  final _controller = StreamController<void>.broadcast();

  /// Stream of activity events.
  Stream<void> get onActivityOccurred => _controller.stream;

  /// Notify listeners that an activity has occurred.
  void notifyActivityOccurred() {
    _controller.add(null);
  }

  /// Close the controller.
  void dispose() {
    _controller.close();
  }
}
