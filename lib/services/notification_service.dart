import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/painting.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static const String _channelKey = 'trip_reminders';

  Future<void> init({String? channelName, String? channelDesc}) async {
    await AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelKey: _channelKey,
          channelName: channelName ?? 'Trip Reminders',
          channelDescription: channelDesc ?? 'Trip reminder notifications',
          defaultColor: const Color(0xFF6C63FF),
          importance: NotificationImportance.High,
          channelShowBadge: true,
          locked: false,
          groupKey: 'trip_reminders_group',
          defaultPrivacy: NotificationPrivacy.Private,
        ),
      ],
    );
  }

  Future<void> scheduleTripReminder({
    required String tripId,
    required String tripTitle,
    required DateTime remindAt,
    String? title,
    String? body,
  }) async {
    final id = _notificationId(tripId, 0);
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: _channelKey,
        title: title ?? 'Upcoming Trip',
        body: body ?? '$tripTitle is coming up!',
        notificationLayout: NotificationLayout.Default,
        displayOnForeground: true,
        displayOnBackground: true,
        payload: {'tripId': tripId},
      ),
      schedule: NotificationCalendar.fromDate(
        date: remindAt,
        preciseAlarm: true,
        allowWhileIdle: true,
      ),
    );
  }

  Future<void> schedulePreTripReminder({
    required String tripId,
    required String tripTitle,
    required DateTime tripDate,
    String? title,
    String? body,
  }) async {
    final remindAt = tripDate.subtract(const Duration(days: 1));
    if (remindAt.isBefore(DateTime.now())) return;
    await scheduleTripReminder(
      tripId: tripId,
      tripTitle: tripTitle,
      remindAt: remindAt,
      title: title ?? 'Upcoming Trip',
      body: body ?? '$tripTitle starts tomorrow! Prepare your items.',
    );
  }

  Future<void> scheduleOnDayReminder({
    required String tripId,
    required String tripTitle,
    required DateTime tripDate,
    String? title,
    String? body,
  }) async {
    if (tripDate.isBefore(DateTime.now())) return;
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: _notificationId(tripId, 2),
        channelKey: _channelKey,
        title: title ?? tripTitle,
        body: body ?? 'Your trip is today! Add photos and details to save your memories.',
        notificationLayout: NotificationLayout.Default,
        displayOnForeground: true,
        displayOnBackground: true,
        payload: {'tripId': tripId},
      ),
      schedule: NotificationCalendar.fromDate(
        date: tripDate,
        preciseAlarm: true,
        allowWhileIdle: true,
      ),
    );
  }

  Future<void> cancelTripReminder(String tripId) async {
    await AwesomeNotifications().cancel(_notificationId(tripId, 0));
    await AwesomeNotifications().cancel(_notificationId(tripId, 2));
  }

  static int _notificationId(String tripId, int offset) {
    final id = tripId.hashCode.toUnsigned(31);
    return id + offset;
  }
}
