import 'package:architecture/architecture.dart';
import 'package:injectable/injectable.dart';

import '../../../../shared/domain/entities/auth_user.dart';
import '../repositories/auth_repository.dart';

@injectable
class RestoreSessionUseCase extends NoParamUseCase<AuthUser> {
  const RestoreSessionUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Result<AuthUser>> call([NoParams param = noParams]) {
    return runResultGuarded(_repository.restoreSession);
  }
}
