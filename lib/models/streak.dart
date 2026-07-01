class ReadingStreak {
  final int currentStreak; // Current consecutive days
  final int longestStreak; // Longest streak ever achieved
  final int weeklyStreak; // Current consecutive weeks
  final int longestWeeklyStreak; // Longest weekly streak
  final DateTime? lastReadingDate;
  final DateTime? streakStartDate;
  final List<DateTime> readingDays; // Days when reading occurred

  ReadingStreak({
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.weeklyStreak = 0,
    this.longestWeeklyStreak = 0,
    this.lastReadingDate,
    this.streakStartDate,
    this.readingDays = const [],
  });

  Map<String, dynamic> toJson() => {
        'currentStreak': currentStreak,
        'longestStreak': longestStreak,
        'weeklyStreak': weeklyStreak,
        'longestWeeklyStreak': longestWeeklyStreak,
        'lastReadingDate': lastReadingDate?.toIso8601String(),
        'streakStartDate': streakStartDate?.toIso8601String(),
        'readingDays': readingDays.map((d) => d.toIso8601String()).toList(),
      };

  factory ReadingStreak.fromJson(Map<String, dynamic> json) => ReadingStreak(
        currentStreak: json['currentStreak'] ?? 0,
        longestStreak: json['longestStreak'] ?? 0,
        weeklyStreak: json['weeklyStreak'] ?? 0,
        longestWeeklyStreak: json['longestWeeklyStreak'] ?? 0,
        lastReadingDate: json['lastReadingDate'] != null
            ? DateTime.parse(json['lastReadingDate'])
            : null,
        streakStartDate: json['streakStartDate'] != null
            ? DateTime.parse(json['streakStartDate'])
            : null,
        readingDays: json['readingDays'] != null
            ? (json['readingDays'] as List)
                .map((d) => DateTime.parse(d))
                .toList()
            : [],
      );

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  bool hasReadToday() {
    if (lastReadingDate == null) return false;
    return isSameDay(lastReadingDate!, DateTime.now());
  }

  bool hasReadThisWeek() {
    if (readingDays.isEmpty) return false;
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    return readingDays.any((date) => date.isAfter(weekStart.subtract(const Duration(days: 1))));
  }
}

