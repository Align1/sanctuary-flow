import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rooted/services/gamification_service.dart';

/// Service for managing leaderboards (local and future cloud-based)
class LeaderboardService {
  static const String _leaderboardKey = 'local_leaderboard';
  static const String _userNameKey = 'user_display_name';

  /// Get local leaderboard (simulated for single user, extensible for multi-user)
  static Future<List<LeaderboardEntry>> getLeaderboard({
    LeaderboardPeriod period = LeaderboardPeriod.allTime,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    // Get current user's stats
    final userProgress = await GamificationService.getUserProgress();
    final userName = prefs.getString(_userNameKey) ?? 'You';

    // Create current user entry
    final currentUserEntry = LeaderboardEntry(
      rank: 1,
      userName: userName,
      level: userProgress.level,
      totalXP: userProgress.totalXP,
      isCurrentUser: true,
    );

    // For now, return simulated leaderboard with current user
    // In future, this would fetch from cloud database
    final entries = _generateSimulatedLeaderboard(currentUserEntry);

    // Save leaderboard
    await _saveLeaderboard(entries);

    return entries;
  }

  /// Generate simulated leaderboard (for demo purposes)
  static List<LeaderboardEntry> _generateSimulatedLeaderboard(
    LeaderboardEntry currentUser,
  ) {
    final entries = <LeaderboardEntry>[
      currentUser,
      // Simulated other users (for demonstration)
      LeaderboardEntry(
        rank: 2,
        userName: 'John D.',
        level: currentUser.level > 1 ? currentUser.level - 1 : 1,
        totalXP: currentUser.totalXP > 200 ? currentUser.totalXP - 200 : 50,
        isCurrentUser: false,
      ),
      LeaderboardEntry(
        rank: 3,
        userName: 'Sarah M.',
        level: currentUser.level > 1 ? currentUser.level - 1 : 1,
        totalXP: currentUser.totalXP > 350 ? currentUser.totalXP - 350 : 30,
        isCurrentUser: false,
      ),
      LeaderboardEntry(
        rank: 4,
        userName: 'David L.',
        level: currentUser.level > 2 ? currentUser.level - 2 : 1,
        totalXP: currentUser.totalXP > 500 ? currentUser.totalXP - 500 : 20,
        isCurrentUser: false,
      ),
      LeaderboardEntry(
        rank: 5,
        userName: 'Maria G.',
        level: currentUser.level > 2 ? currentUser.level - 2 : 1,
        totalXP: currentUser.totalXP > 700 ? currentUser.totalXP - 700 : 10,
        isCurrentUser: false,
      ),
    ];

    // Sort by XP and assign proper ranks
    entries.sort((a, b) => b.totalXP.compareTo(a.totalXP));
    for (int i = 0; i < entries.length; i++) {
      entries[i] = entries[i].copyWith(rank: i + 1);
    }

    return entries;
  }

  /// Save leaderboard
  static Future<void> _saveLeaderboard(List<LeaderboardEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    final entriesJson = entries.map((e) => e.toJson()).toList();
    await prefs.setString(_leaderboardKey, jsonEncode(entriesJson));
  }

  /// Set user display name
  static Future<void> setUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userNameKey, name);
  }

  /// Get user display name
  static Future<String> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userNameKey) ?? 'You';
  }

  /// Get user's rank
  static Future<int> getUserRank() async {
    final leaderboard = await getLeaderboard();
    final userEntry = leaderboard.firstWhere(
      (e) => e.isCurrentUser,
      orElse: () => leaderboard.first,
    );
    return userEntry.rank;
  }
}

/// Leaderboard entry model
class LeaderboardEntry {
  final int rank;
  final String userName;
  final int level;
  final int totalXP;
  final bool isCurrentUser;

  LeaderboardEntry({
    required this.rank,
    required this.userName,
    required this.level,
    required this.totalXP,
    this.isCurrentUser = false,
  });

  String get rankDisplay {
    switch (rank) {
      case 1:
        return '🥇';
      case 2:
        return '🥈';
      case 3:
        return '🥉';
      default:
        return '#$rank';
    }
  }

  Map<String, dynamic> toJson() => {
        'rank': rank,
        'userName': userName,
        'level': level,
        'totalXP': totalXP,
        'isCurrentUser': isCurrentUser,
      };

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) => LeaderboardEntry(
        rank: json['rank'],
        userName: json['userName'],
        level: json['level'],
        totalXP: json['totalXP'],
        isCurrentUser: json['isCurrentUser'] ?? false,
      );

  LeaderboardEntry copyWith({
    int? rank,
    String? userName,
    int? level,
    int? totalXP,
    bool? isCurrentUser,
  }) {
    return LeaderboardEntry(
      rank: rank ?? this.rank,
      userName: userName ?? this.userName,
      level: level ?? this.level,
      totalXP: totalXP ?? this.totalXP,
      isCurrentUser: isCurrentUser ?? this.isCurrentUser,
    );
  }
}

/// Leaderboard period
enum LeaderboardPeriod {
  daily,
  weekly,
  monthly,
  allTime,
}

