import 'package:share_plus/share_plus.dart';
import 'package:rooted/models/reading_plan.dart';
import 'package:rooted/models/spiritual_goal.dart';
import 'package:rooted/models/streak.dart';

class ShareService {
  /// Share a reading plan
  static Future<void> shareReadingPlan(ReadingPlan plan) async {
    final buffer = StringBuffer();

    buffer.writeln('📖 ${plan.name}');
    buffer.writeln('');
    buffer.writeln(plan.description);
    buffer.writeln('');
    buffer.writeln('📊 Duration: ${plan.durationDays} days');

    if (plan.isActive) {
      buffer.writeln('✅ Progress: ${plan.progressPercentage}% complete');
      buffer.writeln('📅 Started: ${_formatDate(plan.startDate!)}');
      buffer.writeln(
          '🎯 ${plan.daysCompleted} days completed, ${plan.daysRemaining} remaining');
    }

    buffer.writeln('');
    buffer.writeln('📚 Daily Readings:');

    // Show first few readings as preview
    final previewCount = plan.readings.length > 7 ? 7 : plan.readings.length;
    for (int i = 0; i < previewCount; i++) {
      final reading = plan.readings[i];
      final status = reading.isCompleted ? '✓' : '○';
      buffer.writeln(
          '  $status Day ${reading.day}: ${reading.bookName} ${reading.chapters}');
    }

    if (plan.readings.length > 7) {
      buffer.writeln('  ... and ${plan.readings.length - 7} more days');
    }

    buffer.writeln('');
    buffer.writeln('Shared from Rooted - Your Spiritual Growth Companion 🙏');

    await Share.share(
      buffer.toString(),
      subject: plan.name,
    );
  }

  /// Share a spiritual goal
  static Future<void> shareGoal(SpiritualGoal goal) async {
    final buffer = StringBuffer();

    buffer.writeln('🎯 My Spiritual Goal');
    buffer.writeln('');
    buffer.writeln(goal.title);
    buffer.writeln('');

    if (goal.description.isNotEmpty) {
      buffer.writeln('📝 ${goal.description}');
      buffer.writeln('');
    }

    buffer.writeln('🏷️ Category: ${goal.category}');
    buffer.writeln('📅 Frequency: ${goal.frequency}');
    buffer.writeln('🎯 Target: ${goal.targetCount} times');
    buffer.writeln(
        '✅ Progress: ${goal.currentCount}/${goal.targetCount} (${goal.progressPercentage.toStringAsFixed(0)}%)');
    buffer.writeln('📊 Status: ${goal.status}');

    buffer.writeln('🚀 Started: ${_formatDate(goal.startDate)}');

    if (goal.targetDate != null) {
      buffer.writeln('🏁 Target Date: ${_formatDate(goal.targetDate!)}');
    }

    if (goal.isCompleted) {
      buffer.writeln('');
      buffer.writeln('🎉 Goal Completed! ✨');
    }

    if (goal.milestones.isNotEmpty) {
      buffer.writeln('');
      buffer.writeln('Milestones:');
      for (final milestone in goal.milestones) {
        buffer.writeln('  • $milestone');
      }
    }

    buffer.writeln('');
    buffer.writeln('Shared from Rooted - Your Spiritual Growth Companion 🙏');

    await Share.share(
      buffer.toString(),
      subject: 'My Spiritual Goal: ${goal.title}',
    );
  }

  /// Share reading streak
  static Future<void> shareStreak(ReadingStreak streak) async {
    final buffer = StringBuffer();

    buffer.writeln('🔥 My Bible Reading Streak');
    buffer.writeln('');
    buffer.writeln('📊 Current Streak: ${streak.currentStreak} days');
    buffer.writeln('🏆 Longest Streak: ${streak.longestStreak} days');
    buffer.writeln('📅 Weekly Streak: ${streak.weeklyStreak} weeks');
    buffer.writeln('🎯 Longest Weekly: ${streak.longestWeeklyStreak} weeks');

    if (streak.lastReadingDate != null) {
      buffer.writeln('');
      buffer.writeln('Last read: ${_formatDate(streak.lastReadingDate!)}');
    }

    if (streak.streakStartDate != null) {
      buffer.writeln('Streak started: ${_formatDate(streak.streakStartDate!)}');
    }

    buffer.writeln('');
    buffer.writeln('Keep God\'s Word close to your heart every day! 💙');
    buffer.writeln('');
    buffer.writeln('Shared from Rooted - Your Spiritual Growth Companion 🙏');

    await Share.share(
      buffer.toString(),
      subject: 'My Bible Reading Streak',
    );
  }

  /// Share progress summary
  static Future<void> shareProgressSummary({
    required int bibleReadings,
    required int minutesSpent,
    required int booksCompleted,
    required int goalsCompleted,
    required ReadingStreak streak,
  }) async {
    final buffer = StringBuffer();

    buffer.writeln('📊 My Spiritual Journey Progress');
    buffer.writeln('');
    buffer.writeln('📖 Bible Reading:');
    buffer.writeln('  • $bibleReadings reading sessions');
    buffer.writeln('  • $minutesSpent minutes in the Word');
    buffer.writeln('  • ${streak.currentStreak}-day streak 🔥');
    buffer.writeln('');
    buffer.writeln('📚 Books: $booksCompleted completed');
    buffer.writeln('🎯 Goals: $goalsCompleted achieved');
    buffer.writeln('');
    buffer.writeln(
        '"Your word is a lamp to my feet and a light to my path." - Psalm 119:105');
    buffer.writeln('');
    buffer.writeln('Shared from Rooted - Your Spiritual Growth Companion 🙏');

    await Share.share(
      buffer.toString(),
      subject: 'My Spiritual Progress',
    );
  }

  /// Format date for sharing
  static String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
