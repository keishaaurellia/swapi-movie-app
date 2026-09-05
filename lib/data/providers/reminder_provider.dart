import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/reminder.dart';

List<Reminder> _parseRemindersFromJson(List<String> rawList) {
  final List<Reminder> result = [];
  for (final item in rawList) {
    try {
      final Map<String, dynamic> map =
          jsonDecode(item) as Map<String, dynamic>;
      result.add(Reminder.fromJson(map));
    } catch (_) {}
  }
  return result;
}

List<String> _encodeRemindersToJson(List<Reminder> reminders) =>
    reminders.map((r) => jsonEncode(r.toJson())).toList();

class ReminderProvider {
  static const String _storageKey = 'user_cinema_reminders_list';
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  bool _isNotificationInitialized = false;
  bool _isStorageLoaded = false;

  final List<Reminder> _reminders = [];

  Future<void> initNotification() async {
    if (_isNotificationInitialized) return;

    try {
      tz.initializeTimeZones();

      final now = DateTime.now();
      final offsetMs = now.timeZoneOffset.inMilliseconds;
      for (final loc in tz.timeZoneDatabase.locations.values) {
        if (loc.currentTimeZone.offset == offsetMs) {
          tz.setLocalLocation(loc);
          break;
        }
      }

      const androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const darwinSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
        defaultPresentAlert: true,
        defaultPresentSound: true,
        defaultPresentBanner: true,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
        macOS: darwinSettings,
      );

      await _notificationsPlugin.initialize(initSettings);

      final androidPlugin = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        await androidPlugin.requestNotificationsPermission();
        await androidPlugin.requestExactAlarmsPermission();
      }

      _isNotificationInitialized = true;
    } catch (e) {
      debugPrint('ReminderProvider notification init error: $e');
    }
  }

  Future<void> _loadFromStorage() async {
    if (_isStorageLoaded) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> rawList = prefs.getStringList(_storageKey) ?? [];
      final parsed = await compute(_parseRemindersFromJson, rawList);
      for (final reminder in parsed) {
        if (!_reminders.any((r) => r.id == reminder.id)) {
          _reminders.add(reminder);
        }
      }
      _isStorageLoaded = true;
    } catch (_) {
      _isStorageLoaded = true;
    }
  }

  Future<void> _saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> rawList =
          await compute(_encodeRemindersToJson, List<Reminder>.from(_reminders));
      await prefs.setStringList(_storageKey, rawList);
    } catch (_) {}
  }

  Future<List<Reminder>> getReminders() async {
    await _loadFromStorage();
    return List.unmodifiable(_reminders);
  }

  NotificationDetails _buildNotificationDetails() {
    const androidDetails = AndroidNotificationDetails(
      'movie_reminder_alarm_channel_v1',
      'Movie Showtime Reminder',
      channelDescription: 'Notifications and sound alarms for movie schedules',
      importance: Importance.max,
      priority: Priority.max,
      playSound: true,
      enableVibration: true,
      channelShowBadge: true,
      category: AndroidNotificationCategory.alarm,
    );
    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      presentBanner: true,
      presentList: true,
    );
    return const NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
    );
  }

  Future<void> addReminder(Reminder reminder) async {
    await _loadFromStorage();
    _reminders.removeWhere((r) => r.id == reminder.id);
    _reminders.add(reminder);
    await _saveToStorage();

    await initNotification();

    try {
      final int notificationId = reminder.id.hashCode.abs() % 100000;
      final DateTime triggerDateTime = reminder.notificationTime;
      final tzTrigger =
          tz.TZDateTime.from(triggerDateTime, tz.local);

      final notificationDetails = _buildNotificationDetails();

      final String timeLabel = reminder.leadTimeMinutes > 0
          ? 'in ${reminder.leadTimeMinutes} minutes'
          : 'now';
      final String bodyText =
          '${reminder.movieTitle} starts $timeLabel at ${reminder.cinemaName}. Don\'t be late!';

      if (tzTrigger.isAfter(tz.TZDateTime.now(tz.local))) {
        try {
          await _notificationsPlugin.zonedSchedule(
            notificationId,
            'Movie Showtime Approaching!',
            bodyText,
            tzTrigger,
            notificationDetails,
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
          );
        } catch (_) {
          await _notificationsPlugin.zonedSchedule(
            notificationId,
            'Movie Showtime Approaching!',
            bodyText,
            tzTrigger,
            notificationDetails,
            androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
          );
        }
      } else {
        await _notificationsPlugin.show(
          notificationId,
          'Movie Showtime Approaching!',
          bodyText,
          notificationDetails,
        );
      }
    } catch (e) {
      debugPrint('Schedule notification error: $e');
    }
  }

  Future<void> showInstantConfirmation(String movieTitle, String cinemaName) async {
    await initNotification();
    final notificationDetails = _buildNotificationDetails();
    try {
      await _notificationsPlugin.show(
        (DateTime.now().millisecondsSinceEpoch ~/ 1000) % 100000,
        'Reminder Activated Successfully!',
        'Alarm for $movieTitle at $cinemaName is active & ready.',
        notificationDetails,
      );
    } catch (e) {
      debugPrint('Instant confirmation notification error: $e');
    }
  }

  Future<void> sendTestNotification({int secondsDelay = 5}) async {
    await initNotification();
    final notificationDetails = _buildNotificationDetails();
    final triggerTime =
        tz.TZDateTime.now(tz.local).add(Duration(seconds: secondsDelay));

    try {
      await _notificationsPlugin.zonedSchedule(
        88888,
        'Movie Showtime Approaching!',
        'Test notification & alarm succeeded! Don\'t be late.',
        triggerTime,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (_) {
      try {
        await _notificationsPlugin.zonedSchedule(
          88888,
          'Movie Showtime Approaching!',
          'Test notification & alarm succeeded! Don\'t be late.',
          triggerTime,
          notificationDetails,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
      } catch (_) {
        await _notificationsPlugin.show(
          88888,
          'Movie Showtime Approaching!',
          'Instant notification & alarm test succeeded!',
          notificationDetails,
        );
      }
    }
  }

  Future<void> deleteReminder(String id) async {
    await _loadFromStorage();
    _reminders.removeWhere((r) => r.id == id);
    await _saveToStorage();

    try {
      final int notificationId = id.hashCode.abs() % 100000;
      await _notificationsPlugin.cancel(notificationId);
    } catch (_) {}
  }
}
