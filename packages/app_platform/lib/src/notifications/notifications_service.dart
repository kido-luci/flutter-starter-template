import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:injectable/injectable.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../permissions/permission_service.dart';

/// Thin wrapper around [FlutterLocalNotificationsPlugin].
///
/// Call [init] once during app bootstrap (from `main`). Permission prompts
/// are issued on demand via [requestPermissions]; on Android 13+ this is
/// required before any notification will surface.
@lazySingleton
class NotificationsService {
  NotificationsService(this._plugin, this._permissions);

  final FlutterLocalNotificationsPlugin _plugin;
  final PermissionService _permissions;

  /// Android notification channel used for general app notifications.
  /// Must match what's registered in [init] before posting.
  static const AndroidNotificationChannel _defaultChannel =
      AndroidNotificationChannel(
        'default_channel',
        'General',
        description: 'General app notifications',
        importance: Importance.defaultImportance,
      );

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    // Load the IANA database and pin `tz.local` to the device's zone. Without
    // this `tz.local` is UTC, so [scheduleDaily] would fire at the wrong wall
    // time for everyone outside it.
    tz_data.initializeTimeZones();
    final localZone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(localZone.identifier));

    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
      macOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );
    await _plugin.initialize(settings: initSettings);
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_defaultChannel);
    _initialized = true;
  }

  /// Asks the user for permission to show notifications.
  Future<bool> requestPermissions() =>
      _permissions.requestNotificationPermission();

  /// Shows a one-off notification on the default channel.
  Future<void> show({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) {
    return _plugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _defaultChannel.id,
          _defaultChannel.name,
          channelDescription: _defaultChannel.description,
          importance: _defaultChannel.importance,
        ),
        iOS: const DarwinNotificationDetails(),
        macOS: const DarwinNotificationDetails(),
      ),
      payload: payload,
    );
  }

  /// Schedules [id] to fire every day at [hour]:[minute] device-local time.
  ///
  /// Scheduling the same [id] again replaces the pending one, so calling this
  /// whenever the user picks a new time needs no [cancel] first. The schedule
  /// survives reboots on both platforms; it does not survive an app
  /// reinstall, so re-arm it on startup from whatever stores the preference.
  ///
  /// [init] must have run first — it pins the local timezone.
  ///
  /// Android uses an inexact alarm so the app needs no `SCHEDULE_EXACT_ALARM`
  /// permission (Google rejects it for anything but alarms and calendars).
  /// Delivery may drift by a few minutes, which is the right trade for a
  /// reminder; a wake-the-user alarm would need [AndroidScheduleMode.alarmClock]
  /// and that permission.
  Future<void> scheduleDaily({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    String? payload,
  }) {
    return _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: _nextInstanceOf(hour: hour, minute: minute),
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _defaultChannel.id,
          _defaultChannel.name,
          channelDescription: _defaultChannel.description,
          importance: _defaultChannel.importance,
        ),
        iOS: const DarwinNotificationDetails(),
        macOS: const DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      // Repeats daily by matching only the time-of-day components.
      matchDateTimeComponents: DateTimeComponents.time,
      payload: payload,
    );
  }

  /// The next [hour]:[minute] in the device's zone — today when it is still
  /// ahead, otherwise tomorrow.
  ///
  /// Uses `!isAfter` rather than `isBefore` so scheduling for the current
  /// minute lands tomorrow instead of firing immediately.
  static tz.TZDateTime _nextInstanceOf({
    required int hour,
    required int minute,
  }) {
    final now = tz.TZDateTime.now(tz.local);
    final today = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    return today.isAfter(now) ? today : today.add(const Duration(days: 1));
  }

  Future<void> cancel(int id) => _plugin.cancel(id: id);

  Future<void> cancelAll() => _plugin.cancelAll();
}
