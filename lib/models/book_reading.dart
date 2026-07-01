class BookReading {
  final String id;
  final String title;
  final String author;
  final int totalPages;
  final int currentPage;
  final DateTime startDate;
  final DateTime? completedDate;
  final String status; // 'Not Started', 'Reading', 'Completed', 'Paused'
  final String? notes;
  final double? rating; // 1-5 stars
  final List<String> tags;

  BookReading({
    required this.id,
    required this.title,
    required this.author,
    required this.totalPages,
    required this.currentPage,
    required this.startDate,
    this.completedDate,
    required this.status,
    this.notes,
    this.rating,
    this.tags = const [],
  });

  double get progressPercentage => 
      totalPages > 0 ? (currentPage / totalPages) * 100 : 0;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'author': author,
        'totalPages': totalPages,
        'currentPage': currentPage,
        'startDate': startDate.toIso8601String(),
        'completedDate': completedDate?.toIso8601String(),
        'status': status,
        'notes': notes,
        'rating': rating,
        'tags': tags,
      };

  factory BookReading.fromJson(Map<String, dynamic> json) => BookReading(
        id: json['id'],
        title: json['title'],
        author: json['author'],
        totalPages: json['totalPages'],
        currentPage: json['currentPage'],
        startDate: DateTime.parse(json['startDate']),
        completedDate: json['completedDate'] != null 
            ? DateTime.parse(json['completedDate']) 
            : null,
        status: json['status'],
        notes: json['notes'],
        rating: json['rating']?.toDouble(),
        tags: List<String>.from(json['tags'] ?? []),
      );
}
