import 'package:architecture/architecture.dart';
import 'package:injectable/injectable.dart';

import 'package:shared_contracts/shared_contracts.dart';
import '../repositories/auth_repository.dart';

typedef RegisterParams = ({String username, String password});

@injectable
class RegisterUseCase extends UseCase<RegisterParams, AuthUser> {
  const RegisterUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Result<AuthUser>> call(RegisterParams param) {
    if (param.username.isEmpty || param.password.isEmpty) {
      return Future.value(
        const Err(
          InvalidCredentialsFailure('Username and password are required.'),
        ),
      );
    }
    return runResultGuarded(
      () => _repository.register(
        username: param.username,
        password: param.password,
      ),
    );
  }
}
