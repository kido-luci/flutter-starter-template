import 'package:architecture/architecture.dart';
import 'package:injectable/injectable.dart';

import '../repositories/auth_repository.dart';

typedef ChangePasswordParams = ({String currentPassword, String newPassword});

@injectable
class ChangePasswordUseCase extends UseCase<ChangePasswordParams, void> {
  const ChangePasswordUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Result<void>> call(ChangePasswordParams param) {
    if (param.currentPassword.isEmpty || param.newPassword.isEmpty) {
      return Future.value(
        const Err(InvalidCredentialsFailure('Both passwords are required.')),
      );
    }
    return runResultGuarded(
      () => _repository.changePassword(
        currentPassword: param.currentPassword,
        newPassword: param.newPassword,
      ),
    );
  }
}
