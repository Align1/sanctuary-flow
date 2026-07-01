import 'dart:convert';
import 'package:rooted/models/streak.dart';
import 'package:rooted/models/bible_reading.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rooted/services/home_widget_service.dart';
import 'package:rooted/services/gamification_service.dart';

class StreakService {
  static const String _streakKey = 'reading_streak';
  static SharedPreferences? _prefs;

  static Future<void> _ensurePrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Get current reading streak
  static Future<ReadingStreak> getStreak() async {
    await _ensurePrefs();
    final streakJson = _prefs!.getString(_streakKey);
    
    if (streakJson == null) {
      return ReadingStreak();
    }

    try {
      final Map<String, dynamic> json = jsonDecode(streakJson) as Map<String, dynamic>;
      return ReadingStreak.fromJson(json);
    } catch (e) {
      return ReadingStreak();
    }
  }

  /// Update streak when a Bible reading is added
  static Future<ReadingStreak> updateStreak(BibleReading reading) async {
    final currentStreak = await getStreak();
    final readingDate = DateTime(
      reading.dateRead.year,
      reading.dateRead.month,
      reading.dateRead.day,
    );

    // Check if already recorded today
    if (currentStreak.lastReadingDate != null &&
        currentStreak.isSameDay(currentStreak.lastReadingDate!, readingDate)) {
      return currentStreak; // Already counted today
    }

    // Update reading days
    List<DateTime> readingDays = List<DateTime>.from(currentStreak.readingDays);
    if (!readingDays.any((d) => currentStreak.isSameDay(d, readingDate))) {
      readingDays.add(readingDate);
      readingDays.sort();
    }

    int newCurrentStreak = currentStreak.currentStreak;
    int newLongestStreak = currentStreak.longestStreak;
    DateTime? streakStartDate = currentStreak.streakStartDate;

    // Check if continuing streak or starting new one
    if (currentStreak.lastReadingDate == null) {
      // First reading ever
      newCurrentStreak = 1;
      streakStartDate = readingDate;
    } else {
      final lastDate = currentStreak.lastReadingDate!;
      final daysDifference = readingDate.difference(
        DateTime(lastDate.year, lastDate.month, lastDate.day)
      ).inDays;

      if (daysDifference == 1) {
        // Continuing streak
        newCurrentStreak = currentStreak.currentStreak + 1;
        streakStartDate ??= lastDate;
      } else if (daysDifference == 0) {
        // Same day, don't change streak
        newCurrentStreak = currentStreak.currentStreak;
      } else {
        // Streak broken, start new streak
        newCurrentStreak = 1;
        streakStartDate = readingDate;
      }
    }

    // Update longest streak
    if (newCurrentStreak > currentStreak.longestStreak) {
      newLongestStreak = newCurrentStreak;
    } else {
      newLongestStreak = currentStreak.longestStreak;
    }

    // Calculate weekly streaks
    int newWeeklyStreak = _calculateWeeklyStreak(readingDays);
    int newLongestWeeklyStreak = newWeeklyStreak > currentStreak.longestWeeklyStreak
        ? newWeeklyStreak
        : currentStreak.longestWeeklyStreak;

    final updatedStreak = ReadingStreak(
      currentStreak: newCurrentStreak,
      longestStreak: newLongestStreak,
      weeklyStreak: newWeeklyStreak,
      longestWeeklyStreak: newLongestWeeklyStreak,
      lastReadingDate: readingDate,
      streakStartDate: streakStartDate,
      readingDays: readingDays,
    );

    await _saveStreak(updatedStreak);
    
    // Award XP for maintaining streak
    if (newCurrentStreak > currentStreak.currentStreak) {
      await GamificationService.awardXPForAction(GameAction.streakDay);
    }
    
    // Update home screen widgets
    await HomeWidgetService.updateStreakWidget();
    
    return updatedStreak;
  }

  /// Calculate current weekly streak
  static int _calculateWeeklyStreak(List<DateTime> readingDays) {
    if (readingDays.isEmpty) return 0;

    final now = DateTime.now();
    int weeks = 0;
    DateTime? lastWeekStart;

    // Check weeks going backwards
    for (int i = 0; i < 52; i++) { // Check up to a year
      final weekStart = now.subtract(Duration(days: now.weekday - 1 + (i * 7)));
      final weekEnd = weekStart.add(const Duration(days: 6));

      final hasReadingThisWeek = readingDays.any((date) =>
          date.isAfter(weekStart.subtract(const Duration(days: 1))) &&
          date.isBefore(weekEnd.add(const Duration(days: 1))));

      if (hasReadingThisWeek) {
        if (lastWeekStart == null || 
            _isConsecutiveWeek(lastWeekStart, weekStart)) {
          weeks++;
          lastWeekStart = weekStart;
        } else {
          break; // Streak broken
        }
      } else if (i == 0) {
        // Current week has no reading, streak is 0
        return 0;
      } else {
        break; // Gap found
      }
    }

    return weeks;
  }

  static bool _isConsecutiveWeek(DateTime week1, DateTime week2) {
    final diff = week1.difference(week2).inDays;
    return diff == 7 || diff == -7;
  }

  /// Save streak to storage
  static Future<void> _saveStreak(ReadingStreak streak) async {
    await _ensurePrefs();
    final json = streak.toJson();
    await _prefs!.setString(_streakKey, jsonEncode(json));
  }

  /// Reset streak (for testing or user reset)
  static Future<void> resetStreak() async {
    await _ensurePrefs();
    await _prefs!.remove(_streakKey);
  }
}

