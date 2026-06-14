import 'package:architecture/architecture.dart';
import 'package:injectable/injectable.dart';

import '../entities/notifications_feed.dart';
import '../repositories/notifications_repository.dart';

@injectable
class GetNotificationsFeedUseCase extends NoParamUseCase<NotificationsFeed> {
  const GetNotificationsFeedUseCase(this._repository);

  final NotificationsRepository _repository;

  @override
  Future<Result<NotificationsFeed>> call([NoParams param = noParams]) {
    return runResultGuarded(_repository.getFeed);
  }
}
