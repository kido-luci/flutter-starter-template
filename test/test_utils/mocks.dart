import 'package:bloc_test/bloc_test.dart';
import 'package:feature_auth/src/domain/usecases/register.dart';
import 'package:feature_auth/src/domain/usecases/restore_session.dart';
import 'package:feature_auth/src/domain/usecases/sign_in.dart';
import 'package:feature_auth/src/domain/usecases/sign_out.dart';
import 'package:feature_notifications/feature_notifications.dart';
import 'package:test_utils/test_utils.dart';

/// Cross-feature mocks used only by the app-level `widget_test`. Feature-local
/// mocks live in each feature package's own `test/support.dart`; shared doubles
/// (`FakeSession`, readers) and fixtures come from `package:test_utils`.

class MockSignIn extends Mock implements SignInUseCase {}

class MockRegister extends Mock implements RegisterUseCase {}

class MockSignOut extends Mock implements SignOutUseCase {}

class MockRestoreSession extends Mock implements RestoreSessionUseCase {}

class MockNotificationsBloc
    extends MockBloc<NotificationsEvent, NotificationsState>
    implements NotificationsBloc {}
