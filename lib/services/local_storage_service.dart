import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rooted/models/bible_reading.dart';
import 'package:rooted/models/prayer_schedule.dart';
import 'package:rooted/models/message_session.dart';
import 'package:rooted/models/book_reading.dart';
import 'package:rooted/models/spiritual_goal.dart';
import 'package:rooted/models/daily_verse.dart';
import 'package:rooted/services/gamification_service.dart';
import 'package:rooted/services/offline_verse_database.dart';

class LocalStorageService {
  static const String _bibleReadingsKey = 'bible_readings';
  static const String _prayerSchedulesKey = 'prayer_schedules';
  static const String _prayerSessionsKey = 'prayer_sessions';
  static const String _messageSessionsKey = 'message_sessions';
  static const String _bookReadingsKey = 'book_readings';
  static const String _spiritualGoalsKey = 'spiritual_goals';
  static const String _dailyVersesKey = 'daily_verses';
  static const String _achievementsKey = 'achievements';

  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Bible Readings
  static Future<void> saveBibleReading(BibleReading reading) async {
    final readings = await getBibleReadings();
    readings.add(reading);
    final jsonList = readings.map((r) => r.toJson()).toList();
    await _prefs!.setString(_bibleReadingsKey, jsonEncode(jsonList));
    
    // Award XP for Bible reading
    await GamificationService.awardXPForAction(GameAction.bibleReading);
  }

  static Future<List<BibleReading>> getBibleReadings() async {
    final jsonString = _prefs!.getString(_bibleReadingsKey) ?? '[]';
    final jsonList = jsonDecode(jsonString) as List;
    return jsonList.map((json) => BibleReading.fromJson(json)).toList();
  }

  static Future<void> updateBibleReading(BibleReading reading) async {
    final readings = await getBibleReadings();
    final index = readings.indexWhere((r) => r.id == reading.id);
    if (index != -1) {
      readings[index] = reading;
      final jsonList = readings.map((r) => r.toJson()).toList();
      await _prefs!.setString(_bibleReadingsKey, jsonEncode(jsonList));
    }
  }

  static Future<void> deleteBibleReading(String id) async {
    final readings = await getBibleReadings();
    readings.removeWhere((r) => r.id == id);
    final jsonList = readings.map((r) => r.toJson()).toList();
    await _prefs!.setString(_bibleReadingsKey, jsonEncode(jsonList));
  }

  // Cloud Sync Helpers (No re-queuing)
  static Future<void> syncBibleReadings(List<BibleReading> readings) async {
    final jsonList = readings.map((r) => r.toJson()).toList();
    await _prefs!.setString(_bibleReadingsKey, jsonEncode(jsonList));
  }

  // Prayer Schedules
  static Future<void> savePrayerSchedule(PrayerSchedule schedule) async {
    final schedules = await getPrayerSchedules();
    // Check if schedule with this ID already exists
    final existingIndex = schedules.indexWhere((s) => s.id == schedule.id);
    if (existingIndex != -1) {
      // Update existing schedule
      schedules[existingIndex] = schedule;
    } else {
      // Add new schedule
      schedules.add(schedule);
    }
    final jsonList = schedules.map((s) => s.toJson()).toList();
    await _prefs!.setString(_prayerSchedulesKey, jsonEncode(jsonList));
    await OfflineVerseDatabase().addToSyncQueue('prayer_schedule', schedule.id, 'upsert', schedule.toJson());
  }

  static Future<List<PrayerSchedule>> getPrayerSchedules() async {
    final jsonString = _prefs!.getString(_prayerSchedulesKey) ?? '[]';
    final jsonList = jsonDecode(jsonString) as List;
    return jsonList.map((json) => PrayerSchedule.fromJson(json)).toList();
  }

  static Future<void> updatePrayerSchedule(PrayerSchedule schedule) async {
    final schedules = await getPrayerSchedules();
    final index = schedules.indexWhere((s) => s.id == schedule.id);
    if (index != -1) {
      schedules[index] = schedule;
      final jsonList = schedules.map((s) => s.toJson()).toList();
      await _prefs!.setString(_prayerSchedulesKey, jsonEncode(jsonList));
      
      // Queue for sync
      await OfflineVerseDatabase().addToSyncQueue(
        'prayer_schedule',
        schedule.id,
        'upsert',
        schedule.toJson(),
      );
    }
  }

