import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart' as ftz;
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    try {
      tz_data.initializeTimeZones();
      await _setLocalTimezone();

      const android = AndroidInitializationSettings('ic_notification');
      const settings = InitializationSettings(android: android);
      await _plugin.initialize(settings: settings);
      _initialized = true;
    } catch (e) {
      debugPrint('NotificationService.init error: $e');
    }
  }

  Future<void> _setLocalTimezone() async {
    try {
      final timezoneName = await ftz.FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timezoneName));
      debugPrint('Timezone set to: $timezoneName');
    } catch (e) {
      debugPrint('Failed to detect local timezone, using default (UTC): $e');
    }
  }

  AndroidNotificationDetails _details() => const AndroidNotificationDetails(
        'trip_reminders',
        'Trip Reminders',
        channelDescription: 'Reminders for your upcoming trips',
        importance: Importance.high,
        priority: Priority.high,
        icon: 'ic_notification',
        category: AndroidNotificationCategory.reminder,
        visibility: NotificationVisibility.public,
        showWhen: true,
        enableVibration: true,
        playSound: true,
      );

  Future<void> _schedule({
    required int id,
    required String title,
    required String body,
    required DateTime dateTime,
  }) async {
    await init();
    final details = NotificationDetails(android: _details());
    final scheduledDate = tz.TZDateTime.from(dateTime, tz.local);
    if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) return;

    final modes = [
      AndroidScheduleMode.alarmClock,
      AndroidScheduleMode.exactAllowWhileIdle,
      AndroidScheduleMode.inexactAllowWhileIdle,
    ];

    for (final mode in modes) {
      try {
        await _plugin.zonedSchedule(
          id: id,
          title: title,
          body: body,
          scheduledDate: scheduledDate,
          notificationDetails: details,
          androidScheduleMode: mode,
        );
        return;
      } catch (e) {
        debugPrint('$mode failed: $e');
      }
    }
  }

  Future<void> scheduleUserReminder({
    required String tripId,
    required DateTime remindAt,
    required String title,
    required String body,
  }) async {
    await _schedule(
      id: tripId.hashCode,
      title: title,
      body: body,
      dateTime: remindAt,
    );
  }

  Future<void> schedulePreTripReminder({
    required String tripId,
    required String tripTitle,
    required DateTime tripDate,
  }) async {
    final remindAt = tripDate.subtract(const Duration(days: 1));
    await _schedule(
      id: tripId.hashCode + 1,
      title: 'Trip Reminder',
      body: '$tripTitle starts tomorrow! Prepare your items.',
      dateTime: remindAt,
    );
  }

  Future<void> scheduleOnDayReminder({
    required String tripId,
    required String tripTitle,
    required DateTime tripDate,
  }) async {
    await _schedule(
      id: tripId.hashCode + 2,
      title: tripTitle,
      body: 'Your trip is today! Add photos and details to save your memories.',
      dateTime: tripDate,
    );
  }

  Future<void> cancelTripReminder(String tripId) async {
    if (!_initialized) await init();
    await _plugin.cancel(id: tripId.hashCode);
    await _plugin.cancel(id: tripId.hashCode + 1);
    await _plugin.cancel(id: tripId.hashCode + 2);
  }
}
