import 'dart:math';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:rooted/models/daily_verse.dart';
import 'package:rooted/services/local_storage_service.dart';
import 'package:rooted/services/home_widget_service.dart';
import 'package:rooted/services/offline_verse_database.dart';
import 'package:rooted/services/connectivity_service.dart';
import 'package:rooted/services/gamification_service.dart';
import 'package:rooted/services/supabase_service.dart';
import 'package:rooted/utils/error_handler.dart';

class VerseService {
  static final OfflineVerseDatabase _offlineDb = OfflineVerseDatabase();
  static final ConnectivityService _connectivityService = ConnectivityService();
  
  static final List<Map<String, String>> _sampleVerses = [
    {
      'verse': 'Trust in the Lord with all your heart and lean not on your own understanding; in all your ways submit to him, and he will make your paths straight.',
      'reference': 'Proverbs 3:5-6',
      'version': 'NIV'
    },
    {
      'verse': 'For I know the plans I have for you, declares the Lord, plans to prosper you and not to harm you, to give you hope and a future.',
      'reference': 'Jeremiah 29:11',
      'version': 'NIV'
    },
    {
      'verse': 'Be strong and courageous. Do not be afraid; do not be discouraged, for the Lord your God will be with you wherever you go.',
      'reference': 'Joshua 1:9',
      'version': 'NIV'
    },
    {
      'verse': 'The Lord is my shepherd, I lack nothing. He makes me lie down in green pastures, he leads me beside quiet waters, he refreshes my soul.',
      'reference': 'Psalm 23:1-3',
      'version': 'NIV'
    },
    {
      'verse': 'Cast all your anxiety on him because he cares for you.',
      'reference': '1 Peter 5:7',
      'version': 'NIV'
    },
    {
      'verse': 'And we know that in all things God works for the good of those who love him, who have been called according to his purpose.',
      'reference': 'Romans 8:28',
      'version': 'NIV'
    },
    {
      'verse': 'I can do all this through him who gives me strength.',
      'reference': 'Philippians 4:13',
      'version': 'NIV'
    },
    {
      'verse': 'The Lord your God is with you, the Mighty Warrior who saves. He will take great delight in you; in his love he will no longer rebuke you, but will rejoice over you with singing.',
      'reference': 'Zephaniah 3:17',
      'version': 'NIV'
    },
    {
      'verse': 'Have I not commanded you? Be strong and courageous. Do not be afraid; do not be discouraged, for the Lord your God will be with you wherever you go.',
      'reference': 'Joshua 1:9',
      'version': 'NIV'
    },
    {
      'verse': 'But those who hope in the Lord will renew their strength. They will soar on wings like eagles; they will run and not grow weary, they will walk and not be faint.',
      'reference': 'Isaiah 40:31',
      'version': 'NIV'
    }
  ];

  static Future<DailyVerse> getTodaysVerse() async {
    try {
      // Check if we already have today's verse (offline-first)
      final existingVerse = await LocalStorageService.getTodaysVerse();
      if (existingVerse != null) {
        return existingVerse;
      }

      // Generate new verse for today
      final today = DateTime.now();
      final todaysVerse = await _generateDailyVerse(today);

      // Save it for future reference  (works offline)
      await LocalStorageService.saveDailyVerse(todaysVerse);
      
      // Also save to offline database for better persistence and sync tracking
      try {
        await _offlineDb.saveUserVerse(
          todaysVerse,
          synced: _connectivityService.isOnline,
        );
      } catch (e) {
        ErrorHandler.logError('SaveUserVerse', e);
        // Continue even if offline DB save fails
      }
      
      // Update home screen widgets (mobile only)
      if (!kIsWeb) {
        try {
          await HomeWidgetService.updateDailyVerseWidget();
        } catch (e) {
          ErrorHandler.logError('UpdateHomeWidget', e);
          // Continue even if widget update fails
        }
      }
      
      return todaysVerse;
    } catch (e) {
      ErrorHandler.logError('GetTodaysVerse', e);
      // Return a fallback verse if everything fails
      return _generateFallbackVerse();
    }
  }

  /// Generate fallback verse when all else fails
  static DailyVerse _generateFallbackVerse() {
    final today = DateTime.now();
    return DailyVerse(
      id: 'verse_${today.year}_${today.month}_${today.day}',
      verse: 'Trust in the Lord with all your heart and lean not on your own understanding.',
      reference: 'Proverbs 3:5',
      version: 'NIV',
      date: today,
    );
  }

