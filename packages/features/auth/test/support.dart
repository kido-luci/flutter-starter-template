import 'package:feature_auth/src/domain/repositories/auth_repository.dart';
import 'package:feature_auth/src/domain/usecases/change_password.dart';
import 'package:feature_auth/src/domain/usecases/delete_account.dart';
import 'package:feature_auth/src/domain/usecases/register.dart';
import 'package:feature_auth/src/domain/usecases/restore_session.dart';
import 'package:feature_auth/src/domain/usecases/sign_in.dart';
import 'package:feature_auth/src/domain/usecases/sign_out.dart';
import 'package:test_utils/test_utils.dart';

export 'package:test_utils/test_utils.dart';

class MockSignIn extends Mock implements SignInUseCase {}

class MockRegister extends Mock implements RegisterUseCase {}

class MockSignOut extends Mock implements SignOutUseCase {}

class MockDeleteAccount extends Mock implements DeleteAccountUseCase {}

class MockRestoreSession extends Mock implements RestoreSessionUseCase {}

class MockAuthRepository extends Mock implements AuthRepository {}

class MockChangePassword extends Mock implements ChangePasswordUseCase {}
