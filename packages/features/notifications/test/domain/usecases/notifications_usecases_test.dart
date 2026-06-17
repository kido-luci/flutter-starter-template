import 'package:architecture/architecture.dart';
import 'package:feature_notifications/feature_notifications.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support.dart';

class MockNotificationsRepository extends Mock
    implements NotificationsRepository {}

void main() {
  late MockNotificationsRepository repository;

  setUp(() {
    repository = MockNotificationsRepository();
  });

  group('GetNotificationsFeedUseCase', () {
    test('delegates to repository', () async {
      when(
        () => repository.getFeed(),
      ).thenAnswer((_) async => const Ok(NotificationsFeed.empty));

      final result = await GetNotificationsFeedUseCase(repository)();

      expect(result, isA<Ok<NotificationsFeed>>());
      verify(() => repository.getFeed()).called(1);
    });

    test('maps thrown errors to UnknownFailure', () async {
      when(() => repository.getFeed()).thenThrow(Exception('offline'));

      final result = await GetNotificationsFeedUseCase(repository)();

      expect(result, isA<Err<NotificationsFeed>>());
      expect(
        (result as Err<NotificationsFeed>).failure,
        isA<UnknownFailure>(),
      );
    });
  });

  group('MarkNotificationReadUseCase', () {
    test('delegates to repository', () async {
      when(
        () => repository.markRead('n-1'),
      ).thenAnswer((_) async => const Ok(null));

      final result = await MarkNotificationReadUseCase(repository)('n-1');

      expect(result, isA<Ok<void>>());
      verify(() => repository.markRead('n-1')).called(1);
    });

    test('maps thrown errors to UnknownFailure', () async {
      when(() => repository.markRead('n-1')).thenThrow(Exception('offline'));

      final result = await MarkNotificationReadUseCase(repository)('n-1');

      expect(result, isA<Err<void>>());
      expect((result as Err<void>).failure, isA<UnknownFailure>());
    });
  });
}
