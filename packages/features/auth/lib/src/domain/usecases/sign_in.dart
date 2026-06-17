import 'package:architecture/architecture.dart';
import 'package:injectable/injectable.dart';

import 'package:shared_contracts/shared_contracts.dart';
import '../repositories/auth_repository.dart';

typedef SignInParams = ({String username, String password});

@injectable
class SignInUseCase extends UseCase<SignInParams, AuthUser> {
  const SignInUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Result<AuthUser>> call(SignInParams param) {
    if (param.username.isEmpty || param.password.isEmpty) {
      return Future.value(
        const Err(
          InvalidCredentialsFailure('Username and password are required.'),
        ),
      );
    }
    return runResultGuarded(
      () => _repository.signIn(
        username: param.username,
        password: param.password,
      ),
    );
  }
}
