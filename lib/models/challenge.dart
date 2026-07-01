/// Challenge model for gamification
class Challenge {
  final String id;
  final String title;
  final String description;
  final ChallengeType type;
  final ChallengeDifficulty difficulty;
  final int xpReward;
  final int targetValue;
  final int currentProgress;
  final DateTime startDate;
  final DateTime endDate;
  final bool isCompleted;
  final DateTime? completedAt;
  final String icon;

  Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.difficulty,
    required this.xpReward,
    required this.targetValue,
    this.currentProgress = 0,
    required this.startDate,
    required this.endDate,
    this.isCompleted = false,
    this.completedAt,
    this.icon = '🎯',
  });

  double get progressPercentage {
    if (targetValue == 0) return 1.0;
    return (currentProgress / targetValue).clamp(0.0, 1.0);
  }

  bool get isExpired => DateTime.now().isAfter(endDate);
  bool get isActive => !isCompleted && !isExpired;
  int get daysRemaining => endDate.difference(DateTime.now()).inDays;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'type': type.toString(),
        'difficulty': difficulty.toString(),
        'xpReward': xpReward,
        'targetValue': targetValue,
        'currentProgress': currentProgress,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'isCompleted': isCompleted,
        'completedAt': completedAt?.toIso8601String(),
        'icon': icon,
      };

  factory Challenge.fromJson(Map<String, dynamic> json) => Challenge(
        id: json['id'],
        title: json['title'],
        description: json['description'],
        type: ChallengeType.values.firstWhere(
          (e) => e.toString() == json['type'],
          orElse: () => ChallengeType.daily,
        ),
        difficulty: ChallengeDifficulty.values.firstWhere(
          (e) => e.toString() == json['difficulty'],
          orElse: () => ChallengeDifficulty.easy,
        ),
        xpReward: json['xpReward'],
        targetValue: json['targetValue'],
        currentProgress: json['currentProgress'] ?? 0,
        startDate: DateTime.parse(json['startDate']),
        endDate: DateTime.parse(json['endDate']),
        isCompleted: json['isCompleted'] ?? false,
        completedAt: json['completedAt'] != null
            ? DateTime.parse(json['completedAt'])
            : null,
        icon: json['icon'] ?? '🎯',
      );

  Challenge copyWith({
    int? currentProgress,
    bool? isCompleted,
    DateTime? completedAt,
  }) {
    return Challenge(
      id: id,
      title: title,
      description: description,
      type: type,
      difficulty: difficulty,
      xpReward: xpReward,
      targetValue: targetValue,
      currentProgress: currentProgress ?? this.currentProgress,
      startDate: startDate,
      endDate: endDate,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      icon: icon,
    );
  }
}

/// Challenge types
enum ChallengeType {
  daily,    // Daily challenges (24 hours)
  weekly,   // Weekly challenges (7 days)
  monthly,  // Monthly challenges (30 days)
  special,  // Special limited-time events
}

/// Challenge difficulty levels
enum ChallengeDifficulty {
  easy,     // Easy challenges
  medium,   // Medium challenges
  hard,     // Hard challenges
  expert,   // Expert challenges
}

/// User progress in gamification
class UserProgress {
  final int totalXP;
  final int level;
  final List<String> unlockedBadges;
  final List<String> completedChallenges;
  final Map<String, int> stats;
  final DateTime firstLoginDate;
  final DateTime lastActivityDate;

  UserProgress({
    this.totalXP = 0,
    this.level = 1,
    this.unlockedBadges = const [],
    this.completedChallenges = const [],
    this.stats = const {},
    DateTime? firstLoginDate,
    DateTime? lastActivityDate,
  })  : firstLoginDate = firstLoginDate ?? DateTime.now(),
        lastActivityDate = lastActivityDate ?? DateTime.now();

  int get daysActive {
    return DateTime.now().difference(firstLoginDate).inDays + 1;
  }

  Map<String, dynamic> toJson() => {
        'totalXP': totalXP,
        'level': level,
        'unlockedBadges': unlockedBadges,
        'completedChallenges': completedChallenges,
        'stats': stats,
        'firstLoginDate': firstLoginDate.toIso8601String(),
        'lastActivityDate': lastActivityDate.toIso8601String(),
      };

  factory UserProgress.fromJson(Map<String, dynamic> json) => UserProgress(
        totalXP: json['totalXP'] ?? 0,
        level: json['level'] ?? 1,
        unlockedBadges: List<String>.from(json['unlockedBadges'] ?? []),
        completedChallenges:
            List<String>.from(json['completedChallenges'] ?? []),
        stats: Map<String, int>.from(json['stats'] ?? {}),
        firstLoginDate: json['firstLoginDate'] != null
            ? DateTime.parse(json['firstLoginDate'])
            : null,
        lastActivityDate: json['lastActivityDate'] != null
            ? DateTime.parse(json['lastActivityDate'])
            : null,
      );

  UserProgress copyWith({
    int? totalXP,
    int? level,
    List<String>? unlockedBadges,
    List<String>? completedChallenges,
    Map<String, int>? stats,
    DateTime? lastActivityDate,
  }) {
    return UserProgress(
      totalXP: totalXP ?? this.totalXP,
      level: level ?? this.level,
      unlockedBadges: unlockedBadges ?? this.unlockedBadges,
      completedChallenges: completedChallenges ?? this.completedChallenges,
      stats: stats ?? this.stats,
      firstLoginDate: firstLoginDate,
      lastActivityDate: lastActivityDate ?? this.lastActivityDate,
    );
  }
}

