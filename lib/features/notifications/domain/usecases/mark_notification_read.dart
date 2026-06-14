import 'package:architecture/architecture.dart';
import 'package:injectable/injectable.dart';

import '../repositories/notifications_repository.dart';

@injectable
class MarkNotificationReadUseCase extends UseCase<String, void> {
  const MarkNotificationReadUseCase(this._repository);

  final NotificationsRepository _repository;

  @override
  Future<Result<void>> call(String id) {
    return runResultGuarded(() => _repository.markRead(id));
  }
}
