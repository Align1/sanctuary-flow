import 'package:sanctuaryflow/models/bible_reading.dart';
import 'package:sanctuaryflow/models/prayer_schedule.dart';
import 'package:sanctuaryflow/models/message_session.dart';
import 'package:sanctuaryflow/models/book_reading.dart';
import 'package:sanctuaryflow/models/spiritual_goal.dart';
import 'package:sanctuaryflow/services/local_storage_service.dart';

class SampleDataService {
  static Future<void> initializeSampleData() async {
    // Check if we already have data
    final existingBooks = await LocalStorageService.getBookReadings();
    if (existingBooks.isNotEmpty) return; // Data already exists

    // Add sample Bible readings
    await _addSampleBibleReadings();
    
    // Add sample prayer schedules
    await _addSamplePrayerSchedules();
    
    // Add sample message sessions
    await _addSampleMessageSessions();
    
    // Add sample books
    await _addSampleBooks();
    
    // Add sample goals
    await _addSampleGoals();
  }

  static Future<void> _addSampleBibleReadings() async {
    final readings = [
      BibleReading(
        id: 'bible_1',
        bookName: 'Genesis',
        chapter: '1',
        verse: '1-10',
        dateRead: DateTime.now().subtract(const Duration(days: 1)),
        minutesSpent: 15,
        notes: 'Amazing creation story. God\'s power is incredible.',
      ),
      BibleReading(
        id: 'bible_2',
        bookName: 'Psalms',
        chapter: '23',
        verse: 'All',
        dateRead: DateTime.now().subtract(const Duration(days: 2)),
        minutesSpent: 10,
        notes: 'The Lord is my shepherd - such comfort in this psalm.',
      ),
      BibleReading(
        id: 'bible_3',
        bookName: 'Matthew',
        chapter: '5',
        verse: '1-12',
        dateRead: DateTime.now().subtract(const Duration(days: 3)),
        minutesSpent: 20,
        notes: 'The Beatitudes - Jesus\' teachings on blessed living.',
      ),
    ];

    for (final reading in readings) {
      await LocalStorageService.saveBibleReading(reading);
    }
  }

  static Future<void> _addSamplePrayerSchedules() async {
    final schedules = [
      PrayerSchedule(
        id: 'prayer_1',
        title: 'Morning Prayer',
        scheduledTime: DateTime(2024, 1, 1, 7, 0),
        weekdays: [1, 2, 3, 4, 5, 6, 7], // Every day
        isActive: true,
        description: 'Start the day with gratitude and seeking God\'s guidance',
      ),
      PrayerSchedule(
        id: 'prayer_2',
        title: 'Evening Prayer',
        scheduledTime: DateTime(2024, 1, 1, 21, 0),
        weekdays: [1, 2, 3, 4, 5, 6, 7], // Every day
        isActive: true,
        description: 'End the day with reflection and thanksgiving',
      ),
      PrayerSchedule(
        id: 'prayer_3',
        title: 'Sunday Worship Prayer',
        scheduledTime: DateTime(2024, 1, 1, 9, 30),
        weekdays: [7], // Sunday only
        isActive: true,
        description: 'Preparation prayer before Sunday service',
      ),
    ];

    for (final schedule in schedules) {
      await LocalStorageService.savePrayerSchedule(schedule);
    }
  }

