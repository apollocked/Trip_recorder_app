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
    tz_data.initializeTimeZones();
    const android = AndroidInitializationSettings('@mipmap/launcher_icon');
    const settings = InitializationSettings(android: android);
    await _plugin.initialize(settings: settings);
    _initialized = true;
  }

  Future<void> scheduleTripReminder({
    required String tripId,
    required String tripTitle,
    required DateTime remindAt,
    String? body,
    String? channelName,
  }) async {
    await init();
    final androidDetails = AndroidNotificationDetails(
      'trip_reminders',
      channelName ?? 'Trip Reminders',
      importance: Importance.high,
      priority: Priority.high,
    );
    final details = NotificationDetails(android: androidDetails);

    final scheduledDate = tz.TZDateTime.from(remindAt, tz.local);
    if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) return;

    await _plugin.zonedSchedule(
      id: tripId.hashCode,
      title: 'Upcoming Trip',
      body: body ?? '$tripTitle is coming up!',
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
    final androidDetails = AndroidNotificationDetails(
      'trip_reminders',
      'Trip Reminders',
      importance: Importance.high,
      priority: Priority.high,
    );
    final details = NotificationDetails(android: androidDetails);

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
