import 'package:app_platform/app_platform.dart';
import 'package:mocktail/mocktail.dart';

class MockImagePickerService extends Mock implements ImagePickerService {}

class MockPermissionService extends Mock implements PermissionService {}

class MockShareService extends Mock implements ShareService {}

void stubShareService(MockShareService share) {
  when(
    () => share.share(
      text: any(named: 'text'),
      subject: any(named: 'subject'),
    ),
  ).thenAnswer((_) async {});
}
