# 📡 Offline Mode - Quick Reference

## 🚀 Quick Start

### For Users
1. **Install the app** - Offline mode works immediately!
2. **15+ verses pre-loaded** - No setup needed
3. **Use anywhere** - Works offline automatically
4. **Changes sync** - Automatic when back online

### For Developers
```dart
// Initialize (in main.dart)
await OfflineVerseDatabase().database;
await ConnectivityService().initialize();
await SyncService().initialize();

// Check connectivity
bool isOnline = ConnectivityService().isOnline;

// Get offline verse
final verse = await OfflineVerseDatabase().getRandomOfflineVerse();

// Manual sync
final result = await SyncService().syncNow();
```

---

## 📋 Common Tasks

### Check Online/Offline Status
```dart
import 'package:sanctuaryflow/services/connectivity_service.dart';

final connectivity = ConnectivityService();

// Current status
if (connectivity.isOnline) {
  print('Online');
} else {
  print('Offline');
}

// Listen to changes
connectivity.statusStream.listen((status) {
  if (status == ConnectivityStatus.online) {
    print('Connection restored!');
  }
});
```

### Save Data Offline-First
```dart
import 'package:sanctuaryflow/services/offline_verse_database.dart';

final db = OfflineVerseDatabase();

// Save verse
await db.saveUserVerse(verse, synced: false);

// Data saved locally, will sync later!
```

### Trigger Manual Sync
```dart
import 'package:sanctuaryflow/services/sync_service.dart';

final syncService = SyncService();

// Sync now
final result = await syncService.syncNow();

if (result.success) {
  print('✅ Synced ${result.itemsSynced} items');
} else {
  print('❌ ${result.message}');
}
```

### Download Verses for Offline
```dart
import 'package:sanctuaryflow/services/verse_download_manager.dart';

final manager = VerseDownloadManager();

// Download with progress
final result = await manager.downloadVerses(
  onProgress: (progress) {
    print('Downloading: ${(progress * 100).toInt()}%');
  },
);

print(result.message);
```

### Show Offline Indicator
```dart
import 'package:sanctuaryflow/widgets/offline_indicator.dart';

// Full indicator
OfflineIndicator(showWhenOnline: true)

// Compact for app bar
CompactOfflineIndicator()

// Sync status card
SyncStatusCard()
```

---

## 🎯 Features At a Glance

| Feature | Online | Offline |
|---------|--------|---------|
| Daily Verse | ✅ | ✅ |
| Reflections | ✅ | ✅ |
| Favorites | ✅ | ✅ |
| Streak Tracking | ✅ | ✅ |
| Bible Reading | ✅ | ✅ |
| Prayer Tracking | ✅ | ✅ |
| Achievements | ✅ | ✅ |
| Home Widgets | ✅ | ✅ |
| Download Verses | ✅ | ❌ |
| Sync Data | ✅ | ❌ (queued) |

---

## 🔧 Key Services

### ConnectivityService
- **Purpose**: Monitor network status
- **File**: `lib/services/connectivity_service.dart`
- **Key Methods**:
  - `isOnline` - Check current status
  - `statusStream` - Listen to changes

### OfflineVerseDatabase
- **Purpose**: Local SQLite storage
- **File**: `lib/services/offline_verse_database.dart`
- **Key Methods**:
  - `getRandomOfflineVerse()` - Get random verse
  - `saveUserVerse()` - Save verse locally
  - `getDatabaseStats()` - Get statistics

### SyncService
- **Purpose**: Background synchronization
- **File**: `lib/services/sync_service.dart`
- **Key Methods**:
  - `syncNow()` - Trigger sync
  - `getSyncStatus()` - Check status
  - `setAutoSync()` - Enable/disable auto-sync

### VerseDownloadManager
- **Purpose**: Download offline content
- **File**: `lib/services/verse_download_manager.dart`
- **Key Methods**:
  - `downloadVerses()` - Download content
  - `getDownloadStats()` - Check status

---

## 💾 Database Tables

