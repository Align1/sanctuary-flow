import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:rooted/services/connectivity_service.dart';
import 'package:rooted/services/offline_verse_database.dart';
import 'package:rooted/utils/error_handler.dart';
import 'package:rooted/services/supabase_service.dart';
import 'package:rooted/services/local_storage_service.dart';
import 'package:rooted/services/achievement_service.dart';
import 'package:rooted/models/bible_reading.dart';
import 'package:rooted/models/prayer_schedule.dart';
import 'package:rooted/models/message_session.dart';
import 'package:rooted/models/book_reading.dart';
import 'package:rooted/models/spiritual_goal.dart';
import 'package:rooted/models/achievement.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service to handle data synchronization when connectivity is restored
class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  final ConnectivityService _connectivityService = ConnectivityService();
  final OfflineVerseDatabase _offlineDb = OfflineVerseDatabase();
  
  StreamSubscription<ConnectivityStatus>? _connectivitySubscription;
  bool _isSyncing = false;
  DateTime? _lastSyncTime;
  
  static const String _lastSyncKey = 'last_sync_timestamp';
  static const String _autoSyncEnabledKey = 'auto_sync_enabled';

  /// Initialize sync service
  Future<void> initialize() async {
    // Load last sync time
    final prefs = await SharedPreferences.getInstance();
    final lastSyncString = prefs.getString(_lastSyncKey);
    if (lastSyncString != null) {
      _lastSyncTime = DateTime.parse(lastSyncString);
    }

    // Listen for connectivity changes
    _connectivitySubscription = _connectivityService.statusStream.listen((status) {
      if (status == ConnectivityStatus.online) {
        _onConnectionRestored();
      }
    });

    // If currently online, do initial sync
    if (_connectivityService.isOnline && await isAutoSyncEnabled()) {
      await performSync();
    }
  }

  /// Called when connection is restored
  Future<void> _onConnectionRestored() async {
    if (await isAutoSyncEnabled()) {
      debugPrint('📡 Connection restored - starting sync...');
      await performSync();
    }
  }

  /// Perform full synchronization
  Future<SyncResult> performSync({bool force = false}) async {
    if (_isSyncing && !force) {
      return SyncResult(
        success: false,
        message: 'Sync already in progress',
        itemsSynced: 0,
      );
    }

    if (!_connectivityService.isOnline) {
      return SyncResult(
        success: false,
        message: 'No internet connection',
        itemsSynced: 0,
      );
    }

    _isSyncing = true;
    int itemsSynced = 0;
    int itemsFailed = 0;
    
    try {
      debugPrint('📡 Starting sync process...');
      
      // 1. Sync pending user data from queue with retry logic
      final pendingItems = await _offlineDb.getPendingSyncItems();
      debugPrint('📡 Found ${pendingItems.length} items to sync');
      
      for (final item in pendingItems) {
        try {
          // Retry each item with exponential backoff
          await ErrorHandler.retryWithBackoff(
            () => _syncItem(item),
            maxRetries: 3,
            initialDelay: const Duration(seconds: 1),
            onRetry: (attempt, error) {
              debugPrint('🔄 Retrying sync item ${item['id']}, attempt $attempt');
            },
            shouldRetry: (error) => ErrorHandler.isNetworkError(error),
          );
          
          await _offlineDb.clearSyncItem(item['id'] as int);
          itemsSynced++;
        } catch (e) {
          itemsFailed++;
          ErrorHandler.logError('Sync', e);
          debugPrint('❌ Failed to sync item ${item['id']} after retries: $e');
        }
      }

      // 2. Download new verses (if available)
      // In a real app, this would fetch from API
      // For now, we'll just mark the sync as successful
      
      // 3. Update last sync time
      _lastSyncTime = DateTime.now();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_lastSyncKey, _lastSyncTime!.toIso8601String());

      debugPrint('✅ Sync completed: $itemsSynced synced, $itemsFailed failed');
      
      final message = itemsFailed > 0
          ? 'Synced $itemsSynced items ($itemsFailed failed)'
          : itemsSynced > 0
              ? 'Successfully synced $itemsSynced items'
              : 'All data is up to date';
      
      return SyncResult(
        success: itemsFailed == 0,
        message: message,
        itemsSynced: itemsSynced,
        itemsFailed: itemsFailed,
        lastSyncTime: _lastSyncTime,
      );
    } catch (e) {
      ErrorHandler.logError('Sync', e);
      debugPrint('❌ Sync failed: $e');
      return SyncResult(
        success: false,
        message: ErrorHandler.getUserFriendlyMessage(e),
        itemsSynced: itemsSynced,
        itemsFailed: itemsFailed,
      );
    } finally {
      _isSyncing = false;
    }
  }
  
  /// Pull all data from cloud to local (Crosscheck)
  Future<void> syncFromCloud() async {
    if (!_connectivityService.isOnline) return;
    
    final supabase = SupabaseService();
    if (!supabase.isAuthenticated) return;
    
    try {
      debugPrint('📡 Starting Cloud Crosscheck (Pulling data)...');
      final data = await supabase.fetchUserData();
      
      // 1. Sync Bible Readings
      final bibleReadings = (data['bible_readings'] as List)
          .map((item) => BibleReading.fromJson(item))
          .toList();
      await LocalStorageService.syncBibleReadings(bibleReadings);
      
      // 2. Sync Prayers
      final prayers = (data['prayers'] as List)
          .map((item) => PrayerSchedule.fromJson(item))
          .toList();
      await LocalStorageService.syncPrayerSchedules(prayers);
      
      // 3. Sync Messages
      final messages = (data['messages'] as List)
          .map((item) => MessageSession.fromJson(item))
          .toList();
      await LocalStorageService.syncMessageSessions(messages);
      
      // 4. Sync Books
      final books = (data['books'] as List)
          .map((item) => BookReading.fromJson(item))
          .toList();
      await LocalStorageService.syncBookReadings(books);
      
      // 5. Sync Goals
      final goals = (data['goals'] as List)
          .map((item) => SpiritualGoal.fromJson(item))
          .toList();
      await LocalStorageService.syncSpiritualGoals(goals);
      
      // 6. Sync Achievements
      final achievements = (data['achievements'] as List)
          .map((item) => Achievement.fromJson(item))
          .toList();
      await AchievementService.syncAchievements(achievements);
      
      debugPrint('✅ Cloud Crosscheck completed successfully');
      
      _lastSyncTime = DateTime.now();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_lastSyncKey, _lastSyncTime!.toIso8601String());
    } catch (e) {
      ErrorHandler.logError('CloudSync', e);
      debugPrint('❌ Cloud Crosscheck failed: $e');
    }
  }

  /// Sync individual item
  Future<void> _syncItem(Map<String, dynamic> item) async {
    final entityType = item['entity_type'] as String;
    final entityId = item['entity_id'] as String;
    final rawData = item['data'] as String;
    final data = jsonDecode(rawData) as Map<String, dynamic>;
    
    final supabase = SupabaseService();

    switch (entityType) {
      case 'user_verse':
        await supabase.saveBibleReading(data);
        await _offlineDb.markVerseAsSynced(entityId);
        break;
      case 'profile':
        await supabase.upsertProfile(data);
        break;
      case 'prayer':
        await supabase.savePrayer(data);
        break;
      case 'achievement':
        await supabase.saveAchievement(data);
        break;
      case 'message_session':
        await supabase.saveMessage(data);
        break;
      case 'book_reading':
        await supabase.saveBook(data);
        break;
      case 'spiritual_goal':
        await supabase.saveGoal(data);
        break;
      default:
        debugPrint('⚠️ Unknown entity type for sync: $entityType');
    }
    
    debugPrint('✅ Synced $entityType: $entityId');
  }

  /// Check if auto-sync is enabled
  Future<bool> isAutoSyncEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_autoSyncEnabledKey) ?? true;
  }

  /// Enable/disable auto-sync
  Future<void> setAutoSync(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_autoSyncEnabledKey, enabled);
    
    if (enabled && _connectivityService.isOnline) {
      await performSync();
    }
  }

  /// Get last sync time
  DateTime? get lastSyncTime => _lastSyncTime;

  /// Check if sync is in progress
  bool get isSyncing => _isSyncing;

  /// Get sync status summary
  Future<SyncStatus> getSyncStatus() async {
    final stats = await _offlineDb.getDatabaseStats();
    
    return SyncStatus(
      isOnline: _connectivityService.isOnline,
      isSyncing: _isSyncing,
      lastSyncTime: _lastSyncTime,
      pendingItems: stats['pending_sync'] ?? 0,
      offlineVerses: stats['offline_verses'] ?? 0,
      userVerses: stats['user_verses'] ?? 0,
      autoSyncEnabled: await isAutoSyncEnabled(),
    );
  }

  /// Force sync now (manual trigger)
  Future<SyncResult> syncNow() async {
    if (!_connectivityService.isOnline) {
      return SyncResult(
        success: false,
        message: 'No internet connection. Changes will sync when online.',
        itemsSynced: 0,
      );
    }
    
    return await performSync(force: true);
  }

  /// Dispose resources
  void dispose() {
    _connectivitySubscription?.cancel();
  }
}