  static Future<void> deletePrayerSchedule(String id) async {
    final schedules = await getPrayerSchedules();
    schedules.removeWhere((s) => s.id == id);
    final jsonList = schedules.map((s) => s.toJson()).toList();
    await _prefs!.setString(_prayerSchedulesKey, jsonEncode(jsonList));
  }

  static Future<void> syncPrayerSchedules(List<PrayerSchedule> schedules) async {
    final jsonList = schedules.map((s) => s.toJson()).toList();
    await _prefs!.setString(_prayerSchedulesKey, jsonEncode(jsonList));
  }

  // Prayer Sessions
  static Future<void> savePrayerSession(PrayerSession session) async {
    final sessions = await getPrayerSessions();
    sessions.add(session);
    final jsonList = sessions.map((s) => s.toJson()).toList();
    await _prefs!.setString(_prayerSessionsKey, jsonEncode(jsonList));
    
    // Queue for sync
    await OfflineVerseDatabase().addToSyncQueue(
      'prayer_session',
      session.id,
      'insert',
      session.toJson(),
    );
  }

  static Future<List<PrayerSession>> getPrayerSessions() async {
    final jsonString = _prefs!.getString(_prayerSessionsKey) ?? '[]';
    final jsonList = jsonDecode(jsonString) as List;
    return jsonList.map((json) => PrayerSession.fromJson(json)).toList();
  }

  // Message Sessions
  static Future<void> saveMessageSession(MessageSession session) async {
    final sessions = await getMessageSessions();
    final existingIndex = sessions.indexWhere((s) => s.id == session.id);
    if (existingIndex != -1) {
      sessions[existingIndex] = session;
    } else {
      sessions.add(session);
    }
    final jsonList = sessions.map((s) => s.toJson()).toList();
    await _prefs!.setString(_messageSessionsKey, jsonEncode(jsonList));
    await OfflineVerseDatabase().addToSyncQueue('message_session', session.id, 'upsert', session.toJson());
  }

  static Future<List<MessageSession>> getMessageSessions() async {
    final jsonString = _prefs!.getString(_messageSessionsKey) ?? '[]';
    final jsonList = jsonDecode(jsonString) as List;
    return jsonList.map((json) => MessageSession.fromJson(json)).toList();
  }

  static Future<void> updateMessageSession(MessageSession session) async {
    final sessions = await getMessageSessions();
    final index = sessions.indexWhere((s) => s.id == session.id);
    if (index != -1) {
      sessions[index] = session;
      final jsonList = sessions.map((s) => s.toJson()).toList();
      await _prefs!.setString(_messageSessionsKey, jsonEncode(jsonList));
      
      // Queue for sync
      await OfflineVerseDatabase().addToSyncQueue(
        'message_session',
        session.id,
        'upsert',
        session.toJson(),
      );
    }
  }

  static Future<void> deleteMessageSession(String id) async {
    final sessions = await getMessageSessions();
    sessions.removeWhere((s) => s.id == id);
    final jsonList = sessions.map((s) => s.toJson()).toList();
    await _prefs!.setString(_messageSessionsKey, jsonEncode(jsonList));
  }

  static Future<void> syncMessageSessions(List<MessageSession> sessions) async {
    final jsonList = sessions.map((s) => s.toJson()).toList();
    await _prefs!.setString(_messageSessionsKey, jsonEncode(jsonList));
  }

  // Book Readings
  static Future<void> saveBookReading(BookReading book) async {
    final books = await getBookReadings();
    final existingIndex = books.indexWhere((b) => b.id == book.id);
    if (existingIndex != -1) {
      books[existingIndex] = book;
    } else {
      books.add(book);
    }
    final jsonList = books.map((b) => b.toJson()).toList();
    await _prefs!.setString(_bookReadingsKey, jsonEncode(jsonList));
    await OfflineVerseDatabase().addToSyncQueue('book_reading', book.id, 'upsert', book.toJson());
  }

  static Future<List<BookReading>> getBookReadings() async {
    final jsonString = _prefs!.getString(_bookReadingsKey) ?? '[]';
    final jsonList = jsonDecode(jsonString) as List;
    return jsonList.map((json) => BookReading.fromJson(json)).toList();
  }