  /// Generate daily verse using Supabase, offline database, or fallback to hardcoded verses
  static Future<DailyVerse> _generateDailyVerse(DateTime date) async {
    // Calculate day of year (1-366)
    final dayOfYear = date.difference(DateTime(date.year, 1, 1)).inDays + 1;
    
    // 1. Try to fetch from Supabase (Cloud First)
    try {
      final supabase = SupabaseService();
      final cloudVerse = await supabase.getDailyVerse(dayOfYear);
      
      if (cloudVerse != null) {
        return DailyVerse(
          id: 'verse_${date.year}_${date.month}_${date.day}',
          verse: cloudVerse['verse'] as String,
          reference: cloudVerse['reference'] as String,
          version: cloudVerse['version'] ?? 'NIV',
          date: date,
        );
      }
    } catch (e) {
      ErrorHandler.logError('SupabaseFetchVerse', e);
    }

    // 2. Try to get from offline database (Mobile fallback)
    if (!kIsWeb) {
      try {
        final offlineVerse = await _offlineDb.getRandomOfflineVerse();
        
        if (offlineVerse != null) {
          return DailyVerse(
            id: 'verse_${date.year}_${date.month}_${date.day}',
            verse: offlineVerse['verse'] as String,
            reference: offlineVerse['reference'] as String,
            version: offlineVerse['version'] as String,
            date: date,
          );
        }
      } catch (e) {
        ErrorHandler.logError('OfflineDbFetchVerse', e);
      }
    }

    // 3. Fallback to hardcoded verses (Final fallback)
    final random = Random(date.day + date.month * 31 + date.year * 365);
    final selectedVerse = _sampleVerses[random.nextInt(_sampleVerses.length)];

    return DailyVerse(
      id: 'verse_${date.year}_${date.month}_${date.day}',
      verse: selectedVerse['verse']!,
      reference: selectedVerse['reference']!,
      version: selectedVerse['version']!,
      date: date,
    );
  }

  static Future<List<DailyVerse>> getFavoriteVerses() async {
    final allVerses = await LocalStorageService.getDailyVerses();
    return allVerses.where((verse) => verse.isFavorite).toList();
  }

  static Future<void> toggleFavorite(String verseId) async {
    final verses = await LocalStorageService.getDailyVerses();
    final verseIndex = verses.indexWhere((v) => v.id == verseId);
    
    if (verseIndex != -1) {
      final updatedVerse = DailyVerse(
        id: verses[verseIndex].id,
        verse: verses[verseIndex].verse,
        reference: verses[verseIndex].reference,
        version: verses[verseIndex].version,
        date: verses[verseIndex].date,
        reflection: verses[verseIndex].reflection,
        isFavorite: !verses[verseIndex].isFavorite,
        tags: verses[verseIndex].tags,
      );
      
      // Save to local storage (offline-first)
      await LocalStorageService.saveDailyVerse(updatedVerse);
      
      // Save to offline database with sync tracking (mobile only)
      await _offlineDb.saveUserVerse(
        updatedVerse,
        synced: _connectivityService.isOnline,
      );
      
      // Update home screen widgets (mobile only)
      if (!kIsWeb) {
        await HomeWidgetService.updateDailyVerseWidget();
      }
    }
  }

  static Future<void> addReflection(String verseId, String reflection) async {
    final verses = await LocalStorageService.getDailyVerses();
    final verseIndex = verses.indexWhere((v) => v.id == verseId);
    
    if (verseIndex != -1) {
      final updatedVerse = DailyVerse(
        id: verses[verseIndex].id,
        verse: verses[verseIndex].verse,
        reference: verses[verseIndex].reference,
        version: verses[verseIndex].version,
        date: verses[verseIndex].date,
        reflection: reflection,
        isFavorite: verses[verseIndex].isFavorite,
        tags: verses[verseIndex].tags,
      );
      
      // Save to local storage (offline-first)
      await LocalStorageService.saveDailyVerse(updatedVerse);
      
      // Save to offline database with sync tracking (mobile only)
      await _offlineDb.saveUserVerse(
        updatedVerse,
        synced: _connectivityService.isOnline,
      );
      
      // Update home screen widgets (mobile only)
      if (!kIsWeb) {
        await HomeWidgetService.updateDailyVerseWidget();
      }
      
      // Award XP for adding reflection
      await GamificationService.awardXPForAction(GameAction.addReflection);
    }
  }

  /// Get verses by category from offline database (mobile only)
  static Future<List<Map<String, dynamic>>> getVersesByCategory(String category) async {
    if (kIsWeb) return [];
    return await _offlineDb.getVersesByCategory(category);
  }

  /// Get all offline verses (mobile only)
  static Future<List<Map<String, dynamic>>> getAllOfflineVerses() async {
    if (kIsWeb) return [];
    return await _offlineDb.getAllOfflineVerses();
  }
}
