class Achievement {
  final String id;
  final String title;
  final String description;
  final String category; // 'bible', 'prayer', 'book', 'goal', 'streak', 'general'
  final int targetValue; // Value needed to unlock
  final int currentValue; // Current progress
  final bool isUnlocked;
  final DateTime? unlockedDate;
  final String iconName; // Icon identifier
  final String badgeColor; // Color for the badge

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.targetValue,
    this.currentValue = 0,
    this.isUnlocked = false,
    this.unlockedDate,
    required this.iconName,
    required this.badgeColor,
  });

  double get progressPercentage =>
      targetValue > 0 ? (currentValue / targetValue * 100).clamp(0.0, 100.0) : 0.0;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'category': category,
        'targetValue': targetValue,
        'currentValue': currentValue,
        'isUnlocked': isUnlocked,
        'unlockedDate': unlockedDate?.toIso8601String(),
        'iconName': iconName,
        'badgeColor': badgeColor,
      };

  factory Achievement.fromJson(Map<String, dynamic> json) => Achievement(
        id: json['id'],
        title: json['title'],
        description: json['description'],
        category: json['category'],
        targetValue: json['targetValue'],
        currentValue: json['currentValue'] ?? 0,
        isUnlocked: json['isUnlocked'] ?? false,
        unlockedDate: json['unlockedDate'] != null
            ? DateTime.parse(json['unlockedDate'])
            : null,
        iconName: json['iconName'],
        badgeColor: json['badgeColor'],
      );

  Achievement copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    int? targetValue,
    int? currentValue,
    bool? isUnlocked,
    DateTime? unlockedDate,
    String? iconName,
    String? badgeColor,
  }) {
    return Achievement(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      targetValue: targetValue ?? this.targetValue,
      currentValue: currentValue ?? this.currentValue,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedDate: unlockedDate ?? this.unlockedDate,
      iconName: iconName ?? this.iconName,
      badgeColor: badgeColor ?? this.badgeColor,
    );
  }
}

