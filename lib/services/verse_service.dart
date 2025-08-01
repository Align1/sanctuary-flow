import 'dart:math';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:sanctuaryflow/models/daily_verse.dart';
import 'package:sanctuaryflow/services/local_storage_service.dart';

class VerseService {
  // Reduced sample verses for faster loading
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
      'verse': 'But those who hope in the Lord will renew their strength. They will soar on wings like eagles; they will run and not grow weary, they will walk and not be faint.',
      'reference': 'Isaiah 40:31',
      'version': 'NIV'
    }
  ];

  static List<Map<String, String>> _loadedVerses = [];
  static bool _versesLoaded = false;
  static bool _loadingInProgress = false;
  static DailyVerse? _cachedTodaysVerse;

  // Lazy loading with caching
  static Future<void> loadVersesFromAssets() async {
    if (_versesLoaded || _loadingInProgress) return;
    
    _loadingInProgress = true;
    try {
      final String jsonString = await rootBundle.loadString('assets/verses_optimized.json');
      final List<dynamic> jsonList = json.decode(jsonString);
      _loadedVerses = jsonList.map<Map<String, String>>((item) => {
        'verse': item['verse'] as String,
        'reference': item['reference'] as String,
        'version': item['version'] as String,
      }).toList();
      _versesLoaded = true;
    } catch (e) {
      // Fallback to sample verses if asset loading fails
      _loadedVerses = [];
      _versesLoaded = true;
    } finally {
      _loadingInProgress = false;
    }
  }

  static Future<List<Map<String, String>>> getVerseList() async {
    await loadVersesFromAssets();
    return _loadedVerses.isNotEmpty ? _loadedVerses : _sampleVerses;
  }

  static Future<DailyVerse> getTodaysVerse() async {
    // Check cache first
    if (_cachedTodaysVerse != null) {
      final today = DateTime.now();
      if (_cachedTodaysVerse!.date.year == today.year &&
          _cachedTodaysVerse!.date.month == today.month &&
          _cachedTodaysVerse!.date.day == today.day) {
        return _cachedTodaysVerse!;
      }
    }

    // Check if we already have today's verse in storage
    final existingVerse = await LocalStorageService.getTodaysVerse();
    if (existingVerse != null) {
      _cachedTodaysVerse = existingVerse;
      return existingVerse;
    }

    // Generate new verse for today
    final today = DateTime.now();
    final verseList = await getVerseList();
    final random = Random(today.day + today.month * 31 + today.year * 365);
    final selectedVerse = verseList[random.nextInt(verseList.length)];

    final todaysVerse = DailyVerse(
      id: 'verse_${today.year}_${today.month}_${today.day}',
      date: today,
      verse: selectedVerse['verse']!,
      reference: selectedVerse['reference']!,
      version: selectedVerse['version']!,
      reflection: '',
      isFavorite: false,
    );

    // Save to storage and cache
    await LocalStorageService.saveDailyVerse(todaysVerse);
    _cachedTodaysVerse = todaysVerse;
    
    return todaysVerse;
  }

  // Optimized method to get a random verse without loading the full asset
  static Future<Map<String, String>> getRandomVerse() async {
    final verseList = await getVerseList();
    final random = Random();
    return verseList[random.nextInt(verseList.length)];
  }

  // Clear cache when needed
  static void clearCache() {
    _cachedTodaysVerse = null;
  }

  // Preload verses in background (call this during app initialization)
  static Future<void> preloadVerses() async {
    // Load verses in background without blocking UI
    loadVersesFromAssets();
  }
}