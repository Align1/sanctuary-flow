import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sanctuaryflow/models/bible_reading.dart';
import 'package:sanctuaryflow/models/prayer_schedule.dart';
import 'package:sanctuaryflow/models/message_session.dart';
import 'package:sanctuaryflow/models/book_reading.dart';
import 'package:sanctuaryflow/models/spiritual_goal.dart';
import 'package:sanctuaryflow/models/daily_verse.dart';

class LocalStorageService {
  static const String _bibleReadingsKey = 'bible_readings';
  static const String _prayerSchedulesKey = 'prayer_schedules';
  static const String _prayerSessionsKey = 'prayer_sessions';
  static const String _messageSessionsKey = 'message_sessions';
  static const String _bookReadingsKey = 'book_readings';
  static const String _spiritualGoalsKey = 'spiritual_goals';
  static const String _dailyVersesKey = 'daily_verses';

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

  // Prayer Schedules
  static Future<void> savePrayerSchedule(PrayerSchedule schedule) async {
    final schedules = await getPrayerSchedules();
    schedules.add(schedule);
    final jsonList = schedules.map((s) => s.toJson()).toList();
    await _prefs!.setString(_prayerSchedulesKey, jsonEncode(jsonList));
  }

  static Future<List<PrayerSchedule>> getPrayerSchedules() async {
    final jsonString = _prefs!.getString(_prayerSchedulesKey) ?? '[]';
    final jsonList = jsonDecode(jsonString) as List;
    return jsonList.map((json) => PrayerSchedule.fromJson(json)).toList();
  }

  // Prayer Sessions
  static Future<void> savePrayerSession(PrayerSession session) async {
    final sessions = await getPrayerSessions();
    sessions.add(session);
    final jsonList = sessions.map((s) => s.toJson()).toList();
    await _prefs!.setString(_prayerSessionsKey, jsonEncode(jsonList));
  }

  static Future<List<PrayerSession>> getPrayerSessions() async {
    final jsonString = _prefs!.getString(_prayerSessionsKey) ?? '[]';
    final jsonList = jsonDecode(jsonString) as List;
    return jsonList.map((json) => PrayerSession.fromJson(json)).toList();
  }

  // Message Sessions
  static Future<void> saveMessageSession(MessageSession session) async {
    final sessions = await getMessageSessions();
    sessions.add(session);
    final jsonList = sessions.map((s) => s.toJson()).toList();
    await _prefs!.setString(_messageSessionsKey, jsonEncode(jsonList));
  }

  static Future<List<MessageSession>> getMessageSessions() async {
    final jsonString = _prefs!.getString(_messageSessionsKey) ?? '[]';
    final jsonList = jsonDecode(jsonString) as List;
    return jsonList.map((json) => MessageSession.fromJson(json)).toList();
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
  }

  static Future<List<BookReading>> getBookReadings() async {
    final jsonString = _prefs!.getString(_bookReadingsKey) ?? '[]';
    final jsonList = jsonDecode(jsonString) as List;
    return jsonList.map((json) => BookReading.fromJson(json)).toList();
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
  }

  static Future<List<SpiritualGoal>> getSpiritualGoals() async {
    final jsonString = _prefs!.getString(_spiritualGoalsKey) ?? '[]';
    final jsonList = jsonDecode(jsonString) as List;
    return jsonList.map((json) => SpiritualGoal.fromJson(json)).toList();
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
}