  static Future<void> updateBookReading(BookReading book) async {
    final books = await getBookReadings();
    final index = books.indexWhere((b) => b.id == book.id);
    if (index != -1) {
      books[index] = book;
      final jsonList = books.map((b) => b.toJson()).toList();
      await _prefs!.setString(_bookReadingsKey, jsonEncode(jsonList));
      
      // Queue for sync
      await OfflineVerseDatabase().addToSyncQueue(
        'book_reading',
        book.id,
        'upsert',
        book.toJson(),
      );
    }
  }

  static Future<void> deleteBookReading(String id) async {
    final books = await getBookReadings();
    books.removeWhere((b) => b.id == id);
    final jsonList = books.map((b) => b.toJson()).toList();
    await _prefs!.setString(_bookReadingsKey, jsonEncode(jsonList));
  }

  static Future<void> syncBookReadings(List<BookReading> books) async {
    final jsonList = books.map((b) => b.toJson()).toList();
    await _prefs!.setString(_bookReadingsKey, jsonEncode(jsonList));
  }

  // Spiritual Goals
  static Future<void> saveSpiritualGoal(SpiritualGoal goal) async {
    final goals = await getSpiritualGoals();
    final existingIndex = goals.indexWhere((g) => g.id == goal.id);
    if (existingIndex != -1) {
      goals[existingIndex] = goal;
    } else {
      goals.add(goal);
    }
    final jsonList = goals.map((g) => g.toJson()).toList();
    await _prefs!.setString(_spiritualGoalsKey, jsonEncode(jsonList));
    await OfflineVerseDatabase().addToSyncQueue('spiritual_goal', goal.id, 'upsert', goal.toJson());
  }

  static Future<List<SpiritualGoal>> getSpiritualGoals() async {
    final jsonString = _prefs!.getString(_spiritualGoalsKey) ?? '[]';
    final jsonList = jsonDecode(jsonString) as List;
    return jsonList.map((json) => SpiritualGoal.fromJson(json)).toList();
  }

  static Future<void> updateSpiritualGoal(SpiritualGoal goal) async {
    final goals = await getSpiritualGoals();
    final index = goals.indexWhere((g) => g.id == goal.id);
    if (index != -1) {
      goals[index] = goal;
      final jsonList = goals.map((g) => g.toJson()).toList();
      await _prefs!.setString(_spiritualGoalsKey, jsonEncode(jsonList));
      
      // Queue for sync
      await OfflineVerseDatabase().addToSyncQueue(
        'spiritual_goal',
        goal.id,
        'upsert',
        goal.toJson(),
      );
    }
  }

  static Future<void> deleteSpiritualGoal(String id) async {
    final goals = await getSpiritualGoals();
    goals.removeWhere((g) => g.id == id);
    final jsonList = goals.map((g) => g.toJson()).toList();
    await _prefs!.setString(_spiritualGoalsKey, jsonEncode(jsonList));
  }

  static Future<void> syncSpiritualGoals(List<SpiritualGoal> goals) async {
    final jsonList = goals.map((g) => g.toJson()).toList();
    await _prefs!.setString(_spiritualGoalsKey, jsonEncode(jsonList));
  }

  // Daily Verses
  static Future<void> saveDailyVerse(DailyVerse verse) async {
    final verses = await getDailyVerses();
    final existingIndex = verses.indexWhere((v) => v.id == verse.id);
    if (existingIndex != -1) {
      verses[existingIndex] = verse;
    } else {
      verses.add(verse);
    }
    final jsonList = verses.map((v) => v.toJson()).toList();
    await _prefs!.setString(_dailyVersesKey, jsonEncode(jsonList));
  }

  static Future<List<DailyVerse>> getDailyVerses() async {
    final jsonString = _prefs!.getString(_dailyVersesKey) ?? '[]';
    final jsonList = jsonDecode(jsonString) as List;
    return jsonList.map((json) => DailyVerse.fromJson(json)).toList();
  }

  static Future<DailyVerse?> getTodaysVerse() async {
    final verses = await getDailyVerses();
    final today = DateTime.now();
    return verses.cast<DailyVerse?>().firstWhere(
      (v) => v != null && 
             v.date.year == today.year &&
             v.date.month == today.month &&
             v.date.day == today.day,
      orElse: () => null,
    );
  }

  static Future<void> deleteDailyVerse(String id) async {
    final verses = await getDailyVerses();
    verses.removeWhere((v) => v.id == id);
    final jsonList = verses.map((v) => v.toJson()).toList();
    await _prefs!.setString(_dailyVersesKey, jsonEncode(jsonList));
  }
}
