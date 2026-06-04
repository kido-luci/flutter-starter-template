import 'package:architecture/architecture.dart';
import 'package:flutter_starter_template/features/notifications/data/local/activity_entity.dart';
import 'package:flutter_starter_template/features/notifications/data/local/notification_entity.dart';
import 'package:flutter_starter_template/features/notifications/data/local/notifications_local_data_source.dart';
import 'package:flutter_starter_template/features/notifications/data/repositories/notifications_repository_impl.dart';
import 'package:flutter_starter_template/features/notifications/domain/entities/app_notification.dart';
import 'package:flutter_starter_template/features/notifications/domain/entities/notifications_feed.dart';
import 'package:flutter_starter_template/features/notifications/domain/entities/user_activity.dart';
import 'package:flutter_starter_template/features/notifications/domain/services/notifications_sync_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test_utils/test_utils.dart';

class MockNotificationsLocalDataSource extends Mock
    implements NotificationsLocalDataSource {}

class MockNotificationsSyncController extends Mock
    implements NotificationsSyncController {}

void main() {
  late MockNotificationsLocalDataSource local;
  late MockNotificationsSyncController sync;
  late NotificationsRepositoryImpl repository;

  final now = DateTime(2026, 6, 1, 12);

  setUp(() {
    local = MockNotificationsLocalDataSource();
    sync = MockNotificationsSyncController();
    repository = NotificationsRepositoryImpl(local, sync);

    when(() => sync.sync()).thenAnswer((_) async {});
    when(() => local.notifications()).thenAnswer(
      (_) async => [
        NotificationEntity(
          uuid: 'n-1',
          title: 'Mention',
          body: 'Alice mentioned you',
          type: 'social',
          isRead: false,
          createdAt: now,
        ),
        NotificationEntity(
          uuid: 'n-2',
          title: 'Fallback',
          body: 'Unknown type',
          type: 'unexpected',
          isRead: true,
          createdAt: now.add(const Duration(minutes: 1)),
        ),
      ],
    );
    when(() => local.activities()).thenAnswer(
      (_) async => [
        ActivityEntity(
          uuid: 'a-1',
          description: 'Signed in',
          type: 'signed_in',
          createdAt: now,
        ),
        ActivityEntity(
          uuid: 'a-2',
          description: 'Fallback',
          type: 'unexpected',
          createdAt: now.add(const Duration(minutes: 1)),
        ),
      ],
    );
  });

  group('NotificationsRepositoryImpl', () {
    test('getFeed maps cached rows to domain and triggers a sync', () async {
      final result = await repository.getFeed();

      final ok = result as Ok<NotificationsFeed>;
      expect(ok.value.notifications, hasLength(2));
      expect(ok.value.notifications[0].type, NotificationType.social);
      expect(ok.value.notifications[1].type, NotificationType.system);
      expect(ok.value.notifications[1].isRead, isTrue);
      expect(ok.value.activities, hasLength(2));
      expect(ok.value.activities[0].type, UserActivityType.signedIn);
      expect(ok.value.activities[1].type, UserActivityType.other);
      verify(() => sync.sync()).called(1);
    });

    test('getFeedLocal reads the cache without triggering a sync', () async {
      final result = await repository.getFeedLocal();

      expect(result, isA<Ok<NotificationsFeed>>());
      verify(() => local.notifications()).called(1);
      verify(() => local.activities()).called(1);
      verifyNever(() => sync.sync());
    });

    test('markRead queues the read locally and triggers a sync', () async {
      when(() => local.markReadPending('n-1')).thenAnswer((_) async {});

      final result = await repository.markRead('n-1');

      expect(result, isA<Ok<void>>());
      verify(() => local.markReadPending('n-1')).called(1);
      verify(() => sync.sync()).called(1);
    });
  });
}
