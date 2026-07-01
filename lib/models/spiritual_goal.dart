class SpiritualGoal {
  final String id;
  final String title;
  final String description;
  final String category; // 'Prayer', 'Bible Study', 'Service', 'Worship', etc.
  final DateTime startDate;
  final DateTime? targetDate;
  final String frequency; // 'Daily', 'Weekly', 'Monthly', 'Custom'
  final int targetCount;
  final int currentCount;
  final bool isCompleted;
  final String status; // 'Active', 'Completed', 'Paused', 'Archived'
  final List<String> milestones;

  SpiritualGoal({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.startDate,
    this.targetDate,
    required this.frequency,
    required this.targetCount,
    required this.currentCount,
    required this.isCompleted,
    required this.status,
    this.milestones = const [],
  });

  double get progressPercentage =>
      targetCount > 0 ? (currentCount / targetCount) * 100 : 0;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'category': category,
        'startDate': startDate.toIso8601String(),
        'targetDate': targetDate?.toIso8601String(),
        'frequency': frequency,
        'targetCount': targetCount,
        'currentCount': currentCount,
        'isCompleted': isCompleted,
        'status': status,
        'milestones': milestones,
      };

  factory SpiritualGoal.fromJson(Map<String, dynamic> json) => SpiritualGoal(
        id: json['id'],
        title: json['title'],
        description: json['description'],
        category: json['category'],
        startDate: DateTime.parse(json['startDate']),
        targetDate: json['targetDate'] != null
            ? DateTime.parse(json['targetDate'])
            : null,
        frequency: json['frequency'],
        targetCount: json['targetCount'],
        currentCount: json['currentCount'],
        isCompleted: json['isCompleted'],
        status: json['status'],
        milestones: List<String>.from(json['milestones'] ?? []),
      );
}