  static Future<void> _addSampleMessageSessions() async {
    final sessions = [
      MessageSession(
        id: 'message_1',
        title: 'The Power of Faith in Difficult Times',
        speaker: 'Pastor David Johnson',
        dateListened: DateTime.now().subtract(const Duration(days: 1)),
        minutesListened: 45,
        source: 'Church Service',
        notes: 'Powerful message about trusting God during trials. Key verse: Romans 8:28',
        rating: 5.0,
        tags: ['faith', 'trials', 'trust'],
      ),
      MessageSession(
        id: 'message_2',
        title: 'Walking in Love: Practical Christianity',
        speaker: 'Pastor Sarah Williams',
        dateListened: DateTime.now().subtract(const Duration(days: 3)),
        minutesListened: 30,
        source: 'Podcast',
        notes: 'Great practical examples of showing love to others daily.',
        rating: 4.0,
        tags: ['love', 'practical', 'daily living'],
      ),
      MessageSession(
        id: 'message_3',
        title: 'Understanding Grace',
        speaker: 'Dr. Michael Chen',
        dateListened: DateTime.now().subtract(const Duration(days: 5)),
        minutesListened: 55,
        source: 'YouTube',
        notes: 'Deep dive into the concept of grace. Very theological but accessible.',
        rating: 5.0,
        tags: ['grace', 'theology', 'salvation'],
      ),
    ];

    for (final session in sessions) {
      await LocalStorageService.saveMessageSession(session);
    }
  }

  static Future<void> _addSampleBooks() async {
    final books = [
      BookReading(
        id: 'book_1',
        title: 'Mere Christianity',
        author: 'C.S. Lewis',
        totalPages: 227,
        currentPage: 85,
        startDate: DateTime.now().subtract(const Duration(days: 15)),
        status: 'Reading',
        notes: 'Excellent logical presentation of Christian faith.',
        rating: null,
        tags: ['apologetics', 'philosophy'],
      ),
      BookReading(
        id: 'book_2',
        title: 'The Purpose Driven Life',
        author: 'Rick Warren',
        totalPages: 334,
        currentPage: 334,
        startDate: DateTime.now().subtract(const Duration(days: 40)),
        completedDate: DateTime.now().subtract(const Duration(days: 5)),
        status: 'Completed',
        notes: 'Life-changing book about finding God\'s purpose for your life.',
        rating: 5.0,
        tags: ['purpose', 'spiritual growth'],
      ),
      BookReading(
        id: 'book_3',
        title: 'Jesus Calling',
        author: 'Sarah Young',
        totalPages: 400,
        currentPage: 120,
        startDate: DateTime.now().subtract(const Duration(days: 20)),
        status: 'Reading',
        notes: 'Daily devotional with beautiful messages from Jesus\' perspective.',
        rating: null,
        tags: ['devotional', 'daily reading'],
      ),
    ];

    for (final book in books) {
      await LocalStorageService.saveBookReading(book);
    }
  }

  static Future<void> _addSampleGoals() async {
    final goals = [
      SpiritualGoal(
        id: 'goal_1',
        title: 'Read Bible Daily',
        description: 'Read at least one chapter of the Bible every day',
        category: 'Bible Study',
        startDate: DateTime.now().subtract(const Duration(days: 10)),
        frequency: 'Daily',
        targetCount: 30,
        currentCount: 8,
        isCompleted: false,
        status: 'Active',
      ),
      SpiritualGoal(
        id: 'goal_2',
        title: 'Morning Prayer Habit',
        description: 'Start each day with 10 minutes of prayer',
        category: 'Prayer',
        startDate: DateTime.now().subtract(const Duration(days: 7)),
        frequency: 'Daily',
        targetCount: 21,
        currentCount: 6,
        isCompleted: false,
        status: 'Active',
      ),
      SpiritualGoal(
        id: 'goal_3',
        title: 'Complete Purpose Driven Life',
        description: 'Read through Rick Warren\'s Purpose Driven Life',
        category: 'Bible Study',
        startDate: DateTime.now().subtract(const Duration(days: 40)),
        frequency: 'Custom',
        targetCount: 1,
        currentCount: 1,
        isCompleted: true,
        status: 'Completed',
      ),
      SpiritualGoal(
        id: 'goal_4',
        title: 'Weekly Church Attendance',
        description: 'Attend church service every Sunday',
        category: 'Worship',
        startDate: DateTime.now().subtract(const Duration(days: 21)),
        frequency: 'Weekly',
        targetCount: 12,
        currentCount: 3,
        isCompleted: false,
        status: 'Active',
      ),
    ];

    for (final goal in goals) {
      await LocalStorageService.saveSpiritualGoal(goal);
    }
  }
}