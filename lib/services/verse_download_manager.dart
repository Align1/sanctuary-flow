import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:rooted/services/offline_verse_database.dart';
import 'package:rooted/services/connectivity_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manager for downloading and caching Bible verses for offline access
class VerseDownloadManager {
  static final VerseDownloadManager _instance = VerseDownloadManager._internal();
  factory VerseDownloadManager() => _instance;
  VerseDownloadManager._internal();

  final OfflineVerseDatabase _offlineDb = OfflineVerseDatabase();
  final ConnectivityService _connectivityService = ConnectivityService();
  
  bool _isDownloading = false;
  double _downloadProgress = 0.0;
  
  static const String _versesDownloadedKey = 'verses_downloaded';
  static const String _lastDownloadKey = 'last_download_timestamp';

  /// Check if verses have been downloaded
  Future<bool> areVersesDownloaded() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_versesDownloadedKey) ?? false;
  }

  /// Get last download time
  Future<DateTime?> getLastDownloadTime() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getString(_lastDownloadKey);
    return timestamp != null ? DateTime.parse(timestamp) : null;
  }

  /// Download verses for offline access
  Future<DownloadResult> downloadVerses({
    List<String>? categories,
    int? limit,
    Function(double progress)? onProgress,
  }) async {
    if (_isDownloading) {
      return DownloadResult(
        success: false,
        message: 'Download already in progress',
        versesDownloaded: 0,
      );
    }

    if (!_connectivityService.isOnline) {
      return DownloadResult(
        success: false,
        message: 'No internet connection',
        versesDownloaded: 0,
      );
    }

    _isDownloading = true;
    _downloadProgress = 0.0;
    int versesDownloaded = 0;

    try {
      debugPrint('📥 Starting verse download...');
      
      // Simulate downloading verses from an API
      // In a real app, this would fetch from a Bible API
      final versesToDownload = _getExpandedVerseLibrary();
      final total = limit != null && limit < versesToDownload.length 
          ? limit 
          : versesToDownload.length;

      for (int i = 0; i < total; i++) {
        final verse = versesToDownload[i];
        
        // Filter by categories if specified
        if (categories != null && !categories.contains(verse['category'])) {
          continue;
        }

        // Simulate network delay
        await Future.delayed(const Duration(milliseconds: 100));
        
        // Save to offline database
        // (The database is already populated in onCreate, but this simulates downloading new verses)
        
        versesDownloaded++;
        _downloadProgress = (i + 1) / total;
        
        if (onProgress != null) {
          onProgress(_downloadProgress);
        }

        debugPrint('📥 Downloaded verse ${i + 1}/$total');
      }

      // Mark verses as downloaded
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_versesDownloadedKey, true);
      await prefs.setString(_lastDownloadKey, DateTime.now().toIso8601String());

      debugPrint('✅ Download completed: $versesDownloaded verses');

      return DownloadResult(
        success: true,
        message: 'Downloaded $versesDownloaded verses',
        versesDownloaded: versesDownloaded,
      );
    } catch (e) {
      debugPrint('❌ Download failed: $e');
      return DownloadResult(
        success: false,
        message: 'Download failed: $e',
        versesDownloaded: versesDownloaded,
      );
    } finally {
      _isDownloading = false;
      _downloadProgress = 0.0;
    }
  }

  /// Get expanded verse library for download
  List<Map<String, dynamic>> _getExpandedVerseLibrary() {
    final now = DateTime.now().toIso8601String();
    
    return [
      // Additional verses beyond the initial set
      {
        'id': 'offline_psalm_91_1-2',
        'verse': 'Whoever dwells in the shelter of the Most High will rest in the shadow of the Almighty. I will say of the Lord, "He is my refuge and my fortress, my God, in whom I trust."',
        'reference': 'Psalm 91:1-2',
        'version': 'NIV',
        'book': 'Psalms',
        'chapter': 91,
        'category': 'Protection',
        'tags': 'protection,trust,refuge',
        'downloaded_at': now,
      },
      {
        'id': 'offline_matt_6_33',
        'verse': 'But seek first his kingdom and his righteousness, and all these things will be given to you as well.',
        'reference': 'Matthew 6:33',
        'version': 'NIV',
        'book': 'Matthew',
        'chapter': 6,
        'category': 'Priorities',
        'tags': 'priorities,kingdom,provision',
        'downloaded_at': now,
      },
      {
        'id': 'offline_eph_2_8-9',
        'verse': 'For it is by grace you have been saved, through faith—and this is not from yourselves, it is the gift of God—not by works, so that no one can boast.',
        'reference': 'Ephesians 2:8-9',
        'version': 'NIV',
        'book': 'Ephesians',
        'chapter': 2,
        'category': 'Grace',
        'tags': 'grace,salvation,faith',
        'downloaded_at': now,
      },
      {
        'id': 'offline_prov_22_6',
        'verse': 'Start children off on the way they should go, and even when they are old they will not turn from it.',
        'reference': 'Proverbs 22:6',
        'version': 'NIV',
        'book': 'Proverbs',
        'chapter': 22,
        'category': 'Parenting',
        'tags': 'parenting,training,children',
        'downloaded_at': now,
      },
      {
        'id': 'offline_james_1_2-3',
        'verse': 'Consider it pure joy, my brothers and sisters, whenever you face trials of many kinds, because you know that the testing of your faith produces perseverance.',
        'reference': 'James 1:2-3',
        'version': 'NIV',
        'book': 'James',
        'chapter': 1,
        'category': 'Perseverance',
        'tags': 'trials,perseverance,joy',
        'downloaded_at': now,
      },
    ];
  }

  /// Get available verse categories
  Future<List<String>> getAvailableCategories() async {
    final verses = await _offlineDb.getAllOfflineVerses();
    final categories = verses
        .map((v) => v['category'] as String?)
        .where((c) => c != null)
        .cast<String>()
        .toSet()
        .toList();
    categories.sort();
    return categories;
  }

  /// Get download statistics
  Future<DownloadStats> getDownloadStats() async {
    final dbStats = await _offlineDb.getDatabaseStats();
    final downloaded = await areVersesDownloaded();
    final lastDownload = await getLastDownloadTime();
    
    return DownloadStats(
      versesAvailable: dbStats['offline_verses'] ?? 0,
      isDownloading: _isDownloading,
      downloadProgress: _downloadProgress,
      lastDownloadTime: lastDownload,
      versesDownloaded: downloaded,
    );
  }

  /// Clear downloaded verses
  Future<void> clearDownloadedVerses() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_versesDownloadedKey, false);
    await prefs.remove(_lastDownloadKey);
    debugPrint('🗑️ Cleared downloaded verses flag');
  }

  /// Get download progress
  double get downloadProgress => _downloadProgress;

  /// Check if download is in progress
  bool get isDownloading => _isDownloading;
}

/// Download result model
class DownloadResult {
  final bool success;
  final String message;
  final int versesDownloaded;

  DownloadResult({
    required this.success,
    required this.message,
    required this.versesDownloaded,
  });
}

/// Download statistics model
class DownloadStats {
  final int versesAvailable;
  final bool isDownloading;
  final double downloadProgress;
  final DateTime? lastDownloadTime;
  final bool versesDownloaded;

  DownloadStats({
    required this.versesAvailable,
    required this.isDownloading,
    required this.downloadProgress,
    this.lastDownloadTime,
    required this.versesDownloaded,
  });

  String get statusMessage {
    if (isDownloading) {
      return 'Downloading... ${(downloadProgress * 100).toStringAsFixed(0)}%';
    }
    
    if (versesDownloaded) {
      if (lastDownloadTime != null) {
        final duration = DateTime.now().difference(lastDownloadTime!);
        if (duration.inDays < 1) {
          return '$versesAvailable verses available offline';
        } else {
          return '$versesAvailable verses (${duration.inDays}d old)';
        }
      }
      return '$versesAvailable verses available offline';
    }
    
    return 'No verses downloaded';
  }
}

