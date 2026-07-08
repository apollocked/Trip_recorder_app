import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  Future<void> init() async {
    debugPrint('NotificationService: init');
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    debugPrint('NotificationService: isAllowed=$isAllowed');
    if (!isAllowed) {
      await AwesomeNotifications().requestPermissionToSendNotifications();
    }
  }

  Future<void> _scheduleNativeAlarm({
    required int notificationId,
    required String title,
    required String body,
    required DateTime targetDate,
  }) async {
    debugPrint('_scheduleNativeAlarm: id=$notificationId title=$title target=$targetDate');
    try {
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: notificationId,
          channelKey: 'trip_reminders',
          title: title,
          body: body,
          wakeUpScreen: true,
          category: NotificationCategory.Reminder,
        ),
        schedule: NotificationCalendar(
          year: targetDate.year,
          month: targetDate.month,
          day: targetDate.day,
          hour: targetDate.hour,
          minute: targetDate.minute,
          second: 0,
          preciseAlarm: true,
          allowWhileIdle: true,
        ),
      );
      debugPrint('_scheduleNativeAlarm: success');
    } catch (e) {
      debugPrint('_scheduleNativeAlarm: error=$e');
    }
  }

  Future<void> scheduleUserReminder({
    required String tripId,
    required DateTime remindAt,
    required String title,
    required String body,
  }) async {
    if (remindAt.isBefore(DateTime.now())) return;
    await _scheduleNativeAlarm(
      notificationId: tripId.hashCode,
      title: title,
      body: body,
      targetDate: remindAt,
    );
  }

  Future<void> schedulePreTripReminder({
    required String tripId,
    required String title,
    required String body,
    required DateTime tripDate,
  }) async {
    final remindAt = tripDate.subtract(const Duration(days: 1));
    if (remindAt.isBefore(DateTime.now())) return;
    await _scheduleNativeAlarm(
      notificationId: tripId.hashCode + 1,
      title: title,
      body: body,
      targetDate: remindAt,
    );
  }

  Future<void> scheduleOnDayReminder({
    required String tripId,
    required String title,
    required String body,
    required DateTime tripDate,
  }) async {
    if (tripDate.isBefore(DateTime.now())) return;
    await _scheduleNativeAlarm(
      notificationId: tripId.hashCode + 2,
      title: title,
      body: body,
      targetDate: tripDate,
    );
  }

  Future<void> cancelTripReminder(String tripId) async {
    await AwesomeNotifications().cancel(tripId.hashCode);
    await AwesomeNotifications().cancel(tripId.hashCode + 1);
    await AwesomeNotifications().cancel(tripId.hashCode + 2);
  }
}
