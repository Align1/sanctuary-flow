import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rooted/models/achievement.dart';
import 'package:rooted/services/local_storage_service.dart';
import 'package:rooted/services/streak_service.dart';

class AchievementService {
  static const String _achievementsKey = 'achievements';
  static SharedPreferences? _prefs;

  static Future<void> _ensurePrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Initialize default achievements
  static Future<List<Achievement>> initializeAchievements() async {
    await _ensurePrefs();

    final existingJson = _prefs!.getString(_achievementsKey);
    List<Achievement> achievements;

    if (existingJson != null) {
      try {
        final List<dynamic> jsonList =
            jsonDecode(existingJson) as List<dynamic>;
        achievements =
            jsonList.map((json) => Achievement.fromJson(json)).toList();
      } catch (e) {
        achievements = _getDefaultAchievements();
      }
    } else {
      achievements = _getDefaultAchievements();
    }

    await _saveAchievements(achievements);
    return achievements;
  }

  static List<Achievement> _getDefaultAchievements() {
    return [
      // Bible Reading Achievements
      Achievement(
        id: 'bible_1',
        title: 'First Steps',
        description: 'Read your first Bible chapter',
        category: 'bible',
        targetValue: 1,
        iconName: 'book',
        badgeColor: '#4A90E2',
      ),
      Achievement(
        id: 'bible_5',
        title: 'Getting Started',
        description: 'Read 5 Bible chapters',
        category: 'bible',
        targetValue: 5,
        iconName: 'book_open',
        badgeColor: '#5BA3F5',
      ),
      Achievement(
        id: 'bible_25',
        title: 'Dedicated Reader',
        description: 'Read 25 Bible chapters',
        category: 'bible',
        targetValue: 25,
        iconName: 'auto_stories',
        badgeColor: '#6BB6FF',
      ),
      Achievement(
        id: 'bible_50',
        title: 'Bible Scholar',
        description: 'Read 50 Bible chapters',
        category: 'bible',
        targetValue: 50,
        iconName: 'school',
        badgeColor: '#7BC9FF',
      ),
      Achievement(
        id: 'bible_100',
        title: 'Scripture Master',
        description: 'Read 100 Bible chapters',
        category: 'bible',
        targetValue: 100,
        iconName: 'stars',
        badgeColor: '#8BD9FF',
      ),

      // Streak Achievements
      Achievement(
        id: 'streak_3',
        title: 'Three Day Champion',
        description: 'Maintain a 3-day reading streak',
        category: 'streak',
        targetValue: 3,
        iconName: 'whatshot',
        badgeColor: '#FF6B6B',
      ),
      Achievement(
        id: 'streak_7',
        title: 'Week Warrior',
        description: 'Maintain a 7-day reading streak',
        category: 'streak',
        targetValue: 7,
        iconName: 'local_fire_department',
        badgeColor: '#FF5252',
      ),
      Achievement(
        id: 'streak_30',
        title: 'Month Master',
        description: 'Maintain a 30-day reading streak',
        category: 'streak',
        targetValue: 30,
        iconName: 'flame',
        badgeColor: '#FF1744',
      ),
      Achievement(
        id: 'streak_100',
        title: 'Century Champion',
        description: 'Maintain a 100-day reading streak',
        category: 'streak',
        targetValue: 100,
        iconName: 'emoji_events',
        badgeColor: '#D32F2F',
      ),

      // Weekly Streak Achievements
      Achievement(
        id: 'weekly_4',
        title: 'Monthly Consistency',
        description: 'Read for 4 consecutive weeks',
        category: 'streak',
        targetValue: 4,
        iconName: 'calendar_month',
        badgeColor: '#9C27B0',
      ),
      Achievement(
        id: 'weekly_12',
        title: 'Quarterly Devotion',
        description: 'Read for 12 consecutive weeks',
        category: 'streak',
        targetValue: 12,
        iconName: 'event',
        badgeColor: '#7B1FA2',
      ),

      // Book Achievements
      Achievement(
        id: 'book_1',
        title: 'Book Worm',
        description: 'Complete reading your first book',
        category: 'book',
        targetValue: 1,
        iconName: 'menu_book',
        badgeColor: '#8B5CF6',
      ),
      Achievement(
        id: 'book_5',
        title: 'Bibliophile',
        description: 'Complete reading 5 books',
        category: 'book',
        targetValue: 5,
        iconName: 'library_books',
        badgeColor: '#7C3AED',
      ),
      Achievement(
        id: 'book_10',
        title: 'Scholar',
        description: 'Complete reading 10 books',
        category: 'book',
        targetValue: 10,
        iconName: 'local_library',
        badgeColor: '#6D28D9',
      ),

      // Goal Achievements
      Achievement(
        id: 'goal_1',
        title: 'Goal Setter',
        description: 'Complete your first spiritual goal',
        category: 'goal',
        targetValue: 1,
        iconName: 'flag',
        badgeColor: '#F59E0B',
      ),
      Achievement(
        id: 'goal_5',
        title: 'Achiever',
        description: 'Complete 5 spiritual goals',
        category: 'goal',
        targetValue: 5,
        iconName: 'emoji_events',
        badgeColor: '#D97706',
      ),
      Achievement(
        id: 'goal_10',
        title: 'Goal Master',
        description: 'Complete 10 spiritual goals',
        category: 'goal',
        targetValue: 10,
        iconName: 'workspace_premium',
        badgeColor: '#B45309',
      ),

      // General Achievements
      Achievement(
        id: 'prayer_100',
        title: 'Prayer Warrior',
        description: 'Track 100 prayer sessions',
        category: 'prayer',
        targetValue: 100,
        iconName: 'hands_holding',
        badgeColor: '#10B981',
      ),
      Achievement(
        id: 'message_50',
        title: 'Eager Learner',
        description: 'Listen to 50 messages',
        category: 'general',
        targetValue: 50,
        iconName: 'headphones',
        badgeColor: '#14B8A6',
      ),
    ];
  }

