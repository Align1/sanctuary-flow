/// User level model for gamification
class UserLevel {
  final int level;
  final int currentXP;
  final int xpForNextLevel;
  final String title;
  final String description;
  final List<String> perks;

  UserLevel({
    required this.level,
    required this.currentXP,
    required this.xpForNextLevel,
    required this.title,
    required this.description,
    this.perks = const [],
  });

  double get progressToNextLevel {
    if (xpForNextLevel == 0) return 1.0;
    return currentXP / xpForNextLevel;
  }

  int get xpNeeded => xpForNextLevel - currentXP;

  Map<String, dynamic> toJson() => {
        'level': level,
        'currentXP': currentXP,
        'xpForNextLevel': xpForNextLevel,
        'title': title,
        'description': description,
        'perks': perks,
      };

  factory UserLevel.fromJson(Map<String, dynamic> json) => UserLevel(
        level: json['level'] ?? 1,
        currentXP: json['currentXP'] ?? 0,
        xpForNextLevel: json['xpForNextLevel'] ?? 100,
        title: json['title'] ?? 'Seeker',
        description: json['description'] ?? 'Beginning your journey',
        perks: List<String>.from(json['perks'] ?? []),
      );
}

/// Level tier definitions
class LevelTier {
  final int level;
  final String title;
  final String description;
  final int xpRequired;
  final List<String> perks;
  final String icon;

  const LevelTier({
    required this.level,
    required this.title,
    required this.description,
    required this.xpRequired,
    this.perks = const [],
    this.icon = '⭐',
  });
}

/// Predefined level tiers
class LevelTiers {
  static const List<LevelTier> tiers = [
    LevelTier(
      level: 1,
      title: 'Seeker',
      description: 'Beginning your spiritual journey',
      xpRequired: 0,
      perks: ['Access to daily verses'],
      icon: '🌱',
    ),
    LevelTier(
      level: 2,
      title: 'Believer',
      description: 'Growing in faith',
      xpRequired: 100,
      perks: ['Custom prayer times', 'Reading plans'],
      icon: '✝️',
    ),
    LevelTier(
      level: 3,
      title: 'Disciple',
      description: 'Committed to daily practice',
      xpRequired: 250,
      perks: ['Advanced goals', 'Message tracking'],
      icon: '📖',
    ),
    LevelTier(
      level: 4,
      title: 'Follower',
      description: 'Walking the path consistently',
      xpRequired: 500,
      perks: ['Streak bonuses', 'Special badges'],
      icon: '🙏',
    ),
    LevelTier(
      level: 5,
      title: 'Servant',
      description: 'Serving through practice',
      xpRequired: 1000,
      perks: ['Custom challenges', 'Advanced stats'],
      icon: '💫',
    ),
    LevelTier(
      level: 6,
      title: 'Teacher',
      description: 'Sharing wisdom with others',
      xpRequired: 2000,
      perks: ['Sharing features', 'Mentorship'],
      icon: '📚',
    ),
    LevelTier(
      level: 7,
      title: 'Leader',
      description: 'Leading by example',
      xpRequired: 4000,
      perks: ['Group features', 'Leadership tools'],
      icon: '👑',
    ),
    LevelTier(
      level: 8,
      title: 'Shepherd',
      description: 'Guiding others in faith',
      xpRequired: 8000,
      perks: ['Community features', 'Advanced sharing'],
      icon: '🕊️',
    ),
    LevelTier(
      level: 9,
      title: 'Warrior',
      description: 'Strong in spiritual battles',
      xpRequired: 15000,
      perks: ['All features unlocked', 'Exclusive badges'],
      icon: '⚔️',
    ),
    LevelTier(
      level: 10,
      title: 'Saint',
      description: 'Master of spiritual growth',
      xpRequired: 30000,
      perks: ['Legendary status', 'All perks', 'Special recognition'],
      icon: '✨',
    ),
  ];

  static LevelTier getTierForLevel(int level) {
    if (level >= tiers.length) return tiers.last;
    return tiers[level - 1];
  }

  static LevelTier getNextTier(int currentLevel) {
    if (currentLevel >= tiers.length) return tiers.last;
    return tiers[currentLevel];
  }

  static int getXPForLevel(int level) {
    if (level >= tiers.length) return tiers.last.xpRequired;
    return tiers[level - 1].xpRequired;
  }
}

