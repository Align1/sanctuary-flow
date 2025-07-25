class PrayerSchedule {
  final String id;
  final String title;
  final DateTime scheduledTime;
  final List<int> weekdays; // 1-7 (Monday-Sunday)
  final bool isActive;
  final String? description;

  PrayerSchedule({
    required this.id,
    required this.title,
    required this.scheduledTime,
    required this.weekdays,
    required this.isActive,
    this.description,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'scheduledTime': scheduledTime.toIso8601String(),
        'weekdays': weekdays,
        'isActive': isActive,
        'description': description,
      };

  factory PrayerSchedule.fromJson(Map<String, dynamic> json) => PrayerSchedule(
        id: json['id'],
        title: json['title'],
        scheduledTime: DateTime.parse(json['scheduledTime']),
        weekdays: List<int>.from(json['weekdays']),
        isActive: json['isActive'],
        description: json['description'],
      );
}

class PrayerSession {
  final String id;
  final DateTime startTime;
  final DateTime? endTime;
  final int minutesPrayed;
  final String? notes;
  final String? prayerType;

  PrayerSession({
    required this.id,
    required this.startTime,
    this.endTime,
    required this.minutesPrayed,
    this.notes,
    this.prayerType,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'startTime': startTime.toIso8601String(),
        'endTime': endTime?.toIso8601String(),
        'minutesPrayed': minutesPrayed,
        'notes': notes,
        'prayerType': prayerType,
      };

  factory PrayerSession.fromJson(Map<String, dynamic> json) => PrayerSession(
        id: json['id'],
        startTime: DateTime.parse(json['startTime']),
        endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
        minutesPrayed: json['minutesPrayed'],
        notes: json['notes'],
        prayerType: json['prayerType'],
      );
}