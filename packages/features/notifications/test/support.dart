import 'package:bloc_test/bloc_test.dart';
import 'package:feature_notifications/feature_notifications.dart';
import 'package:test_utils/test_utils.dart';

export 'package:test_utils/test_utils.dart';

class MockNotificationsBloc
    extends MockBloc<NotificationsEvent, NotificationsState>
    implements NotificationsBloc {}

class MockNotificationsSyncController extends Mock
    implements NotificationsSyncController {}
