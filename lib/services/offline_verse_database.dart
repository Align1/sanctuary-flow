import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:rooted/models/daily_verse.dart';

/// Offline-first verse database for storing Bible verses locally
/// Note: Only works on mobile platforms (Android/iOS), not on web
class OfflineVerseDatabase {
  static final OfflineVerseDatabase _instance = OfflineVerseDatabase._internal();
  factory OfflineVerseDatabase() => _instance;
  OfflineVerseDatabase._internal();

  Database? _database;
  bool _isInitialized = false;

  /// Get database instance (returns null on web)
  Future<Database?> get database async {
    if (kIsWeb) {
      return null; // SQLite not supported on web
    }
    
    if (_database != null) return _database!;
    
    if (!_isInitialized) {
      _database = await _initDatabase();
      _isInitialized = true;
    }
    
    return _database;
  }

  /// Initialize the database (mobile only)
  Future<Database> _initDatabase() async {
    if (kIsWeb) {
      throw UnsupportedError('SQLite is not supported on web platform');
    }
    
    final databasePath = await getDatabasesPath();
    final path = '$databasePath/sanctuary_verses.db';

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  /// Create database tables
  Future<void> _onCreate(Database db, int version) async {
    // Verses table - offline verse library
    await db.execute('''
      CREATE TABLE verses (
        id TEXT PRIMARY KEY,
        verse TEXT NOT NULL,
        reference TEXT NOT NULL,
        version TEXT NOT NULL,
        book TEXT NOT NULL,
        chapter INTEGER NOT NULL,
        category TEXT,
        tags TEXT,
        downloaded_at TEXT NOT NULL
      )
    ''');

    // User verses table - for user's daily verses, reflections, favorites
    await db.execute('''
      CREATE TABLE user_verses (
        id TEXT PRIMARY KEY,
        verse TEXT NOT NULL,
        reference TEXT NOT NULL,
        version TEXT NOT NULL,
        date TEXT NOT NULL,
        reflection TEXT,
        is_favorite INTEGER DEFAULT 0,
        tags TEXT,
        synced INTEGER DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Sync queue table - for tracking pending syncs
    await db.execute('''
      CREATE TABLE sync_queue (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        entity_type TEXT NOT NULL,
        entity_id TEXT NOT NULL,
        action TEXT NOT NULL,
        data TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // Populate initial offline verse library
    await _populateInitialVerses(db);
  }

  /// Populate database with initial offline verses
  Future<void> _populateInitialVerses(Database db) async {
    final now = DateTime.now().toIso8601String();
    
    final verses = [
      {
        'id': 'offline_prov_3_5-6',
        'verse': 'Trust in the Lord with all your heart and lean not on your own understanding; in all your ways submit to him, and he will make your paths straight.',
        'reference': 'Proverbs 3:5-6',
        'version': 'NIV',
        'book': 'Proverbs',
        'chapter': 3,
        'category': 'Trust',
        'tags': 'faith,guidance,trust',
        'downloaded_at': now,
      },
      {
        'id': 'offline_jer_29_11',
        'verse': 'For I know the plans I have for you, declares the Lord, plans to prosper you and not to harm you, to give you hope and a future.',
        'reference': 'Jeremiah 29:11',
        'version': 'NIV',
        'book': 'Jeremiah',
        'chapter': 29,
        'category': 'Hope',
        'tags': 'hope,future,plans',
        'downloaded_at': now,
      },
      {
        'id': 'offline_josh_1_9',
        'verse': 'Be strong and courageous. Do not be afraid; do not be discouraged, for the Lord your God will be with you wherever you go.',
        'reference': 'Joshua 1:9',
        'version': 'NIV',
        'book': 'Joshua',
        'chapter': 1,
        'category': 'Courage',
        'tags': 'courage,strength,fear',
        'downloaded_at': now,
      },
      {
        'id': 'offline_psalm_23_1-3',
        'verse': 'The Lord is my shepherd, I lack nothing. He makes me lie down in green pastures, he leads me beside quiet waters, he refreshes my soul.',
        'reference': 'Psalm 23:1-3',
        'version': 'NIV',
        'book': 'Psalms',
        'chapter': 23,
        'category': 'Peace',
        'tags': 'peace,comfort,shepherd',
        'downloaded_at': now,
      },
      {
        'id': 'offline_1pet_5_7',
        'verse': 'Cast all your anxiety on him because he cares for you.',
        'reference': '1 Peter 5:7',
        'version': 'NIV',
        'book': '1 Peter',
        'chapter': 5,
        'category': 'Peace',
        'tags': 'anxiety,worry,care',
        'downloaded_at': now,
      },
      {
        'id': 'offline_rom_8_28',
        'verse': 'And we know that in all things God works for the good of those who love him, who have been called according to his purpose.',
        'reference': 'Romans 8:28',
        'version': 'NIV',
        'book': 'Romans',
        'chapter': 8,
        'category': 'Faith',
        'tags': 'faith,purpose,good',
        'downloaded_at': now,
      },
      {
        'id': 'offline_phil_4_13',
        'verse': 'I can do all this through him who gives me strength.',
        'reference': 'Philippians 4:13',
        'version': 'NIV',
        'book': 'Philippians',
        'chapter': 4,
        'category': 'Strength',
        'tags': 'strength,power,ability',
        'downloaded_at': now,
      },
      {
        'id': 'offline_zeph_3_17',
        'verse': 'The Lord your God is with you, the Mighty Warrior who saves. He will take great delight in you; in his love he will no longer rebuke you, but will rejoice over you with singing.',
        'reference': 'Zephaniah 3:17',
        'version': 'NIV',
        'book': 'Zephaniah',
        'chapter': 3,
        'category': 'Love',
        'tags': 'love,joy,delight',
        'downloaded_at': now,
      },
      {
        'id': 'offline_isa_40_31',
        'verse': 'But those who hope in the Lord will renew their strength. They will soar on wings like eagles; they will run and not grow weary, they will walk and not be faint.',
        'reference': 'Isaiah 40:31',
        'version': 'NIV',
        'book': 'Isaiah',
        'chapter': 40,
        'category': 'Strength',
        'tags': 'strength,hope,renewal',
        'downloaded_at': now,
      },
      {
        'id': 'offline_matt_11_28',
        'verse': 'Come to me, all you who are weary and burdened, and I will give you rest.',
        'reference': 'Matthew 11:28',
        'version': 'NIV',
        'book': 'Matthew',
        'chapter': 11,
        'category': 'Rest',
        'tags': 'rest,peace,burden',
        'downloaded_at': now,
      },
      {
        'id': 'offline_john_3_16',
        'verse': 'For God so loved the world that he gave his one and only Son, that whoever believes in him shall not perish but have eternal life.',
        'reference': 'John 3:16',
        'version': 'NIV',
        'book': 'John',
        'chapter': 3,
        'category': 'Love',
        'tags': 'love,salvation,eternal-life',
        'downloaded_at': now,
      },
      {
        'id': 'offline_psalm_46_1',
        'verse': 'God is our refuge and strength, an ever-present help in trouble.',
        'reference': 'Psalm 46:1',
        'version': 'NIV',
        'book': 'Psalms',
        'chapter': 46,
        'category': 'Strength',
        'tags': 'refuge,strength,help',
        'downloaded_at': now,
      },
      {
        'id': 'offline_2cor_12_9',
        'verse': 'But he said to me, "My grace is sufficient for you, for my power is made perfect in weakness." Therefore I will boast all the more gladly about my weaknesses, so that Christ\'s power may rest on me.',
        'reference': '2 Corinthians 12:9',
        'version': 'NIV',
        'book': '2 Corinthians',
        'chapter': 12,
        'category': 'Grace',
        'tags': 'grace,weakness,power',
        'downloaded_at': now,
      },
      {
        'id': 'offline_psalm_103_2-3',
        'verse': 'Praise the Lord, my soul, and forget not all his benefits—who forgives all your sins and heals all your diseases.',
        'reference': 'Psalm 103:2-3',
        'version': 'NIV',
        'book': 'Psalms',
        'chapter': 103,
        'category': 'Healing',
        'tags': 'healing,forgiveness,praise',
        'downloaded_at': now,
      },
      {
        'id': 'offline_prov_16_3',
        'verse': 'Commit to the Lord whatever you do, and he will establish your plans.',
        'reference': 'Proverbs 16:3',
        'version': 'NIV',
        'book': 'Proverbs',
        'chapter': 16,
        'category': 'Guidance',
        'tags': 'plans,commitment,success',
        'downloaded_at': now,
      },
    ];

    final batch = db.batch();
    for (final verse in verses) {
      batch.insert('verses', verse);
    }
    await batch.commit(noResult: true);
  }

  /// Get all offline verses
  Future<List<Map<String, dynamic>>> getAllOfflineVerses() async {
    if (kIsWeb) return []; // Return empty list on web
    
    final db = await database;
    if (db == null) return [];
    
    return await db.query('verses', orderBy: 'reference');
  }

  /// Get random offline verse
  Future<Map<String, dynamic>?> getRandomOfflineVerse() async {
    if (kIsWeb) return null; // Not available on web
    
    final db = await database;
    if (db == null) return null;
    
    final verses = await db.query('verses', orderBy: 'RANDOM()', limit: 1);
    return verses.isNotEmpty ? verses.first : null;
  }

  /// Get verses by category
  Future<List<Map<String, dynamic>>> getVersesByCategory(String category) async {
    if (kIsWeb) return []; // Return empty list on web
    
    final db = await database;
    if (db == null) return [];
    
    return await db.query(
      'verses',
      where: 'category = ?',
      whereArgs: [category],
    );
  }

  /// Save user's daily verse
  Future<void> saveUserVerse(DailyVerse verse, {bool synced = false}) async {
    if (kIsWeb) return; // Not available on web
    
    final db = await database;
    if (db == null) return;
    
    final now = DateTime.now().toIso8601String();
    
    await db.insert(
      'user_verses',
      {
        'id': verse.id,
        'verse': verse.verse,
        'reference': verse.reference,
        'version': verse.version,
        'date': verse.date.toIso8601String(),
        'reflection': verse.reflection,
        'is_favorite': verse.isFavorite ? 1 : 0,
        'tags': verse.tags.join(','),
        'synced': synced ? 1 : 0,
        'created_at': now,
        'updated_at': now,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // Add to sync queue if not synced
    if (!synced) {
      await addToSyncQueue('user_verse', verse.id, 'upsert', verse.toJson());
    }
  }

  /// Get user's verses
  Future<List<DailyVerse>> getUserVerses() async {
    if (kIsWeb) return []; // Return empty list on web
    
    final db = await database;
    if (db == null) return [];
    
    final maps = await db.query('user_verses', orderBy: 'date DESC');
    
    return maps.map((map) => DailyVerse(
      id: map['id'] as String,
      verse: map['verse'] as String,
      reference: map['reference'] as String,
      version: map['version'] as String,
      date: DateTime.parse(map['date'] as String),
      reflection: map['reflection'] as String?,
      isFavorite: (map['is_favorite'] as int) == 1,
      tags: (map['tags'] as String).isEmpty 
          ? [] 
          : (map['tags'] as String).split(','),
    )).toList();
  }

  /// Add item to sync queue
  Future<void> addToSyncQueue(
    String entityType,
    String entityId,
    String action,
    Map<String, dynamic> data,
  ) async {
    final now = DateTime.now().toIso8601String();
    final jsonData = jsonEncode(data);

    if (kIsWeb) {
      // For web, use SharedPreferences to store the queue
      final prefs = await SharedPreferences.getInstance();
      final queueJson = prefs.getString('web_sync_queue') ?? '[]';
      final List<dynamic> queue = jsonDecode(queueJson);
      
      queue.add({
        'id': DateTime.now().millisecondsSinceEpoch,
        'entity_type': entityType,
        'entity_id': entityId,
        'action': action,
        'data': jsonData,
        'created_at': now,
      });
      
      await prefs.setString('web_sync_queue', jsonEncode(queue));
      return;
    }
    
    final db = await database;
    if (db == null) return;
    
    await db.insert('sync_queue', {
      'entity_type': entityType,
      'entity_id': entityId,
      'action': action,
      'data': jsonData,
      'created_at': now,
    });
  }

  /// Get pending sync items
  Future<List<Map<String, dynamic>>> getPendingSyncItems() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final queueJson = prefs.getString('web_sync_queue') ?? '[]';
      final List<dynamic> queue = jsonDecode(queueJson);
      return queue.cast<Map<String, dynamic>>();
    }
    
    final db = await database;
    if (db == null) return [];
    
    return await db.query('sync_queue', orderBy: 'created_at ASC');
  }

  /// Clear sync queue item
  Future<void> clearSyncItem(int id) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final queueJson = prefs.getString('web_sync_queue') ?? '[]';
      final List<dynamic> queue = jsonDecode(queueJson);
      
      queue.removeWhere((item) => item['id'] == id);
      
      await prefs.setString('web_sync_queue', jsonEncode(queue));
      return;
    }
    
    final db = await database;
    if (db == null) return;
    
    await db.delete('sync_queue', where: 'id = ?', whereArgs: [id]);
  }

  /// Mark verse as synced
  Future<void> markVerseAsSynced(String verseId) async {
    if (kIsWeb) return; // Not available on web
    
    final db = await database;
    if (db == null) return;
    
    await db.update(
      'user_verses',
      {'synced': 1, 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [verseId],
    );
  }

  /// Get database stats
  Future<Map<String, int>> getDatabaseStats() async {
    if (kIsWeb) {
      return {
        'offline_verses': 0,
        'user_verses': 0,
        'pending_sync': 0,
      };
    }
    
    final db = await database;
    if (db == null) {
      return {
        'offline_verses': 0,
        'user_verses': 0,
        'pending_sync': 0,
      };
    }
    
    final offlineVersesCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM verses')
    ) ?? 0;
    
    final userVersesCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM user_verses')
    ) ?? 0;
    
    final pendingSyncCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM sync_queue')
    ) ?? 0;

    return {
      'offline_verses': offlineVersesCount,
      'user_verses': userVersesCount,
      'pending_sync': pendingSyncCount,
    };
  }

  /// Close database
  Future<void> close() async {
    if (kIsWeb) return; // Not available on web
    
    final db = await database;
    if (db == null) return;
    
    await db.close();
    _database = null;
  }
}

