import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// Daily on-device reminders. No server, no account, no location permission:
/// times are resolved in the DEVICE timezone (location-aware enough without GPS).
/// Water nudge 8 PM local, exercise nudge 7 AM local. Inexact scheduling —
/// no exact-alarm permission needed.
class ReminderService {
  ReminderService._();
  static final plugin = FlutterLocalNotificationsPlugin();

  static const waterId = 101;
  static const exerciseId = 102;
  static const waterHour = 20, waterMinute = 0;
  static const exerciseHour = 7, exerciseMinute = 0;
  static const _kWater = 'remind.water';
  static const _kExercise = 'remind.exercise';

  static Future<bool> get waterOn async =>
      (await SharedPreferences.getInstance()).getBool(_kWater) ?? true;
  static Future<bool> get exerciseOn async =>
      (await SharedPreferences.getInstance()).getBool(_kExercise) ?? true;

  static Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    await plugin.initialize(
        settings: const InitializationSettings(android: android));
    tzdata.initializeTimeZones();
    try {
      final info = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(info.identifier));
    } catch (_) {
      tz.setLocalLocation(tz.getLocation('Asia/Dhaka'));
    }
    if (await waterOn) await scheduleWater();
    if (await exerciseOn) await scheduleExercise();
  }

  static Future<bool> requestPermission() async {
    final android = plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    return await android?.requestNotificationsPermission() ?? false;
  }

  static tz.TZDateTime _next(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var at =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (at.isBefore(now)) at = at.add(const Duration(days: 1));
    return at;
  }

  static Future<void> _daily({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'ayucare_daily',
        'Daily health reminders',
        importance: Importance.defaultImportance,
      ),
    );
    await plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: _next(hour, minute),
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static Future<void> scheduleWater() => _daily(
        id: waterId,
        title: 'AyuCare · Water check-in',
        body: 'Did you drink enough water today? A glass now keeps you steady.',
        hour: waterHour,
        minute: waterMinute,
      );

  static Future<void> scheduleExercise() => _daily(
        id: exerciseId,
        title: 'AyuCare · Move a little',
        body: 'Time for today\u2019s movement — even a short walk counts.',
        hour: exerciseHour,
        minute: exerciseMinute,
      );

  static Future<void> setWater(bool on) async {
    (await SharedPreferences.getInstance()).setBool(_kWater, on);
    on ? await scheduleWater() : await plugin.cancel(id: waterId);
  }

  static Future<void> setExercise(bool on) async {
    (await SharedPreferences.getInstance()).setBool(_kExercise, on);
    on ? await scheduleExercise() : await plugin.cancel(id: exerciseId);
  }

  static String get zoneName => tz.local.name;
}
