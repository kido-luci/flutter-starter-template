// Covers the scheduling maths behind `scheduleDaily` — the part that decides
// *when* a reminder lands. `init()` is deliberately not exercised: it reads the
// device zone over a method channel, which no unit test can answer, so the
// local zone is pinned here instead and the plugin call is captured.

import 'package:app_platform/app_platform.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test_utils/test_utils.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class _MockPlugin extends Mock implements FlutterLocalNotificationsPlugin {}

class _FakePermissionService extends PermissionService {
  _FakePermissionService()
    : super.custom(
        () async => PermissionStatus.granted,
        () async => PermissionStatus.granted,
        () async => false,
        () async => false,
      );
}

void main() {
  late _MockPlugin plugin;
  late NotificationsService service;

  // Loaded before any group body runs — `tz.getLocation` throws until the
  // database is initialised, and group bodies execute at declaration time.
  tz_data.initializeTimeZones();
  // A fixed non-UTC zone: a bug that silently schedules in UTC would still
  // look correct if the test happened to run in UTC.
  tz.setLocalLocation(tz.getLocation('Asia/Ho_Chi_Minh'));

  setUpAll(() {
    registerFallbackValue(const NotificationDetails());
    registerFallbackValue(AndroidScheduleMode.inexactAllowWhileIdle);
    registerFallbackValue(tz.TZDateTime.now(tz.local));
  });

  void stubSchedule() {
    when(
      () => plugin.zonedSchedule(
        id: any(named: 'id'),
        title: any(named: 'title'),
        body: any(named: 'body'),
        scheduledDate: any(named: 'scheduledDate'),
        notificationDetails: any(named: 'notificationDetails'),
        androidScheduleMode: any(named: 'androidScheduleMode'),
        matchDateTimeComponents: any(named: 'matchDateTimeComponents'),
        payload: any(named: 'payload'),
      ),
    ).thenAnswer((_) async {});
  }

  setUp(() {
    plugin = _MockPlugin();
    service = NotificationsService(plugin, _FakePermissionService());
    stubSchedule();
  });

  Future<tz.TZDateTime> scheduledDateFor({
    required int hour,
    required int minute,
  }) async {
    await service.scheduleDaily(
      id: 1,
      title: 'Time to review',
      body: '12 cards are due',
      hour: hour,
      minute: minute,
    );
    final captured = verify(
      () => plugin.zonedSchedule(
        id: any(named: 'id'),
        title: any(named: 'title'),
        body: any(named: 'body'),
        scheduledDate: captureAny(named: 'scheduledDate'),
        notificationDetails: any(named: 'notificationDetails'),
        androidScheduleMode: any(named: 'androidScheduleMode'),
        matchDateTimeComponents: any(named: 'matchDateTimeComponents'),
        payload: any(named: 'payload'),
      ),
    ).captured;
    return captured.single as tz.TZDateTime;
  }

  test('schedules the requested wall-clock time in the local zone', () async {
    final scheduled = await scheduledDateFor(hour: 7, minute: 30);

    expect(scheduled.hour, 7);
    expect(scheduled.minute, 30);
    expect(scheduled.location, tz.local);
  });

  test('always lands in the future, within the next 24 hours', () async {
    // Covers both branches without a fake clock: whichever side of `now` the
    // requested time falls on, the result must still be ahead and no more than
    // a day out. An off-by-one that scheduled in the past would fire instantly.
    for (final offset in const [
      Duration(hours: -6),
      Duration(minutes: -1),
      Duration(minutes: 1),
      Duration(hours: 6),
    ]) {
      final target = tz.TZDateTime.now(tz.local).add(offset);
      final scheduled = await scheduledDateFor(
        hour: target.hour,
        minute: target.minute,
      );
      final now = tz.TZDateTime.now(tz.local);

      expect(
        scheduled.isAfter(now),
        isTrue,
        reason: 'offset $offset scheduled $scheduled, which is not after $now',
      );
      expect(
        scheduled.difference(now),
        lessThanOrEqualTo(const Duration(days: 1)),
      );
      // `verify` consumes the recorded call, so start each offset clean.
      reset(plugin);
      stubSchedule();
    }
  });

  group('nextDailyInstance', () {
    // A zone that actually observes DST, unlike the fixed-offset one above:
    // 2026-03-08 02:00 EST jumps to 03:00 EDT, so that calendar day is 23
    // hours long. Adding a 24-hour Duration would land at 10:00 instead of
    // the 09:00 the user asked for.
    final newYork = tz.getLocation('America/New_York');

    test('keeps the wall-clock time when tomorrow loses an hour', () {
      final now = tz.TZDateTime(newYork, 2026, 3, 7, 10);

      final next = nextDailyInstance(now: now, hour: 9, minute: 0);

      expect(next.year, 2026);
      expect(next.month, 3);
      expect(next.day, 8);
      expect(next.hour, 9);
      expect(next.minute, 0);
    });

    test('keeps the wall-clock time when tomorrow gains an hour', () {
      // 2026-11-01 02:00 EDT falls back to 01:00 EST — a 25-hour day.
      final now = tz.TZDateTime(newYork, 2026, 10, 31, 10);

      final next = nextDailyInstance(now: now, hour: 9, minute: 0);

      expect(next.day, 1);
      expect(next.month, 11);
      expect(next.hour, 9);
    });

    test('stays today when the time is still ahead', () {
      final now = tz.TZDateTime(newYork, 2026, 6, 10, 8);

      final next = nextDailyInstance(now: now, hour: 9, minute: 30);

      expect(next.day, 10);
      expect(next.hour, 9);
      expect(next.minute, 30);
    });

    test('rolls into the next month, and the next year', () {
      final endOfMonth = tz.TZDateTime(newYork, 2026, 6, 30, 10);
      expect(nextDailyInstance(now: endOfMonth, hour: 9, minute: 0).month, 7);

      final endOfYear = tz.TZDateTime(newYork, 2026, 12, 31, 10);
      final next = nextDailyInstance(now: endOfYear, hour: 9, minute: 0);
      expect(next.year, 2027);
      expect(next.month, 1);
      expect(next.day, 1);
    });

    test('schedules tomorrow when the requested minute is the current one', () {
      final now = tz.TZDateTime(newYork, 2026, 6, 10, 9, 30);

      final next = nextDailyInstance(now: now, hour: 9, minute: 30);

      expect(next.day, 11);
    });
  });

  test('repeats daily without requiring an exact-alarm permission', () async {
    await service.scheduleDaily(
      id: 1,
      title: 't',
      body: 'b',
      hour: 9,
      minute: 0,
    );

    final captured = verify(
      () => plugin.zonedSchedule(
        id: any(named: 'id'),
        title: any(named: 'title'),
        body: any(named: 'body'),
        scheduledDate: any(named: 'scheduledDate'),
        notificationDetails: any(named: 'notificationDetails'),
        androidScheduleMode: captureAny(named: 'androidScheduleMode'),
        matchDateTimeComponents: captureAny(named: 'matchDateTimeComponents'),
        payload: any(named: 'payload'),
      ),
    ).captured;

    expect(captured[0], AndroidScheduleMode.inexactAllowWhileIdle);
    expect(captured[1], DateTimeComponents.time);
  });
}
