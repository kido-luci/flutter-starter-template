import 'package:architecture/architecture.dart';
import 'package:injectable/injectable.dart';

import '../repositories/auth_repository.dart';

@injectable
class DeleteAccountUseCase extends NoParamUseCase<void> {
  const DeleteAccountUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Result<void>> call([NoParams param = noParams]) {
    return runResultGuarded(_repository.deleteAccount);
  }
}
