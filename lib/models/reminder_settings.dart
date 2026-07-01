class ReminderSettings {
  final bool dailyReadingEnabled;
  final int dailyReadingHour;
  final int dailyReadingMinute;
  final bool missedActivityEnabled;
  final bool weeklyProgressEnabled;
  final DayOfWeek weeklyProgressDay;
  final int weeklyProgressHour;
  final int weeklyProgressMinute;
  final bool streakPreservationEnabled;
  final int streakWarningHours; // Hours before day ends to warn about streak

  ReminderSettings({
    this.dailyReadingEnabled = true,
    this.dailyReadingHour = 9,
    this.dailyReadingMinute = 0,
    this.missedActivityEnabled = true,
    this.weeklyProgressEnabled = true,
    this.weeklyProgressDay = DayOfWeek.sunday,
    this.weeklyProgressHour = 20,
    this.weeklyProgressMinute = 0,
    this.streakPreservationEnabled = true,
    this.streakWarningHours = 3, // Warn 3 hours before midnight
  });

  Map<String, dynamic> toJson() => {
        'dailyReadingEnabled': dailyReadingEnabled,
        'dailyReadingHour': dailyReadingHour,
        'dailyReadingMinute': dailyReadingMinute,
        'missedActivityEnabled': missedActivityEnabled,
        'weeklyProgressEnabled': weeklyProgressEnabled,
        'weeklyProgressDay': weeklyProgressDay.index,
        'weeklyProgressHour': weeklyProgressHour,
        'weeklyProgressMinute': weeklyProgressMinute,
        'streakPreservationEnabled': streakPreservationEnabled,
        'streakWarningHours': streakWarningHours,
      };

  factory ReminderSettings.fromJson(Map<String, dynamic> json) {
    return ReminderSettings(
      dailyReadingEnabled: json['dailyReadingEnabled'] ?? true,
      dailyReadingHour: json['dailyReadingHour'] ?? 9,
      dailyReadingMinute: json['dailyReadingMinute'] ?? 0,
      missedActivityEnabled: json['missedActivityEnabled'] ?? true,
      weeklyProgressEnabled: json['weeklyProgressEnabled'] ?? true,
      weeklyProgressDay: json['weeklyProgressDay'] != null
          ? DayOfWeek.values[json['weeklyProgressDay']]
          : DayOfWeek.sunday,
      weeklyProgressHour: json['weeklyProgressHour'] ?? 20,
      weeklyProgressMinute: json['weeklyProgressMinute'] ?? 0,
      streakPreservationEnabled: json['streakPreservationEnabled'] ?? true,
      streakWarningHours: json['streakWarningHours'] ?? 3,
    );
  }

  ReminderSettings copyWith({
    bool? dailyReadingEnabled,
    int? dailyReadingHour,
    int? dailyReadingMinute,
    bool? missedActivityEnabled,
    bool? weeklyProgressEnabled,
    DayOfWeek? weeklyProgressDay,
    int? weeklyProgressHour,
    int? weeklyProgressMinute,
    bool? streakPreservationEnabled,
    int? streakWarningHours,
  }) {
    return ReminderSettings(
      dailyReadingEnabled: dailyReadingEnabled ?? this.dailyReadingEnabled,
      dailyReadingHour: dailyReadingHour ?? this.dailyReadingHour,
      dailyReadingMinute: dailyReadingMinute ?? this.dailyReadingMinute,
      missedActivityEnabled: missedActivityEnabled ?? this.missedActivityEnabled,
      weeklyProgressEnabled: weeklyProgressEnabled ?? this.weeklyProgressEnabled,
      weeklyProgressDay: weeklyProgressDay ?? this.weeklyProgressDay,
      weeklyProgressHour: weeklyProgressHour ?? this.weeklyProgressHour,
      weeklyProgressMinute: weeklyProgressMinute ?? this.weeklyProgressMinute,
      streakPreservationEnabled: streakPreservationEnabled ?? this.streakPreservationEnabled,
      streakWarningHours: streakWarningHours ?? this.streakWarningHours,
    );
  }

  String formatTime(int hour, int minute) {
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return '${displayHour.toString()}:${minute.toString().padLeft(2, '0')} $period';
  }
}

enum DayOfWeek {
  monday,
  tuesday,
  wednesday,
  thursday,
  friday,
  saturday,
  sunday,
}

extension DayOfWeekExtension on DayOfWeek {
  String get displayName {
    switch (this) {
      case DayOfWeek.monday:
        return 'Monday';
      case DayOfWeek.tuesday:
        return 'Tuesday';
      case DayOfWeek.wednesday:
        return 'Wednesday';
      case DayOfWeek.thursday:
        return 'Thursday';
      case DayOfWeek.friday:
        return 'Friday';
      case DayOfWeek.saturday:
        return 'Saturday';
      case DayOfWeek.sunday:
        return 'Sunday';
    }
  }

  int get weekdayNumber {
    // Convert to 1-7 (Monday = 1, Sunday = 7)
    return index + 1;
  }
}

