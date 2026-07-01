import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rooted/models/level.dart';
import 'package:rooted/models/badge.dart';
import 'package:rooted/models/challenge.dart';
import 'package:rooted/services/offline_verse_database.dart';

/// Service to manage gamification features
class GamificationService {
  static const String _userProgressKey = 'user_progress';
  static const String _badgesKey = 'user_badges';
  static const String _challengesKey = 'user_challenges';

  /// Get user progress
  static Future<UserProgress> getUserProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final progressJson = prefs.getString(_userProgressKey);

    if (progressJson == null) {
      final initialProgress = UserProgress();
      await _saveUserProgress(initialProgress);
      return initialProgress;
    }

    try {
      return UserProgress.fromJson(jsonDecode(progressJson));
    } catch (e) {
      return UserProgress();
    }
  }

  /// Save user progress
  static Future<void> _saveUserProgress(UserProgress progress) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userProgressKey, jsonEncode(progress.toJson()));
  }

  /// Add XP and check for level up
  static Future<LevelUpResult> addXP(int xp, {String? reason}) async {
    final progress = await getUserProgress();
    final oldLevel = progress.level;
    final newTotalXP = progress.totalXP + xp;

    // Calculate new level
    int newLevel = oldLevel;
    for (int i = 1; i <= LevelTiers.tiers.length; i++) {
      if (newTotalXP >= LevelTiers.getXPForLevel(i)) {
        newLevel = i;
      } else {
        break;
      }
    }

    final didLevelUp = newLevel > oldLevel;

    // Update progress
    final updatedProgress = progress.copyWith(
      totalXP: newTotalXP,
      level: newLevel,
      lastActivityDate: DateTime.now(),
    );

    await _saveUserProgress(updatedProgress);
    await _queueProfileSync(updatedProgress);

    debugPrint('🎮 +$xp XP${reason != null ? " ($reason)" : ""}');
    if (didLevelUp) {
      debugPrint('🎉 LEVEL UP! Level $oldLevel → $newLevel');
    }

    return LevelUpResult(
      didLevelUp: didLevelUp,
      oldLevel: oldLevel,
      newLevel: newLevel,
      xpGained: xp,
      totalXP: newTotalXP,
      newTier: didLevelUp ? LevelTiers.getTierForLevel(newLevel) : null,
    );
  }

  /// Get current user level with details
  static Future<UserLevel> getCurrentLevel() async {
    final progress = await getUserProgress();
    final currentTier = LevelTiers.getTierForLevel(progress.level);
    final nextTier = LevelTiers.getNextTier(progress.level);

    final currentLevelXP = LevelTiers.getXPForLevel(progress.level);
    final nextLevelXP = nextTier.xpRequired;
    final xpInCurrentLevel = progress.totalXP - currentLevelXP;
    final xpNeededForNextLevel = nextLevelXP - currentLevelXP;

    return UserLevel(
      level: progress.level,
      currentXP: xpInCurrentLevel,
      xpForNextLevel: xpNeededForNextLevel,
      title: currentTier.title,
      description: currentTier.description,
      perks: currentTier.perks,
    );
  }

  /// Get all badges with user progress
  static Future<List<Badge>> getAllBadges() async {
    final prefs = await SharedPreferences.getInstance();
    final badgesJson = prefs.getString(_badgesKey);

    // Initialize with all badge definitions
    final allBadges = List<Badge>.from(BadgeDefinitions.allBadges);

    if (badgesJson == null) {
      await _saveBadges(allBadges);
      return allBadges;
    }

    try {
      final badgesList = jsonDecode(badgesJson) as List;
      final userBadges = badgesList.map((b) => Badge.fromJson(b)).toList();

      // Merge with definitions (in case new badges added)
      final mergedBadges = <Badge>[];
      for (final defBadge in BadgeDefinitions.allBadges) {
        final userBadge = userBadges.firstWhere(
          (b) => b.id == defBadge.id,
          orElse: () => defBadge,
        );
        mergedBadges.add(userBadge);
      }

      return mergedBadges;
    } catch (e) {
      return allBadges;
    }
  }

  /// Save badges
  static Future<void> _saveBadges(List<Badge> badges) async {
    final prefs = await SharedPreferences.getInstance();
    final badgesJson = badges.map((b) => b.toJson()).toList();
    await prefs.setString(_badgesKey, jsonEncode(badgesJson));
  }

  /// Update badge progress and check for unlock
  static Future<BadgeUnlockResult?> updateBadgeProgress(
    String badgeId,
    int increment,
  ) async {
    final badges = await getAllBadges();
    final badgeIndex = badges.indexWhere((b) => b.id == badgeId);

    if (badgeIndex == -1) return null;

    final badge = badges[badgeIndex];
    if (badge.isUnlocked) return null;

    final newProgress = badge.progress + increment;
    final shouldUnlock = newProgress >= badge.requirement;

    final updatedBadge = badge.copyWith(
      progress: newProgress,
      isUnlocked: shouldUnlock,
      unlockedAt: shouldUnlock ? DateTime.now() : null,
    );

    badges[badgeIndex] = updatedBadge;
    await _saveBadges(badges);

    if (shouldUnlock) {
      // Award XP for unlocking badge
      await addXP(badge.xpReward, reason: 'Badge: ${badge.name}');
      
      debugPrint('🏆 Badge Unlocked: ${badge.name}');
      
      return BadgeUnlockResult(
        badge: updatedBadge,
        xpGained: badge.xpReward,
      );
    }

    return null;
  }

  /// Get unlocked badges
  static Future<List<Badge>> getUnlockedBadges() async {
    final badges = await getAllBadges();
    return badges.where((b) => b.isUnlocked).toList();
  }

  /// Get active challenges
  static Future<List<Challenge>> getActiveChallenges() async {
    final challenges = await getAllChallenges();
    return challenges.where((c) => c.isActive).toList();
  }

  /// Get all challenges
  static Future<List<Challenge>> getAllChallenges() async {
    final prefs = await SharedPreferences.getInstance();
    final challengesJson = prefs.getString(_challengesKey);

    if (challengesJson == null) {
      final initialChallenges = _generateDailyChallenges();
      await _saveChallenges(initialChallenges);
      return initialChallenges;
    }

    try {
      final challengesList = jsonDecode(challengesJson) as List;
      return challengesList.map((c) => Challenge.fromJson(c)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Save challenges
  static Future<void> _saveChallenges(List<Challenge> challenges) async {
    final prefs = await SharedPreferences.getInstance();
    final challengesJson = challenges.map((c) => c.toJson()).toList();
    await prefs.setString(_challengesKey, jsonEncode(challengesJson));
  }

  /// Update challenge progress
  static Future<ChallengeCompleteResult?> updateChallengeProgress(
    String challengeId,
    int increment,
  ) async {
    final challenges = await getAllChallenges();
    final challengeIndex = challenges.indexWhere((c) => c.id == challengeId);

    if (challengeIndex == -1) return null;

    final challenge = challenges[challengeIndex];
    if (challenge.isCompleted || challenge.isExpired) return null;

    final newProgress = challenge.currentProgress + increment;
    final isNowCompleted = newProgress >= challenge.targetValue;

    final updatedChallenge = challenge.copyWith(
      currentProgress: newProgress,
      isCompleted: isNowCompleted,
      completedAt: isNowCompleted ? DateTime.now() : null,
    );

    challenges[challengeIndex] = updatedChallenge;
    await _saveChallenges(challenges);

    if (isNowCompleted) {
      // Award XP for completing challenge
      await addXP(challenge.xpReward, reason: 'Challenge: ${challenge.title}');
      
      debugPrint('✅ Challenge Completed: ${challenge.title}');
      
      return ChallengeCompleteResult(
        challenge: updatedChallenge,
        xpGained: challenge.xpReward,
      );
    }

    return null;
  }

  /// Generate daily challenges
  static List<Challenge> _generateDailyChallenges() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final nextWeek = today.add(const Duration(days: 7));

    return [
      // Daily challenges
      Challenge(
        id: 'daily_read_${today.toIso8601String()}',
        title: 'Daily Reading',
        description: 'Read the Bible once today',
        type: ChallengeType.daily,
        difficulty: ChallengeDifficulty.easy,
        xpReward: 25,
        targetValue: 1,
        startDate: today,
        endDate: tomorrow,
        icon: '📖',
      ),
      Challenge(
        id: 'daily_pray_${today.toIso8601String()}',
        title: 'Prayer Time',
        description: 'Complete a prayer session today',
        type: ChallengeType.daily,
        difficulty: ChallengeDifficulty.easy,
        xpReward: 20,
        targetValue: 1,
        startDate: today,
        endDate: tomorrow,
        icon: '🙏',
      ),
      Challenge(
        id: 'daily_reflection_${today.toIso8601String()}',
        title: 'Daily Reflection',
        description: 'Add a reflection to today\'s verse',
        type: ChallengeType.daily,
        difficulty: ChallengeDifficulty.easy,
        xpReward: 15,
        targetValue: 1,
        startDate: today,
        endDate: tomorrow,
        icon: '💭',
      ),

      // Weekly challenges
      Challenge(
        id: 'weekly_readings_${today.toIso8601String()}',
        title: 'Weekly Devotion',
        description: 'Complete 7 Bible readings this week',
        type: ChallengeType.weekly,
        difficulty: ChallengeDifficulty.medium,
        xpReward: 150,
        targetValue: 7,
        startDate: today,
        endDate: nextWeek,
        icon: '🔥',
      ),
      Challenge(
        id: 'weekly_streak_${today.toIso8601String()}',
        title: 'Consistency Challenge',
        description: 'Read every day for 7 days',
        type: ChallengeType.weekly,
        difficulty: ChallengeDifficulty.hard,
        xpReward: 250,
        targetValue: 7,
        startDate: today,
        endDate: nextWeek,
        icon: '⚡',
      ),
    ];
  }

  /// Refresh challenges (generate new ones if expired)
  static Future<void> refreshChallenges() async {
    final challenges = await getAllChallenges();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Check if we need new daily challenges
    final hasTodaysChallenges = challenges.any((c) =>
        c.type == ChallengeType.daily &&
        c.startDate.year == today.year &&
        c.startDate.month == today.month &&
        c.startDate.day == today.day);

    if (!hasTodaysChallenges) {
      // Remove expired challenges and generate new ones
      final activeChallenges = challenges.where((c) => !c.isExpired).toList();
      final newChallenges = _generateDailyChallenges();
      
      final allChallenges = [...activeChallenges, ...newChallenges];
      await _saveChallenges(allChallenges);
      
      debugPrint('🎮 Generated new challenges for today');
    }
  }

  /// Award XP for specific actions
  static Future<void> awardXPForAction(GameAction action) async {
    int xp = 0;
    String? badgeToUpdate;
    String? challengeToUpdate;

    switch (action) {
      case GameAction.bibleReading:
        xp = 10;
        badgeToUpdate = 'first_reading';
        challengeToUpdate = 'daily_read';
        break;
      case GameAction.prayerSession:
        xp = 8;
        badgeToUpdate = 'prayer_10';
        challengeToUpdate = 'daily_pray';
        break;
      case GameAction.addReflection:
        xp = 5;
        challengeToUpdate = 'daily_reflection';
        break;
      case GameAction.completeGoal:
        xp = 20;
        badgeToUpdate = 'goal_complete';
        break;
      case GameAction.streakDay:
        xp = 15;
        badgeToUpdate = 'streak_7';
        challengeToUpdate = 'weekly_streak';
        break;
      case GameAction.shareVerse:
        xp = 10;
        badgeToUpdate = 'share_first';
        break;
      case GameAction.completeReadingPlan:
        xp = 50;
        break;
    }

    if (xp > 0) {
      await addXP(xp, reason: action.toString());
    }

    // Update badge progress
    if (badgeToUpdate != null) {
      final result = await updateBadgeProgress(badgeToUpdate, 1);
      if (result != null) {
        // Badge was unlocked!
        debugPrint('🏆 Badge unlocked: ${result.badge.name}');
      }
    }

    // Update challenge progress
    if (challengeToUpdate != null) {
      final today = DateTime.now();
      final todayString = DateTime(today.year, today.month, today.day).toIso8601String();
      final fullChallengeId = '${challengeToUpdate}_$todayString';
      
      final result = await updateChallengeProgress(fullChallengeId, 1);
      if (result != null) {
        // Challenge completed!
        debugPrint('✅ Challenge completed: ${result.challenge.title}');
      }
    }
  }

  /// Get gamification stats
  static Future<GamificationStats> getStats() async {
    final progress = await getUserProgress();
    final badges = await getAllBadges();
    final challenges = await getActiveChallenges();
    final level = await getCurrentLevel();

    final unlockedBadges = badges.where((b) => b.isUnlocked).length;
    final totalBadges = badges.length;
    final activeChallengesCount = challenges.length;
    final completedChallenges = challenges.where((c) => c.isCompleted).length;

    return GamificationStats(
      level: level,
      totalXP: progress.totalXP,
      unlockedBadges: unlockedBadges,
      totalBadges: totalBadges,
      activeChallenges: activeChallengesCount,
      completedChallenges: completedChallenges,
      daysActive: progress.daysActive,
    );
  }

  /// Reset all gamification progress (for testing)
  static Future<void> resetProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userProgressKey);
    await prefs.remove(_badgesKey);
    await prefs.remove(_challengesKey);
    debugPrint('🔄 Gamification progress reset');
  }

  /// Queue profile for sync
  static Future<void> _queueProfileSync(UserProgress progress) async {
    await OfflineVerseDatabase().addToSyncQueue(
      'profile',
      'user_profile',
      'upsert',
      progress.toJson(),
    );
  }
}

