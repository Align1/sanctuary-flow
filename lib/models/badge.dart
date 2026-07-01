/// Badge model for gamification
class Badge {
  final String id;
  final String name;
  final String description;
  final String icon;
  final BadgeRarity rarity;
  final BadgeCategory category;
  final int xpReward;
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final int progress;
  final int requirement;

  Badge({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.rarity,
    required this.category,
    this.xpReward = 0,
    this.isUnlocked = false,
    this.unlockedAt,
    this.progress = 0,
    this.requirement = 1,
  });

  double get progressPercentage {
    if (requirement == 0) return 1.0;
    return (progress / requirement).clamp(0.0, 1.0);
  }

  bool get isCompleted => progress >= requirement;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'icon': icon,
        'rarity': rarity.toString(),
        'category': category.toString(),
        'xpReward': xpReward,
        'isUnlocked': isUnlocked,
        'unlockedAt': unlockedAt?.toIso8601String(),
        'progress': progress,
        'requirement': requirement,
      };

  factory Badge.fromJson(Map<String, dynamic> json) => Badge(
        id: json['id'],
        name: json['name'],
        description: json['description'],
        icon: json['icon'],
        rarity: BadgeRarity.values.firstWhere(
          (e) => e.toString() == json['rarity'],
          orElse: () => BadgeRarity.common,
        ),
        category: BadgeCategory.values.firstWhere(
          (e) => e.toString() == json['category'],
          orElse: () => BadgeCategory.general,
        ),
        xpReward: json['xpReward'] ?? 0,
        isUnlocked: json['isUnlocked'] ?? false,
        unlockedAt: json['unlockedAt'] != null
            ? DateTime.parse(json['unlockedAt'])
            : null,
        progress: json['progress'] ?? 0,
        requirement: json['requirement'] ?? 1,
      );

  Badge copyWith({
    bool? isUnlocked,
    DateTime? unlockedAt,
    int? progress,
  }) {
    return Badge(
      id: id,
      name: name,
      description: description,
      icon: icon,
      rarity: rarity,
      category: category,
      xpReward: xpReward,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      progress: progress ?? this.progress,
      requirement: requirement,
    );
  }
}

/// Badge rarity levels
enum BadgeRarity {
  common,    // Common badges
  uncommon,  // Uncommon badges
  rare,      // Rare badges
  epic,      // Epic badges
  legendary, // Legendary badges
}

/// Badge categories
enum BadgeCategory {
  general,      // General achievements
  reading,      // Bible reading related
  prayer,       // Prayer related
  streak,       // Streak related
  goals,        // Goals related
  social,       // Social/sharing related
  milestone,    // Major milestones
}

/// Predefined badges
class BadgeDefinitions {
  static final List<Badge> allBadges = [
    // Reading Badges
    Badge(
      id: 'first_reading',
      name: 'First Steps',
      description: 'Complete your first Bible reading',
      icon: '👣',
      rarity: BadgeRarity.common,
      category: BadgeCategory.reading,
      xpReward: 10,
      requirement: 1,
    ),
    Badge(
      id: 'reading_10',
      name: 'Devoted Reader',
      description: 'Complete 10 Bible readings',
      icon: '📖',
      rarity: BadgeRarity.uncommon,
      category: BadgeCategory.reading,
      xpReward: 50,
      requirement: 10,
    ),
    Badge(
      id: 'reading_50',
      name: 'Scripture Scholar',
      description: 'Complete 50 Bible readings',
      icon: '📚',
      rarity: BadgeRarity.rare,
      category: BadgeCategory.reading,
      xpReward: 200,
      requirement: 50,
    ),
    Badge(
      id: 'reading_100',
      name: 'Bible Master',
      description: 'Complete 100 Bible readings',
      icon: '🎓',
      rarity: BadgeRarity.epic,
      category: BadgeCategory.reading,
      xpReward: 500,
      requirement: 100,
    ),

    // Streak Badges
    Badge(
      id: 'streak_7',
      name: 'Week Warrior',
      description: 'Maintain a 7-day reading streak',
      icon: '🔥',
      rarity: BadgeRarity.uncommon,
      category: BadgeCategory.streak,
      xpReward: 100,
      requirement: 7,
    ),
    Badge(
      id: 'streak_30',
      name: 'Monthly Champion',
      description: 'Maintain a 30-day reading streak',
      icon: '🏆',
      rarity: BadgeRarity.rare,
      category: BadgeCategory.streak,
      xpReward: 300,
      requirement: 30,
    ),
    Badge(
      id: 'streak_100',
      name: 'Consistency King',
      description: 'Maintain a 100-day reading streak',
      icon: '👑',
      rarity: BadgeRarity.epic,
      category: BadgeCategory.streak,
      xpReward: 1000,
      requirement: 100,
    ),
    Badge(
      id: 'streak_365',
      name: 'Year of Devotion',
      description: 'Maintain a 365-day reading streak',
      icon: '✨',
      rarity: BadgeRarity.legendary,
      category: BadgeCategory.streak,
      xpReward: 5000,
      requirement: 365,
    ),

    // Prayer Badges
    Badge(
      id: 'prayer_10',
      name: 'Prayer Novice',
      description: 'Complete 10 prayer sessions',
      icon: '🙏',
      rarity: BadgeRarity.common,
      category: BadgeCategory.prayer,
      xpReward: 50,
      requirement: 10,
    ),
    Badge(
      id: 'prayer_50',
      name: 'Prayer Warrior',
      description: 'Complete 50 prayer sessions',
      icon: '⚡',
      rarity: BadgeRarity.rare,
      category: BadgeCategory.prayer,
      xpReward: 250,
      requirement: 50,
    ),

    // Goals Badges
    Badge(
      id: 'goal_complete',
      name: 'Goal Getter',
      description: 'Complete your first spiritual goal',
      icon: '🎯',
      rarity: BadgeRarity.common,
      category: BadgeCategory.goals,
      xpReward: 75,
      requirement: 1,
    ),
    Badge(
      id: 'goal_10',
      name: 'Achiever',
      description: 'Complete 10 spiritual goals',
      icon: '🌟',
      rarity: BadgeRarity.rare,
      category: BadgeCategory.goals,
      xpReward: 500,
      requirement: 10,
    ),

    // Milestone Badges
    Badge(
      id: 'first_week',
      name: 'One Week Strong',
      description: 'Use the app for 7 days',
      icon: '📅',
      rarity: BadgeRarity.common,
      category: BadgeCategory.milestone,
      xpReward: 50,
      requirement: 7,
    ),
    Badge(
      id: 'first_month',
      name: 'Monthly Milestone',
      description: 'Use the app for 30 days',
      icon: '🗓️',
      rarity: BadgeRarity.uncommon,
      category: BadgeCategory.milestone,
      xpReward: 150,
      requirement: 30,
    ),
    Badge(
      id: 'first_year',
      name: 'Year of Growth',
      description: 'Use the app for 365 days',
      icon: '🎊',
      rarity: BadgeRarity.legendary,
      category: BadgeCategory.milestone,
      xpReward: 2000,
      requirement: 365,
    ),

    // Social Badges
    Badge(
      id: 'share_first',
      name: 'Word Spreader',
      description: 'Share your first verse',
      icon: '📢',
      rarity: BadgeRarity.common,
      category: BadgeCategory.social,
      xpReward: 25,
      requirement: 1,
    ),
    Badge(
      id: 'share_10',
      name: 'Evangelist',
      description: 'Share 10 verses',
      icon: '💬',
      rarity: BadgeRarity.uncommon,
      category: BadgeCategory.social,
      xpReward: 100,
      requirement: 10,
    ),
  ];
}