  /// Get all achievements
  static Future<List<Achievement>> getAchievements() async {
    await _ensurePrefs();
    final jsonString = _prefs!.getString(_achievementsKey);

    if (jsonString == null) {
      return await initializeAchievements();
    }

    try {
      final List<dynamic> jsonList = jsonDecode(jsonString) as List<dynamic>;
      return jsonList.map((json) => Achievement.fromJson(json)).toList();
    } catch (e) {
      return await initializeAchievements();
    }
  }

  /// Save achievements to storage
  static Future<void> _saveAchievements(List<Achievement> achievements) async {
    await _ensurePrefs();
    final jsonList = achievements.map((a) => a.toJson()).toList();
    await _prefs!.setString(_achievementsKey, jsonEncode(jsonList));
  }

  /// Sync achievements from cloud (merge)
  static Future<void> syncAchievements(List<Achievement> cloudAchievements) async {
    await _ensurePrefs();
    final localAchievements = await getAchievements();
    
    bool changed = false;
    for (final cloud in cloudAchievements) {
      final index = localAchievements.indexWhere((a) => a.id == cloud.id);
      if (index != -1) {
        final local = localAchievements[index];
        if ((cloud.isUnlocked && !local.isUnlocked) || 
            (cloud.currentValue > local.currentValue)) {
          localAchievements[index] = local.copyWith(
            currentValue: cloud.currentValue,
            isUnlocked: cloud.isUnlocked,
            unlockedDate: cloud.unlockedDate,
          );
          changed = true;
        }
      }
    }
    
    if (changed) {
      await _saveAchievements(localAchievements);
    }
  }

  /// Update achievement progress
  static Future<Achievement> updateAchievement(
    String achievementId,
    int newValue,
  ) async {
    final achievements = await getAchievements();
    final index = achievements.indexWhere((a) => a.id == achievementId);

    if (index == -1) return achievements.first;

    final achievement = achievements[index];
    final updatedAchievement = achievement.copyWith(
      currentValue: newValue,
      isUnlocked: newValue >= achievement.targetValue && !achievement.isUnlocked
          ? true
          : achievement.isUnlocked,
      unlockedDate:
          newValue >= achievement.targetValue && !achievement.isUnlocked
              ? DateTime.now()
              : achievement.unlockedDate,
    );

    achievements[index] = updatedAchievement;
    await _saveAchievements(achievements);
    return updatedAchievement;
  }