/// Game actions that award XP
enum GameAction {
  bibleReading,
  prayerSession,
  addReflection,
  completeGoal,
  streakDay,
  shareVerse,
  completeReadingPlan,
}

/// Level up result
class LevelUpResult {
  final bool didLevelUp;
  final int oldLevel;
  final int newLevel;
  final int xpGained;
  final int totalXP;
  final LevelTier? newTier;

  LevelUpResult({
    required this.didLevelUp,
    required this.oldLevel,
    required this.newLevel,
    required this.xpGained,
    required this.totalXP,
    this.newTier,
  });
}

/// Badge unlock result
class BadgeUnlockResult {
  final Badge badge;
  final int xpGained;

  BadgeUnlockResult({
    required this.badge,
    required this.xpGained,
  });
}

/// Challenge complete result
class ChallengeCompleteResult {
  final Challenge challenge;
  final int xpGained;

  ChallengeCompleteResult({
    required this.challenge,
    required this.xpGained,
  });
}

/// Gamification statistics
class GamificationStats {
  final UserLevel level;
  final int totalXP;
  final int unlockedBadges;
  final int totalBadges;
  final int activeChallenges;
  final int completedChallenges;
  final int daysActive;

  GamificationStats({
    required this.level,
    required this.totalXP,
    required this.unlockedBadges,
    required this.totalBadges,
    required this.activeChallenges,
    required this.completedChallenges,
    required this.daysActive,
  });

  double get badgeCompletion {
    if (totalBadges == 0) return 0;
    return unlockedBadges / totalBadges;
  }
}

