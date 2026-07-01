class BibleReading {
  final String id;
  final String bookName;
  final String chapter;
  final String verse;
  final DateTime dateRead;
  final int minutesSpent;
  final String? notes;

  BibleReading({
    required this.id,
    required this.bookName,
    required this.chapter,
    required this.verse,
    required this.dateRead,
    required this.minutesSpent,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'bookName': bookName,
        'chapter': chapter,
        'verse': verse,
        'dateRead': dateRead.toIso8601String(),
        'minutesSpent': minutesSpent,
        'notes': notes,
      };

  factory BibleReading.fromJson(Map<String, dynamic> json) => BibleReading(
        id: json['id'],
        bookName: json['bookName'],
        chapter: json['chapter'],
        verse: json['verse'],
        dateRead: DateTime.parse(json['dateRead']),
        minutesSpent: json['minutesSpent'],
        notes: json['notes'],
      );
}
