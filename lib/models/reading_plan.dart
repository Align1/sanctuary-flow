class ReadingPlan {
  final String id;
  final String name;
  final String description;
  final String type; // 'preset', 'custom'
  final int durationDays; // Total days to complete
  final DateTime? startDate;
  final DateTime? completedDate;
  final bool isActive;
  final List<DailyReading> readings;
  final int currentDay; // Which day the user is on (1-based)

  ReadingPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.durationDays,
    this.startDate,
    this.completedDate,
    this.isActive = false,
    required this.readings,
    this.currentDay = 1,
  });

  int get progressPercentage {
    if (readings.isEmpty) return 0;
    final completed = readings.where((r) => r.isCompleted).length;
    return ((completed / readings.length) * 100).round();
  }

  int get daysCompleted => readings.where((r) => r.isCompleted).length;

  int get daysRemaining => readings.where((r) => !r.isCompleted).length;

  DailyReading? get todaysReading {
    if (!isActive || startDate == null) return null;
    final daysSinceStart = DateTime.now().difference(startDate!).inDays;
    final targetDay = daysSinceStart + 1;
    
    if (targetDay > 0 && targetDay <= readings.length) {
      return readings[targetDay - 1];
    }
    return null;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'type': type,
        'durationDays': durationDays,
        'startDate': startDate?.toIso8601String(),
        'completedDate': completedDate?.toIso8601String(),
        'isActive': isActive,
        'readings': readings.map((r) => r.toJson()).toList(),
        'currentDay': currentDay,
      };

  factory ReadingPlan.fromJson(Map<String, dynamic> json) => ReadingPlan(
        id: json['id'],
        name: json['name'],
        description: json['description'],
        type: json['type'],
        durationDays: json['durationDays'],
        startDate: json['startDate'] != null ? DateTime.parse(json['startDate']) : null,
        completedDate: json['completedDate'] != null ? DateTime.parse(json['completedDate']) : null,
        isActive: json['isActive'] ?? false,
        readings: (json['readings'] as List).map((r) => DailyReading.fromJson(r)).toList(),
        currentDay: json['currentDay'] ?? 1,
      );

  ReadingPlan copyWith({
    String? id,
    String? name,
    String? description,
    String? type,
    int? durationDays,
    DateTime? startDate,
    DateTime? completedDate,
    bool? isActive,
    List<DailyReading>? readings,
    int? currentDay,
  }) {
    return ReadingPlan(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      durationDays: durationDays ?? this.durationDays,
      startDate: startDate ?? this.startDate,
      completedDate: completedDate ?? this.completedDate,
      isActive: isActive ?? this.isActive,
      readings: readings ?? this.readings,
      currentDay: currentDay ?? this.currentDay,
    );
  }
}

class DailyReading {
  final int day; // Day number (1-based)
  final String bookName;
  final String chapters; // e.g., "1", "1-3", "1:1-10"
  final bool isCompleted;
  final DateTime? completedDate;

  DailyReading({
    required this.day,
    required this.bookName,
    required this.chapters,
    this.isCompleted = false,
    this.completedDate,
  });

  Map<String, dynamic> toJson() => {
        'day': day,
        'bookName': bookName,
        'chapters': chapters,
        'isCompleted': isCompleted,
        'completedDate': completedDate?.toIso8601String(),
      };

  factory DailyReading.fromJson(Map<String, dynamic> json) => DailyReading(
        day: json['day'],
        bookName: json['bookName'],
        chapters: json['chapters'],
        isCompleted: json['isCompleted'] ?? false,
        completedDate: json['completedDate'] != null ? DateTime.parse(json['completedDate']) : null,
      );

  DailyReading copyWith({
    int? day,
    String? bookName,
    String? chapters,
    bool? isCompleted,
    DateTime? completedDate,
  }) {
    return DailyReading(
      day: day ?? this.day,
      bookName: bookName ?? this.bookName,
      chapters: chapters ?? this.chapters,
      isCompleted: isCompleted ?? this.isCompleted,
      completedDate: completedDate ?? this.completedDate,
    );
  }
}

