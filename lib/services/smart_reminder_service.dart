import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rooted/models/reminder_settings.dart';
import 'package:rooted/services/local_storage_service.dart';
import 'package:rooted/services/streak_service.dart';
import 'package:rooted/services/reading_plan_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class SmartReminderService {
  static const String _settingsKey = 'reminder_settings';
  static const int _dailyReadingNotificationId = 10001;
  static const int _streakWarningNotificationId = 10002;
  static const int _weeklyProgressNotificationId = 10003;
  static const int _missedActivityNotificationId = 10004;

  static SharedPreferences? _prefs;
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> _ensurePrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Get reminder settings
  static Future<ReminderSettings> getSettings() async {
    await _ensurePrefs();
    final jsonString = _prefs!.getString(_settingsKey);

    if (jsonString == null) {
      return ReminderSettings();
    }

    try {
      final Map<String, dynamic> json =
          jsonDecode(jsonString) as Map<String, dynamic>;
      return ReminderSettings.fromJson(json);
    } catch (e) {
      return ReminderSettings();
    }
  }

  /// Save reminder settings
  static Future<void> saveSettings(ReminderSettings settings) async {
    await _ensurePrefs();
    await _prefs!.setString(_settingsKey, jsonEncode(settings.toJson()));

    // Reschedule all reminders with new settings
    await scheduleAllReminders();
  }

  /// Schedule all enabled reminders
  static Future<void> scheduleAllReminders() async {
    // Skip on web platform
    if (kIsWeb) {
      debugPrint('Skipping smart reminders on web platform');
      return;
    }

    final settings = await getSettings();

    // Cancel all existing reminders first
    await _cancelAllSmartReminders();

    // Schedule daily reading reminder
    if (settings.dailyReadingEnabled) {
      await _scheduleDailyReadingReminder(
        settings.dailyReadingHour,
        settings.dailyReadingMinute,
      );
    }

    // Schedule weekly progress summary
    if (settings.weeklyProgressEnabled) {
      await _scheduleWeeklyProgressReminder(
        settings.weeklyProgressDay,
        settings.weeklyProgressHour,
        settings.weeklyProgressMinute,
      );
    }

    // Streak preservation will be checked dynamically
    debugPrint('Scheduled all smart reminders');
  }

  /// Schedule daily reading reminder
  static Future<void> _scheduleDailyReadingReminder(
      int hour, int minute) async {
    if (kIsWeb) return;

    try {
      final now = DateTime.now();
      var scheduledDate = DateTime(now.year, now.month, now.day, hour, minute);

      // If the time has passed today, schedule for tomorrow
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      const androidDetails = AndroidNotificationDetails(
        'daily_reading_channel',
        'Daily Reading Reminders',
        channelDescription: 'Reminders to read the Bible daily',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.zonedSchedule(
        _dailyReadingNotificationId,
        '📖 Time for Bible Reading',
        'Take a few moments to read God\'s Word today',
        tz.TZDateTime.from(scheduledDate, tz.local),
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time, // Repeat daily
      );

      debugPrint('Scheduled daily reading reminder for $hour:$minute');
    } catch (e) {
      debugPrint('Error scheduling daily reading reminder: $e');
    }
  }

  /// Schedule weekly progress summary
  static Future<void> _scheduleWeeklyProgressReminder(
    DayOfWeek day,
    int hour,
    int minute,
  ) async {
    if (kIsWeb) return;

    try {
      final now = DateTime.now();
      final targetWeekday = day.weekdayNumber;

      // Calculate days until target weekday
      int daysUntil = (targetWeekday - now.weekday) % 7;
      if (daysUntil == 0) {
        // Today is the day - check if time has passed
        final todayTime = DateTime(now.year, now.month, now.day, hour, minute);
        if (todayTime.isBefore(now)) {
          daysUntil = 7; // Schedule for next week
        }
      }

      final scheduledDate = DateTime(now.year, now.month, now.day, hour, minute)
          .add(Duration(days: daysUntil));

      const androidDetails = AndroidNotificationDetails(
        'weekly_progress_channel',
        'Weekly Progress Summary',
        channelDescription: 'Weekly summary of your spiritual progress',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.zonedSchedule(
        _weeklyProgressNotificationId,
        '📊 Your Weekly Progress',
        'See how you did this week in your spiritual journey',
        tz.TZDateTime.from(scheduledDate, tz.local),
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );

      debugPrint(
          'Scheduled weekly progress reminder for ${day.displayName} $hour:$minute');
    } catch (e) {
      debugPrint('Error scheduling weekly progress reminder: $e');
    }
  }

  /// Check and send streak preservation alert
  static Future<void> checkStreakPreservation() async {
    if (kIsWeb) return;

    final settings = await getSettings();
    if (!settings.streakPreservationEnabled) return;

    try {
      final streak = await StreakService.getStreak();

      // Only warn if there's an active streak
      if (streak.currentStreak < 3) return;

      // Check if user has read today
      if (streak.hasReadToday()) return;

      // Check if we're within the warning window
      final now = DateTime.now();
      final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
      final hoursUntilEnd = endOfDay.difference(now).inHours;

      if (hoursUntilEnd <= settings.streakWarningHours && hoursUntilEnd > 0) {
        await _sendStreakWarningNotification(
            streak.currentStreak, hoursUntilEnd);
      }
    } catch (e) {
      debugPrint('Error checking streak preservation: $e');
    }
  }

  /// Send streak warning notification
  static Future<void> _sendStreakWarningNotification(
    int currentStreak,
    int hoursRemaining,
  ) async {
    if (kIsWeb) return;

    try {
      const androidDetails = AndroidNotificationDetails(
        'streak_warning_channel',
        'Streak Preservation',
        channelDescription: 'Alerts to help maintain your reading streak',
        importance: Importance.max,
        priority: Priority.max,
        icon: '@mipmap/ic_launcher',
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.show(
        _streakWarningNotificationId,
        '🔥 Don\'t Break Your Streak!',
        'You have a $currentStreak-day streak! Read the Bible in the next $hoursRemaining hours to keep it going.',
        details,
      );

      debugPrint('Sent streak warning notification');
    } catch (e) {
      debugPrint('Error sending streak warning: $e');
    }
  }

  /// Check for missed activities and send notification
  static Future<void> checkMissedActivities() async {
    if (kIsWeb) return;

    final settings = await getSettings();
    if (!settings.missedActivityEnabled) return;

    try {
      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(days: 1));

      // Check Bible readings
      final readings = await LocalStorageService.getBibleReadings();
      final yesterdayReadings = readings
          .where((r) =>
              r.dateRead.year == yesterday.year &&
              r.dateRead.month == yesterday.month &&
              r.dateRead.day == yesterday.day)
          .toList();

      // Check active reading plan
      final activePlan = await ReadingPlanService.getActivePlan();

      if (yesterdayReadings.isEmpty && activePlan != null) {
        await _sendMissedActivityNotification();
      }
    } catch (e) {
      debugPrint('Error checking missed activities: $e');
    }
  }

  /// Send missed activity notification
  static Future<void> _sendMissedActivityNotification() async {
    if (kIsWeb) return;

    try {
      const androidDetails = AndroidNotificationDetails(
        'missed_activity_channel',
        'Missed Activity Reminders',
        channelDescription: 'Reminders when you miss a reading',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.show(
        _missedActivityNotificationId,
        '📅 You Missed Yesterday\'s Reading',
        'It\'s okay! Get back on track today with your Bible reading.',
        details,
      );

      debugPrint('Sent missed activity notification');
    } catch (e) {
      debugPrint('Error sending missed activity notification: $e');
    }
  }

  /// Generate and send weekly progress summary
  static Future<void> sendWeeklyProgressSummary() async {
    if (kIsWeb) return;

    try {
      final now = DateTime.now();
      final weekAgo = now.subtract(const Duration(days: 7));

      // Get this week's readings
      final readings = await LocalStorageService.getBibleReadings();
      final weekReadings =
          readings.where((r) => r.dateRead.isAfter(weekAgo)).toList();

      // Calculate stats
      final daysRead = weekReadings.length;
      final totalMinutes =
          weekReadings.fold<int>(0, (sum, r) => sum + r.minutesSpent);
      final streak = await StreakService.getStreak();

      String message;
      if (daysRead == 0) {
        message = 'No readings this week. Let\'s start fresh!';
      } else if (daysRead == 7) {
        message =
            'Perfect week! 7 days of reading, $totalMinutes minutes total. Current streak: ${streak.currentStreak} days 🔥';
      } else {
        message =
            '$daysRead days of reading, $totalMinutes minutes total. Current streak: ${streak.currentStreak} days';
      }

      const androidDetails = AndroidNotificationDetails(
        'weekly_progress_channel',
        'Weekly Progress Summary',
        channelDescription: 'Weekly summary of your spiritual progress',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.show(
        _weeklyProgressNotificationId,
        '📊 Your Week in Review',
        message,
        details,
      );

      debugPrint('Sent weekly progress summary');
    } catch (e) {
      debugPrint('Error sending weekly progress summary: $e');
    }
  }

  /// Cancel all smart reminders
  static Future<void> _cancelAllSmartReminders() async {
    if (kIsWeb) return;

    try {
      await _notifications.cancel(_dailyReadingNotificationId);
      await _notifications.cancel(_weeklyProgressNotificationId);
      await _notifications.cancel(_streakWarningNotificationId);
      await _notifications.cancel(_missedActivityNotificationId);
      debugPrint('Cancelled all smart reminders');
    } catch (e) {
      debugPrint('Error cancelling smart reminders: $e');
    }
  }

  /// Initialize reminders on app start
  static Future<void> initialize() async {
    if (kIsWeb) {
      debugPrint('Smart reminders not supported on web');
      return;
    }

    await scheduleAllReminders();

    // Check streak preservation and missed activities
    await checkStreakPreservation();
    await checkMissedActivities();
  }
}
