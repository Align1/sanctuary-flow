class DailyVerse {
  final String id;
  final String verse;
  final String reference;
  final String version; // NIV, ESV, etc.
  final DateTime date;
  final String? reflection;
  final bool isFavorite;
  final List<String> tags;

  DailyVerse({
    required this.id,
    required this.verse,
    required this.reference,
    required this.version,
    required this.date,
    this.reflection,
    this.isFavorite = false,
    this.tags = const [],
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'verse': verse,
        'reference': reference,
        'version': version,
        'date': date.toIso8601String(),
        'reflection': reflection,
        'isFavorite': isFavorite,
        'tags': tags,
      };

  factory DailyVerse.fromJson(Map<String, dynamic> json) => DailyVerse(
        id: json['id'],
        verse: json['verse'],
        reference: json['reference'],
        version: json['version'],
        date: DateTime.parse(json['date']),
        reflection: json['reflection'],
        isFavorite: json['isFavorite'] ?? false,
        tags: List<String>.from(json['tags'] ?? []),
      );
}