  /// Check and update all achievements based on current data
  static Future<List<Achievement>> checkAndUpdateAchievements() async {
    final achievements = await getAchievements();

    // Get current data
    final bibleReadings = await LocalStorageService.getBibleReadings();
    final books = await LocalStorageService.getBookReadings();
    final goals = await LocalStorageService.getSpiritualGoals();
    final prayerSessions = await LocalStorageService.getPrayerSessions();
    final messageSessions = await LocalStorageService.getMessageSessions();

    // Get streak data
    final streak = await StreakService.getStreak();

    bool hasNewUnlocks = false;

    // Update Bible reading achievements
    final bibleCount = bibleReadings.length;
    for (final achievement
        in achievements.where((a) => a.category == 'bible')) {
      final target = int.tryParse(achievement.id.split('_').last) ?? 0;
      if (bibleCount >= target) {
        final updated = await updateAchievement(achievement.id, bibleCount);
        if (updated.isUnlocked && !achievement.isUnlocked) {
          hasNewUnlocks = true;
        }
        // Update the achievement in our local list
        final index = achievements.indexWhere((a) => a.id == achievement.id);
        if (index != -1) {
          achievements[index] = updated;
        }
      }
    }

    // Update book achievements
    final completedBooks = books.where((b) => b.status == 'Completed').length;
    for (final achievement in achievements.where((a) => a.category == 'book')) {
      final target = int.tryParse(achievement.id.split('_').last) ?? 0;
      if (completedBooks >= target) {
        final updated = await updateAchievement(achievement.id, completedBooks);
        if (updated.isUnlocked && !achievement.isUnlocked) {
          hasNewUnlocks = true;
        }
        final index = achievements.indexWhere((a) => a.id == achievement.id);
        if (index != -1) {
          achievements[index] = updated;
        }
      }
    }

    // Update goal achievements
    final completedGoals = goals.where((g) => g.isCompleted).length;
    for (final achievement in achievements.where((a) => a.category == 'goal')) {
      final target = int.tryParse(achievement.id.split('_').last) ?? 0;
      if (completedGoals >= target) {
        final updated = await updateAchievement(achievement.id, completedGoals);
        if (updated.isUnlocked && !achievement.isUnlocked) {
          hasNewUnlocks = true;
        }
        final index = achievements.indexWhere((a) => a.id == achievement.id);
        if (index != -1) {
          achievements[index] = updated;
        }
      }
    }

    // Update prayer achievements
    final prayerCount = prayerSessions.length;
    for (final achievement
        in achievements.where((a) => a.category == 'prayer')) {
      final target = int.tryParse(achievement.id.split('_').last) ?? 0;
      if (prayerCount >= target) {
        final updated = await updateAchievement(achievement.id, prayerCount);
        if (updated.isUnlocked && !achievement.isUnlocked) {
          hasNewUnlocks = true;
        }
        final index = achievements.indexWhere((a) => a.id == achievement.id);
        if (index != -1) {
          achievements[index] = updated;
        }
      }
    }

    // Update message achievements
    final messageCount = messageSessions.length;
    for (final achievement in achievements
        .where((a) => a.category == 'general' && a.id.startsWith('message'))) {
      final target = int.tryParse(achievement.id.split('_').last) ?? 0;
      if (messageCount >= target) {
        final updated = await updateAchievement(achievement.id, messageCount);
        if (updated.isUnlocked && !achievement.isUnlocked) {
          hasNewUnlocks = true;
        }
        final index = achievements.indexWhere((a) => a.id == achievement.id);
        if (index != -1) {
          achievements[index] = updated;
        }
      }
    }

    // Update streak achievements
    for (final achievement in achievements
        .where((a) => a.category == 'streak' && a.id.startsWith('streak_'))) {
      final target = int.tryParse(achievement.id.split('_').last) ?? 0;
      if (streak.currentStreak >= target) {
        final updated =
            await updateAchievement(achievement.id, streak.currentStreak);
        if (updated.isUnlocked && !achievement.isUnlocked) {
          hasNewUnlocks = true;
        }
        final index = achievements.indexWhere((a) => a.id == achievement.id);
        if (index != -1) {
          achievements[index] = updated;
        }
      }
    }

    // Update weekly streak achievements
    for (final achievement in achievements
        .where((a) => a.category == 'streak' && a.id.startsWith('weekly_'))) {
      final target = int.tryParse(achievement.id.split('_').last) ?? 0;
      if (streak.weeklyStreak >= target) {
        final updated =
            await updateAchievement(achievement.id, streak.weeklyStreak);
        if (updated.isUnlocked && !achievement.isUnlocked) {
          hasNewUnlocks = true;
        }
        final index = achievements.indexWhere((a) => a.id == achievement.id);
        if (index != -1) {
          achievements[index] = updated;
        }
      }
    }

    return await getAchievements();
  }

  /// Get unlocked achievements
  static Future<List<Achievement>> getUnlockedAchievements() async {
    final achievements = await getAchievements();
    return achievements.where((a) => a.isUnlocked).toList();
  }

  /// Get achievements by category
  static Future<List<Achievement>> getAchievementsByCategory(
      String category) async {
    final achievements = await getAchievements();
    return achievements.where((a) => a.category == category).toList();
  }

  /// Get recent unlocks (last 5)
  static Future<List<Achievement>> getRecentUnlocks() async {
    final achievements = await getAchievements();
    final unlocked = achievements
        .where((a) => a.isUnlocked && a.unlockedDate != null)
        .toList();
    unlocked.sort((a, b) => b.unlockedDate!.compareTo(a.unlockedDate!));
    return unlocked.take(5).toList();
  }
}
