import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:rooted/models/prayer_schedule.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz_data;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  /// Initialize the notification service
  /// Must be called before app startup completes
  static Future<bool> initialize() async {
    // Skip initialization on web platform
    if (kIsWeb) {
      debugPrint('Notification service not supported on web platform');
      _initialized = false;
      return false;
    }
    
    if (_initialized) return true;

    // Initialize timezone database
    tz_data.initializeTimeZones();

    // Android initialization settings
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization settings
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // Combined initialization settings
    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // Initialize the plugin
    try {
      final bool? initialized = await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      if (initialized != true) {
        debugPrint('Failed to initialize notifications');
        _initialized = false;
        return false;
      }

      // Request permissions (required for Android 13+)
      await _requestPermissions();

      _initialized = true;
      debugPrint('Notification service initialized');
      return true;
    } catch (e) {
      debugPrint('Error initializing notification service: $e');
      _initialized = false;
      return false;
    }
  }

  /// Request notification permissions (especially important for Android 13+)
  static Future<void> _requestPermissions() async {
    // Android 13+ requires explicit permission
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _notifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      await androidImplementation.requestNotificationsPermission();
    }

    // iOS permissions are automatically requested via DarwinInitializationSettings
    // (requestAlertPermission, requestBadgePermission, requestSoundPermission)
    // No additional explicit permission request needed here
  }

  /// Handle notification tap
  static void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.id}');
    // You can navigate to prayer schedule screen here if needed
  }

  /// Schedule a prayer reminder notification
  /// Returns true if scheduled successfully
  static Future<bool> schedulePrayerReminder(PrayerSchedule schedule) async {
    // Skip on web platform (notifications don't work on web)
    if (kIsWeb) {
      debugPrint('Skipping notification scheduling on web platform');
      return false;
    }
    
    if (!_initialized) {
      final result = await initialize();
      if (!result) {
        debugPrint('Failed to initialize notification service');
        return false;
      }
    }

    if (!schedule.isActive) {
      // If schedule is inactive, cancel any existing notifications
      await cancelPrayerReminder(schedule.id);
      return true;
    }

    try {
      // First, cancel any existing notifications for this schedule
      // to prevent duplicates if this is being updated
      await cancelPrayerReminder(schedule.id);

      // Get the time components
      final time = schedule.scheduledTime;
      final hour = time.hour;
      final minute = time.minute;
      
      // Create Android-specific details
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'prayer_reminders',
        'Prayer Reminders',
        channelDescription: 'Notifications for scheduled prayer times',
        importance: Importance.high,
        priority: Priority.high,
        enableVibration: true,
        playSound: true,
      );

      // Create iOS-specific details
      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      // Combined notification details
      const NotificationDetails details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      // For each weekday in the schedule, create a recurring notification
      for (int weekday in schedule.weekdays) {
        // Create a notification ID that's unique per schedule and weekday
        final notificationId = _generateNotificationId(schedule.id, weekday);
        
        // Calculate the next occurrence of this weekday and time
        final scheduledDate = _nextInstanceOfDayAndTime(weekday, hour, minute);
        
        // Schedule the recurring notification using day of week and time matching
        // matchDateTimeComponents.dayOfWeekAndTime will make it repeat weekly
        // on the specified weekday at the specified time
        try {
          await _notifications.zonedSchedule(
            notificationId,
            schedule.title,
            schedule.description ?? 'Time for your scheduled prayer',
            tz.TZDateTime.from(scheduledDate, tz.local),
            details,
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
            matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
          );
        } catch (e) {
          debugPrint('Error scheduling notification: $e');
          rethrow;
        }
      }

      debugPrint('Scheduled prayer reminder for: ${schedule.title}');
      return true;
    } catch (e) {
      debugPrint('Error scheduling prayer reminder: $e');
      return false;
    }
  }

  /// Cancel a prayer reminder notification
  static Future<void> cancelPrayerReminder(String scheduleId) async {
    // Skip on web platform (notifications don't work on web)
    if (kIsWeb) {
      debugPrint('Skipping cancel reminder on web platform');
      return;
    }
    
    if (!_initialized) {
      debugPrint('Notification service not initialized, skipping cancel');
      return;
    }

    // Cancel all notifications for this schedule (one per weekday)
    // We need to cancel for all weekdays 1-7 since we don't know which were scheduled
    try {
      for (int weekday = 1; weekday <= 7; weekday++) {
        final notificationId = _generateNotificationId(scheduleId, weekday);
        await _notifications.cancel(notificationId);
      }
      debugPrint('Cancelled prayer reminders for schedule: $scheduleId');
    } catch (e) {
      debugPrint('Error cancelling prayer reminder: $e');
    }
  }

  /// Reschedule all prayer reminders from saved schedules
  /// Call this after app initialization or when schedules might have changed
  static Future<void> rescheduleAllReminders(
      List<PrayerSchedule> schedules) async {
    // Skip on web platform (notifications don't work on web)
    if (kIsWeb) {
      debugPrint('Skipping notification scheduling on web platform');
      return;
    }
    
    if (!_initialized) {
      final initResult = await initialize();
      if (!initResult) {
        debugPrint('Failed to initialize notification service');
        return;
      }
    }

    // Cancel all existing prayer reminders first
    await cancelAllPrayerReminders();

    // Schedule all active prayer reminders
    for (final schedule in schedules) {
      if (schedule.isActive) {
        await schedulePrayerReminder(schedule);
      }
    }

    debugPrint('Rescheduled ${schedules.length} prayer reminders');
  }

  /// Cancel all prayer reminders
  static Future<void> cancelAllPrayerReminders() async {
    if (!_initialized) {
      debugPrint('Notification service not initialized, skipping cancelAll');
      return;
    }
    
    // Skip on web platform (notifications don't work on web)
    if (kIsWeb) {
      debugPrint('Skipping cancelAll on web platform');
      return;
    }
    
    try {
      await _notifications.cancelAll();
      debugPrint('Cancelled all prayer reminders');
    } catch (e) {
      debugPrint('Error cancelling all reminders: $e');
    }
  }

  /// Generate a unique notification ID from schedule ID and weekday
  /// Uses a hash to ensure IDs are within valid range (int32)
  static int _generateNotificationId(String scheduleId, int weekday) {
    // Create a hash from the schedule ID and weekday
    // This ensures unique IDs while keeping them within int range
    final hash = scheduleId.hashCode;
    // Combine hash with weekday (multiply by 10 to avoid collisions)
    // Notification IDs should be positive integers
    return (hash.abs() % 1000000) * 10 + weekday;
  }

  /// Get the next instance of a specific weekday and time
  /// Returns a DateTime for the next occurrence
  static DateTime _nextInstanceOfDayAndTime(int weekday, int hour, int minute) {
    // Get current time
    final now = DateTime.now();
    
    // Calculate days until the next occurrence of this weekday
    int daysUntil = (weekday - now.weekday) % 7;
    if (daysUntil == 0) {
      // Today is the weekday - check if time has passed
      final todayTime = DateTime(now.year, now.month, now.day, hour, minute);
      if (todayTime.isBefore(now)) {
        // Time has passed today, schedule for next week
        daysUntil = 7;
      }
    } else {
      // Adjust for negative modulo (if weekday < current weekday)
      if (weekday < now.weekday) {
        daysUntil += 7;
      }
    }

    // Calculate the target date
    final targetDate = now.add(Duration(days: daysUntil));
    return DateTime(
      targetDate.year,
      targetDate.month,
      targetDate.day,
      hour,
      minute,
    );
  }
}
