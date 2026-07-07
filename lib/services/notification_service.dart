import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
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
      const android = AndroidInitializationSettings('ic_notification');
      const settings = InitializationSettings(android: android);
      await _plugin.initialize(settings: settings);
      _initialized = true;
    } catch (e) {
      debugPrint('NotificationService.init error: $e');
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

  Future<void> scheduleTripReminder({
    required String tripId,
    required String tripTitle,
    required DateTime remindAt,
    required String title,
    required String body,
    String? channelName,
  }) async {
    await init();
    final details = NotificationDetails(android: _details());

    final scheduledDate = tz.TZDateTime.from(remindAt, tz.local);
    if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) return;

    await _plugin.zonedSchedule(
      id: tripId.hashCode,
      title: title,
      body: body,
      scheduledDate: scheduledDate,
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  Future<void> schedulePreTripReminder({
    required String tripId,
    required String tripTitle,
    required DateTime tripDate,
  }) async {
    final remindAt = tripDate.subtract(const Duration(days: 1));
    await scheduleTripReminder(
      tripId: tripId,
      tripTitle: tripTitle,
      remindAt: remindAt,
      title: 'Trip Reminder',
      body: '$tripTitle starts tomorrow! Prepare your items.',
      channelName: 'Trip Reminders',
    );
  }

  Future<void> scheduleOnDayReminder({
    required String tripId,
    required String tripTitle,
    required DateTime tripDate,
  }) async {
    await init();
    final details = NotificationDetails(android: _details());

    final scheduledDate = tz.TZDateTime.from(tripDate, tz.local);
    if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) return;

    await _plugin.zonedSchedule(
      id: tripId.hashCode + 2,
      title: tripTitle,
      body: 'Your trip is today! Add photos and details to save your memories.',
      scheduledDate: scheduledDate,
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  Future<void> cancelTripReminder(String tripId) async {
    if (!_initialized) await init();
    await _plugin.cancel(id: tripId.hashCode);
    await _plugin.cancel(id: tripId.hashCode + 2);
  }
}
