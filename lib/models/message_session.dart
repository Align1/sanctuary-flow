class MessageSession {
  final String id;
  final String title;
  final String speaker;
  final DateTime dateListened;
  final int minutesListened;
  final String source; // 'Podcast', 'YouTube', 'Church Service', etc.
  final String? notes;
  final double? rating; // 1-5 stars
  final List<String> tags;

  MessageSession({
    required this.id,
    required this.title,
    required this.speaker,
    required this.dateListened,
    required this.minutesListened,
    required this.source,
    this.notes,
    this.rating,
    this.tags = const [],
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'speaker': speaker,
        'dateListened': dateListened.toIso8601String(),
        'minutesListened': minutesListened,
        'source': source,
        'notes': notes,
        'rating': rating,
        'tags': tags,
      };

  factory MessageSession.fromJson(Map<String, dynamic> json) => MessageSession(
        id: json['id'],
        title: json['title'],
        speaker: json['speaker'],
        dateListened: DateTime.parse(json['dateListened']),
        minutesListened: json['minutesListened'],
        source: json['source'],
        notes: json['notes'],
        rating: json['rating']?.toDouble(),
        tags: List<String>.from(json['tags'] ?? []),
      );
}