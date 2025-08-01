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
  
  // Cache for frequently accessed data
  static List<BibleReading>? _bibleReadingsCache;
  static List<BookReading>? _bookReadingsCache;
  static List<SpiritualGoal>? _spiritualGoalsCache;
  static List<DailyVerse>? _dailyVersesCache;
  static bool _cacheInitialized = false;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    await _initializeCache();
  }

  static Future<void> _initializeCache() async {
    if (_cacheInitialized) return;
    
    try {
      // Initialize cache in background
      _bibleReadingsCache = await _loadBibleReadingsFromStorage();
      _bookReadingsCache = await _loadBookReadingsFromStorage();
      _spiritualGoalsCache = await _loadSpiritualGoalsFromStorage();
      _dailyVersesCache = await _loadDailyVersesFromStorage();
      _cacheInitialized = true;
    } catch (e) {
      // Initialize with empty lists if loading fails
      _bibleReadingsCache = [];
      _bookReadingsCache = [];
      _spiritualGoalsCache = [];
      _dailyVersesCache = [];
      _cacheInitialized = true;
    }
  }

  // Optimized Bible Readings methods
  static Future<void> saveBibleReading(BibleReading reading) async {
    await _ensureCacheInitialized();
    _bibleReadingsCache!.add(reading);
    await _saveBibleReadingsToStorage(_bibleReadingsCache!);
  }

  static Future<List<BibleReading>> getBibleReadings() async {
    await _ensureCacheInitialized();
    return _bibleReadingsCache ?? [];
  }

  static Future<void> updateBibleReading(BibleReading reading) async {
    await _ensureCacheInitialized();
    final index = _bibleReadingsCache!.indexWhere((r) => r.id == reading.id);
    if (index != -1) {
      _bibleReadingsCache![index] = reading;
      await _saveBibleReadingsToStorage(_bibleReadingsCache!);
    }
  }

  static Future<void> deleteBibleReading(String id) async {
    await _ensureCacheInitialized();
    _bibleReadingsCache!.removeWhere((r) => r.id == id);
    await _saveBibleReadingsToStorage(_bibleReadingsCache!);
  }

  // Optimized Book Readings methods
  static Future<void> saveBookReading(BookReading book) async {
    await _ensureCacheInitialized();
    final existingIndex = _bookReadingsCache!.indexWhere((b) => b.id == book.id);
    if (existingIndex != -1) {
      _bookReadingsCache![existingIndex] = book;
    } else {
      _bookReadingsCache!.add(book);
    }
    await _saveBookReadingsToStorage(_bookReadingsCache!);
  }

  static Future<List<BookReading>> getBookReadings() async {
    await _ensureCacheInitialized();
    return _bookReadingsCache ?? [];
  }

  // Optimized Spiritual Goals methods
  static Future<void> saveSpiritualGoal(SpiritualGoal goal) async {
    await _ensureCacheInitialized();
    final existingIndex = _spiritualGoalsCache!.indexWhere((g) => g.id == goal.id);
    if (existingIndex != -1) {
      _spiritualGoalsCache![existingIndex] = goal;
    } else {
      _spiritualGoalsCache!.add(goal);
    }
    await _saveSpiritualGoalsToStorage(_spiritualGoalsCache!);
  }

  static Future<List<SpiritualGoal>> getSpiritualGoals() async {
    await _ensureCacheInitialized();
    return _spiritualGoalsCache ?? [];
  }

  // Optimized Daily Verses methods
  static Future<void> saveDailyVerse(DailyVerse verse) async {
    await _ensureCacheInitialized();
    final existingIndex = _dailyVersesCache!.indexWhere((v) => v.id == verse.id);
    if (existingIndex != -1) {
      _dailyVersesCache![existingIndex] = verse;
    } else {
      _dailyVersesCache!.add(verse);
    }
    await _saveDailyVersesToStorage(_dailyVersesCache!);
  }

  static Future<List<DailyVerse>> getDailyVerses() async {
    await _ensureCacheInitialized();
    return _dailyVersesCache ?? [];
  }

  static Future<DailyVerse?> getTodaysVerse() async {
    await _ensureCacheInitialized();
    final today = DateTime.now();
    try {
      return _dailyVersesCache?.firstWhere(
        (v) => v.date.year == today.year &&
               v.date.month == today.month &&
               v.date.day == today.day,
      );
    } catch (e) {
      return null;
    }
  }

  // Helper methods for storage operations
  static Future<void> _ensureCacheInitialized() async {
    if (!_cacheInitialized) {
      await _initializeCache();
    }
  }

  static Future<List<BibleReading>> _loadBibleReadingsFromStorage() async {
    final jsonString = _prefs!.getString(_bibleReadingsKey) ?? '[]';
    final jsonList = jsonDecode(jsonString) as List;
    return jsonList.map((json) => BibleReading.fromJson(json)).toList();
  }

  static Future<void> _saveBibleReadingsToStorage(List<BibleReading> readings) async {
    final jsonList = readings.map((r) => r.toJson()).toList();
    await _prefs!.setString(_bibleReadingsKey, jsonEncode(jsonList));
  }

  static Future<List<BookReading>> _loadBookReadingsFromStorage() async {
    final jsonString = _prefs!.getString(_bookReadingsKey) ?? '[]';
    final jsonList = jsonDecode(jsonString) as List;
    return jsonList.map((json) => BookReading.fromJson(json)).toList();
  }

  static Future<void> _saveBookReadingsToStorage(List<BookReading> books) async {
    final jsonList = books.map((b) => b.toJson()).toList();
    await _prefs!.setString(_bookReadingsKey, jsonEncode(jsonList));
  }

  static Future<List<SpiritualGoal>> _loadSpiritualGoalsFromStorage() async {
    final jsonString = _prefs!.getString(_spiritualGoalsKey) ?? '[]';
    final jsonList = jsonDecode(jsonString) as List;
    return jsonList.map((json) => SpiritualGoal.fromJson(json)).toList();
  }

  static Future<void> _saveSpiritualGoalsToStorage(List<SpiritualGoal> goals) async {
    final jsonList = goals.map((g) => g.toJson()).toList();
    await _prefs!.setString(_spiritualGoalsKey, jsonEncode(jsonList));
  }

  static Future<List<DailyVerse>> _loadDailyVersesFromStorage() async {
    final jsonString = _prefs!.getString(_dailyVersesKey) ?? '[]';
    final jsonList = jsonDecode(jsonString) as List;
    return jsonList.map((json) => DailyVerse.fromJson(json)).toList();
  }

  static Future<void> _saveDailyVersesToStorage(List<DailyVerse> verses) async {
    final jsonList = verses.map((v) => v.toJson()).toList();
    await _prefs!.setString(_dailyVersesKey, jsonEncode(jsonList));
  }

  // Legacy methods for other data types (keeping for compatibility)
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

  // Cache management
  static void clearCache() {
    _bibleReadingsCache = null;
    _bookReadingsCache = null;
    _spiritualGoalsCache = null;
    _dailyVersesCache = null;
    _cacheInitialized = false;
  }
}