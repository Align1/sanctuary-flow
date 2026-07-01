import 'package:home_widget/home_widget.dart';
import 'package:rooted/services/verse_service.dart';
import 'package:rooted/services/streak_service.dart';
import 'package:rooted/models/daily_verse.dart';
import 'package:rooted/models/streak.dart';

/// Service to manage home screen widgets
class HomeWidgetService {
  static const String _verseKey = 'widget_verse';
  static const String _referenceKey = 'widget_reference';
  static const String _streakKey = 'widget_streak';
  static const String _longestStreakKey = 'widget_longest_streak';
  static const String _lastUpdatedKey = 'widget_last_updated';
  static const String _hasReadTodayKey = 'widget_has_read_today';

  /// Initialize home widgets on app startup
  static Future<void> initialize() async {
    // Set the app group for iOS (required for sharing data between app and widgets)
    await HomeWidget.setAppGroupId('group.com.mycompany.Rooted');
    
    // Register callbacks for Android widget interactions
    HomeWidget.registerInteractivityCallback(_backgroundCallback);
    
    // Update all widgets with current data
    await updateAllWidgets();
  }

  /// Background callback for Android widget interactions
  @pragma('vm:entry-point')
  static Future<void> _backgroundCallback(Uri? uri) async {
    if (uri == null) return;

    // Handle different actions based on the URI
    if (uri.host == 'open_app') {
      // Open the app (handled by the app itself)
    } else if (uri.host == 'refresh_verse') {
      // Refresh the daily verse widget
      await updateDailyVerseWidget();
    } else if (uri.host == 'refresh_streak') {
      // Refresh the streak widget
      await updateStreakWidget();
    }
  }

  /// Update all widgets with current data
  static Future<void> updateAllWidgets() async {
    await Future.wait([
      updateDailyVerseWidget(),
      updateStreakWidget(),
    ]);
  }

  /// Update the daily verse widget
  static Future<void> updateDailyVerseWidget() async {
    try {
      final DailyVerse verse = await VerseService.getTodaysVerse();
      
      await HomeWidget.saveWidgetData<String>(_verseKey, verse.verse);
      await HomeWidget.saveWidgetData<String>(_referenceKey, verse.reference);
      await HomeWidget.saveWidgetData<String>(
        _lastUpdatedKey,
        DateTime.now().toIso8601String(),
      );

      // Update the widgets on the home screen
      await HomeWidget.updateWidget(
        name: 'DailyVerseWidgetProvider',
        androidName: 'DailyVerseWidgetProvider',
        iOSName: 'DailyVerseWidget',
      );
    } catch (e) {
      // Log error silently - widget updates should not crash the app
      // In production, consider using a proper logging service
    }
  }

  /// Update the streak counter widget
  static Future<void> updateStreakWidget() async {
    try {
      final ReadingStreak streak = await StreakService.getStreak();
      
      await HomeWidget.saveWidgetData<int>(_streakKey, streak.currentStreak);
      await HomeWidget.saveWidgetData<int>(_longestStreakKey, streak.longestStreak);
      await HomeWidget.saveWidgetData<bool>(_hasReadTodayKey, streak.hasReadToday());
      await HomeWidget.saveWidgetData<String>(
        _lastUpdatedKey,
        DateTime.now().toIso8601String(),
      );

      // Update the widgets on the home screen
      await HomeWidget.updateWidget(
        name: 'StreakWidgetProvider',
        androidName: 'StreakWidgetProvider',
        iOSName: 'StreakWidget',
      );
    } catch (e) {
      // Log error silently - widget updates should not crash the app
      // In production, consider using a proper logging service
    }
  }

  /// Get the pending click action (for Android)
  static Future<Uri?> getWidgetUri() async {
    return await HomeWidget.getWidgetData<Uri>('uri');
  }

  /// Launch app from widget (helper method)
  static Future<void> setWidgetLaunchAction(String action) async {
    await HomeWidget.saveWidgetData<String>('launch_action', action);
  }
}

