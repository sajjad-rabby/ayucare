import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// Daily on-device reminders. No server, no account, no location permission:
/// times resolve in the DEVICE timezone. Users can add multiple reminders at
/// any 12-hour time; each is scheduled daily. Inexact scheduling only.
class ReminderItem {
  ReminderItem({
    required this.id,
    required this.title,
    required this.body,
    required this.hour,
    required this.minute,
    required this.enabled,
    required this.kind,
  });

  final String id, title, body;
  final int hour, minute;
  final bool enabled;
  final String kind; // water | exercise | custom

  /// Always 12-hour, regardless of device clock setting.
  String get time12 {
    final h12 = hour % 12 == 0 ? 12 : hour % 12;
    final ap = hour < 12 ? 'AM' : 'PM';
    return '$h12:${minute.toString().padLeft(2, '0')} $ap';
  }

  IconData get icon => switch (kind) {
        'water' => Icons.water_drop_outlined,
        'exercise' => Icons.fitness_center_outlined,
        _ => Icons.notifications_outlined,
      };

  Map<String, Object?> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'hour': hour,
        'minute': minute,
        'enabled': enabled,
        'kind': kind,
      };

  factory ReminderItem.fromJson(Map<String, Object?> j) => ReminderItem(
        id: j['id'] as String,
        title: j['title'] as String,
        body: j['body'] as String,
        hour: (j['hour'] as num).toInt(),
        minute: (j['minute'] as num).toInt(),
        enabled: j['enabled'] as bool,
        kind: j['kind'] as String,
      );
}

class ReminderService {
  ReminderService._();
  static final plugin = FlutterLocalNotificationsPlugin();
  static const _kList = 'reminders.v2';
  static const maxReminders = 8;

  static List<ReminderItem> _defaults() => [
        ReminderItem(
            id: 'water-evening',
            title: 'AyuCare · Water check-in',
            body:
                'Did you drink enough water today? A glass now keeps you steady.',
            hour: 20,
            minute: 0,
            enabled: true,
            kind: 'water'),
        ReminderItem(
            id: 'exercise-morning',
            title: 'AyuCare · Move a little',
            body: 'Time for today\u2019s movement — even a short walk counts.',
            hour: 7,
            minute: 0,
            enabled: true,
            kind: 'exercise'),
      ];

  static Future<List<ReminderItem>> load() async {
    final raw = (await SharedPreferences.getInstance()).getStringList(_kList);
    if (raw == null) {
      final d = _defaults();
      await save(d);
      return d;
    }
    return raw
        .map((s) => ReminderItem.fromJson(
            (jsonDecode(s) as Map).cast<String, Object?>()))
        .toList();
  }

  static Future<void> save(List<ReminderItem> items) async {
    (await SharedPreferences.getInstance()).setStringList(
        _kList, items.map((e) => jsonEncode(e.toJson())).toList());
  }

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
    await rescheduleAll(await load());
  }

  static Future<bool> requestPermission() async {
    // try/catch: widget tests register no platform implementation, and
    // some OEM ROMs throw here. Permission denial must never crash UI.
    try {
      final android = plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      return await android?.requestNotificationsPermission() ?? false;
    } catch (_) {
      return false;
    }
  }

  static tz.TZDateTime _next(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var at =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (at.isBefore(now)) at = at.add(const Duration(days: 1));
    return at;
  }

  /// Cancel everything we own, then schedule enabled items (ids 200+index).
  static Future<void> rescheduleAll(List<ReminderItem> items) async {
    for (var i = 0; i < maxReminders; i++) {
      await plugin.cancel(id: 200 + i);
    }
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'ayucare_daily',
        'Daily health reminders',
        importance: Importance.defaultImportance,
      ),
    );
    var slot = 0;
    for (final r in items) {
      if (!r.enabled || slot >= maxReminders) continue;
      await plugin.zonedSchedule(
        id: 200 + slot,
        title: r.title,
        body: r.body,
        scheduledDate: _next(r.hour, r.minute),
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
      slot++;
    }
  }

  static String get zoneName {
    try {
      return tz.local.name;
    } catch (_) {
      return 'device timezone';
    }
  }

  /// One-shot reminder for todo lists (exact local date-time, daily range
  /// 1000..1999 to avoid clashing with daily slots 200+).
  static Future<void> scheduleOneShot({
    required int id,
    required String title,
    required String body,
    required DateTime at,
  }) async {
    final when = tz.TZDateTime.from(at, tz.local);
    if (when.isBefore(tz.TZDateTime.now(tz.local))) return;
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'ayucare_todo',
        'Todo reminders',
        importance: Importance.defaultImportance,
      ),
    );
    await plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: when,
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  static Future<void> cancelOneShot(int id) => plugin.cancel(id: id);
}
