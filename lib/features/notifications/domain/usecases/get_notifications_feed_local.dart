import 'package:architecture/architecture.dart';
import 'package:injectable/injectable.dart';

import '../entities/notifications_feed.dart';
import '../repositories/notifications_repository.dart';

/// Reads the cached feed without triggering a sync. Used by the bloc to refresh
/// the UI after a background sync, without kicking off another sync (which
/// would loop).
@injectable
class GetNotificationsFeedLocal extends NoParamUseCase<NotificationsFeed> {
  const GetNotificationsFeedLocal(this._repository);

  final NotificationsRepository _repository;

  @override
  Future<Result<NotificationsFeed>> call([NoParams param = noParams]) {
    return runResultGuarded(_repository.getFeedLocal);
  }
}
