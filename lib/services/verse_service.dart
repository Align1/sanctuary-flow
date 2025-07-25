import 'dart:math';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:sanctuaryflow/models/daily_verse.dart';
import 'package:sanctuaryflow/services/local_storage_service.dart';

class VerseService {
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

  static List<Map<String, String>> _loadedVerses = [];
  static bool _versesLoaded = false;

  static Future<void> loadVersesFromAssets() async {
    if (_versesLoaded) return;
    try {
      final String jsonString = await rootBundle.loadString('assets/verses.json');
      final List<dynamic> jsonList = json.decode(jsonString);
      _loadedVerses = jsonList.map<Map<String, String>>((item) => {
        'verse': item['verse'] as String,
        'reference': item['reference'] as String,
        'version': item['version'] as String,
      }).toList();
      _versesLoaded = true;
    } catch (e) {
      _loadedVerses = [];
      _versesLoaded = true;
    }
  }

  static Future<List<Map<String, String>>> getVerseList() async {
    await loadVersesFromAssets();
    return _loadedVerses.isNotEmpty ? _loadedVerses : _sampleVerses;
  }

  static Future<DailyVerse> getTodaysVerse() async {
    // Check if we already have today's verse
    final existingVerse = await LocalStorageService.getTodaysVerse();
    if (existingVerse != null) {
      return existingVerse;
    }

    // Generate new verse for today
    final today = DateTime.now();
    final verseList = await getVerseList();
    final random = Random(today.day + today.month * 31 + today.year * 365);
    final selectedVerse = verseList[random.nextInt(verseList.length)];

    final todaysVerse = DailyVerse(
      id: 'verse_${today.year}_${today.month}_${today.day}',
      verse: selectedVerse['verse']!,
      reference: selectedVerse['reference']!,
      version: selectedVerse['version']!,
      date: today,
    );

    // Save it for future reference
    await LocalStorageService.saveDailyVerse(todaysVerse);
    return todaysVerse;
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
      
      await LocalStorageService.saveDailyVerse(updatedVerse);
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
      
      await LocalStorageService.saveDailyVerse(updatedVerse);
    }
  }
}