/// Sync result model
class SyncResult {
  final bool success;
  final String message;
  final int itemsSynced;
  final int itemsFailed;
  final DateTime? lastSyncTime;

  SyncResult({
    required this.success,
    required this.message,
    required this.itemsSynced,
    this.itemsFailed = 0,
    this.lastSyncTime,
  });
}

/// Sync status model
class SyncStatus {
  final bool isOnline;
  final bool isSyncing;
  final DateTime? lastSyncTime;
  final int pendingItems;
  final int offlineVerses;
  final int userVerses;
  final bool autoSyncEnabled;

  SyncStatus({
    required this.isOnline,
    required this.isSyncing,
    this.lastSyncTime,
    required this.pendingItems,
    required this.offlineVerses,
    required this.userVerses,
    required this.autoSyncEnabled,
  });

  String get statusMessage {
    if (!isOnline) {
      return pendingItems > 0
          ? 'Offline - $pendingItems items waiting to sync'
          : 'Offline - All changes saved locally';
    }
    
    if (isSyncing) {
      return 'Syncing...';
    }
    
    if (pendingItems > 0) {
      return 'Online - $pendingItems items pending';
    }
    
    if (lastSyncTime != null) {
      final duration = DateTime.now().difference(lastSyncTime!);
      if (duration.inMinutes < 1) {
        return 'Synced just now';
      } else if (duration.inHours < 1) {
        return 'Synced ${duration.inMinutes}m ago';
      } else if (duration.inDays < 1) {
        return 'Synced ${duration.inHours}h ago';
      } else {
        return 'Synced ${duration.inDays}d ago';
      }
    }
    
    return 'Online - Ready to sync';
  }
}