### verses (Offline Library)
- Pre-loaded verses for offline access
- Expandable through downloads
- Organized by category

### user_verses (User Data)
- User's verses, reflections, favorites
- Sync tracking
- Timestamps for conflict resolution

### sync_queue (Pending Sync)
- Changes waiting to sync
- Auto-processed when online
- Ensures zero data loss

---

## 🎨 UI Components

### OfflineIndicator
**Location**: `lib/widgets/offline_indicator.dart`

**Usage**:
```dart
// Show always
OfflineIndicator(showWhenOnline: true)

// Show only when offline
OfflineIndicator()
```

**Colors**:
- 🟢 Green - Online and synced
- 🔵 Blue - Online with pending sync
- 🟠 Orange - Offline with changes

### CompactOfflineIndicator
**Usage**: In app bars for minimal space

```dart
AppBar(
  title: Text('My Screen'),
  actions: [CompactOfflineIndicator()],
)
```

### SyncStatusCard
**Usage**: In settings for detailed info

```dart
SyncStatusCard() // Shows full sync details
```

---

## 📊 Status Messages

### Connectivity Status
- **"Working Offline"** - No internet, all changes saved locally
- **"All Synced"** - Online and all data synced
- **"Pending Sync"** - Online with items to sync
- **"Syncing..."** - Sync in progress

### Sync Status
- **"Synced just now"** - Recently synced
- **"Synced 5m ago"** - Last sync time
- **"Offline - 3 items waiting"** - Pending changes
- **"No internet connection"** - Cannot sync

---

## ⚡ Performance Tips

### Storage
- Each verse: ~1-2 KB
- 100 verses: ~150 KB total
- Minimal impact on device

### Battery
- Connectivity monitoring: Negligible
- Sync operations: Minimal (background)
- SQLite: Very efficient

### Network
- Download 50 verses: ~50 KB
- Sync operation: <10 KB
- Zero usage offline: All local

---

## 🐛 Quick Troubleshooting

### Problem: Sync not working
**Solution**: Check auto-sync enabled, trigger manual sync

### Problem: No verses offline
**Solution**: Download verses while online, check database stats

### Problem: Wrong status showing
**Solution**: Restart app, toggle airplane mode

### Problem: Growing sync queue
**Solution**: Ensure stable connection, manual sync

---

## 📱 Testing Offline Mode

### Quick Test
1. Open app
2. Enable airplane mode
3. Add reflection to verse
4. Check offline indicator shows
5. Disable airplane mode
6. Watch automatic sync
7. Verify changes persisted

### What to Test
- ✅ All features work offline
- ✅ Offline indicator appears
- ✅ Changes queued for sync
- ✅ Auto-sync on reconnection
- ✅ Manual sync works
- ✅ No data loss

---

## 🔗 Related Documentation

- **[OFFLINE_MODE_GUIDE.md](OFFLINE_MODE_GUIDE.md)** - Complete technical guide
- **[README.md](README.md)** - Project overview
- **[HOME_WIDGETS_GUIDE.md](HOME_WIDGETS_GUIDE.md)** - Widget documentation

---

## 💡 Pro Tips

### For Best Experience
1. Download verses while on WiFi
2. Keep auto-sync enabled
3. Check sync status occasionally
4. Don't worry about data loss - it's all saved!

### For Developers
1. Always save locally first
2. Add to sync queue when offline
3. Provide feedback to users
4. Test offline scenarios thoroughly

---

## 📞 Quick Help

**Offline not working?**
- Check database initialized in `main.dart`
- Verify services initialized
- Check for errors in console

**Sync issues?**
- Check internet connection
- Verify auto-sync enabled
- Trigger manual sync
- Review sync queue

**Need more help?**
- See [OFFLINE_MODE_GUIDE.md](OFFLINE_MODE_GUIDE.md)
- Check database statistics
- Review connectivity service logs

---

**Implementation**: ✅ Complete  
**Status**: 🚀 Production Ready  
**Documentation**: ✅ Comprehensive

*Your spiritual growth, uninterrupted.* 🙏

