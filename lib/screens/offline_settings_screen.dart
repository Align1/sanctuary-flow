import 'package:flutter/material.dart';
import 'package:rooted/services/connectivity_service.dart';
import 'package:rooted/services/verse_download_manager.dart';
import 'package:rooted/services/offline_verse_database.dart';
import 'package:rooted/widgets/offline_indicator.dart';

/// Settings screen for offline mode configuration
class OfflineSettingsScreen extends StatefulWidget {
  const OfflineSettingsScreen({super.key});

  @override
  State<OfflineSettingsScreen> createState() => _OfflineSettingsScreenState();
}

class _OfflineSettingsScreenState extends State<OfflineSettingsScreen> {
  final ConnectivityService _connectivityService = ConnectivityService();
  final VerseDownloadManager _downloadManager = VerseDownloadManager();
  final OfflineVerseDatabase _offlineDb = OfflineVerseDatabase();

  DownloadStats? _downloadStats;
  Map<String, int>? _dbStats;
  bool _isLoading = true;
  double _downloadProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);
    
    final downloadStats = await _downloadManager.getDownloadStats();
    final dbStats = await _offlineDb.getDatabaseStats();
    
    if (mounted) {
      setState(() {
        _downloadStats = downloadStats;
        _dbStats = dbStats;
        _isLoading = false;
      });
    }
  }

  Future<void> _downloadVerses() async {
    if (!_connectivityService.isOnline) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cannot download verses while offline'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    final result = await _downloadManager.downloadVerses(
      onProgress: (progress) {
        if (mounted) {
          setState(() {
            _downloadProgress = progress;
          });
        }
      },
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor: result.success ? Colors.green : Colors.red,
        ),
      );
      
      if (result.success) {
        await _loadStats();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Offline Mode'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showOfflineInfo,
            tooltip: 'About Offline Mode',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadStats,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Offline indicator
                  const OfflineIndicator(showWhenOnline: true),
                  const SizedBox(height: 24),

                  // Sync status card
                  const SyncStatusCard(),
                  const SizedBox(height: 24),

                  // Download verses section
                  _buildDownloadSection(),
                  const SizedBox(height: 24),

                  // Database statistics
                  _buildDatabaseStats(),
                  const SizedBox(height: 24),

                  // Offline features info
                  _buildOfflineFeatures(),
                ],
              ),
            ),
    );
  }

  Widget _buildDownloadSection() {
    final isDownloading = _downloadManager.isDownloading;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.download, color: Colors.blue),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Offline Verse Library',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      if (_downloadStats != null)
                        Text(
                          _downloadStats!.statusMessage,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            if (isDownloading)
              Column(
                children: [
                  LinearProgressIndicator(
                    value: _downloadProgress,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Downloading... ${(_downloadProgress * 100).toStringAsFixed(0)}%',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              )
            else
              ElevatedButton.icon(
                onPressed: _connectivityService.isOnline ? _downloadVerses : null,
                icon: const Icon(Icons.download),
                label: Text(_downloadStats?.versesDownloaded ?? false
                    ? 'Re-download Verses'
                    : 'Download Verses for Offline'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 44),
                ),
              ),
            
            if (!_connectivityService.isOnline)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Connect to internet to download verses',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.orange.shade700,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatabaseStats() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Storage Statistics',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            _buildStatRow(
              'Offline Verses Available',
              '${_dbStats?['offline_verses'] ?? 0}',
              Icons.book,
              Colors.blue,
            ),
            const Divider(),
            _buildStatRow(
              'Your Personal Verses',
              '${_dbStats?['user_verses'] ?? 0}',
              Icons.favorite,
              Colors.pink,
            ),
            const Divider(),
            _buildStatRow(
              'Pending Sync Items',
              '${_dbStats?['pending_sync'] ?? 0}',
              Icons.sync,
              Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfflineFeatures() {
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info, color: Colors.blue.shade700),
                const SizedBox(width: 8),
                Text(
                  'What Works Offline?',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildFeatureItem('✓ View downloaded Bible verses'),
            _buildFeatureItem('✓ Add reflections and favorites'),
            _buildFeatureItem('✓ Track your reading streak'),
            _buildFeatureItem('✓ Access all your saved data'),
            _buildFeatureItem('✓ Use home screen widgets'),
            const SizedBox(height: 8),
            Text(
              'All changes sync automatically when you\'re back online!',
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: Colors.blue.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          color: Colors.blue.shade900,
        ),
      ),
    );
  }

  void _showOfflineInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Offline Mode'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Offline-First Design',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Rooted is designed to work anywhere, anytime. All your spiritual growth data is stored locally on your device, so you can:',
              ),
              SizedBox(height: 12),
              Text('• Read Bible verses without internet'),
              Text('• Track your progress offline'),
              Text('• Add reflections and notes'),
              Text('• Continue your streak'),
              SizedBox(height: 12),
              Text(
                'Automatic Sync',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'When you reconnect to the internet, all your changes are automatically synced in the background. You never have to worry about losing your data.',
              ),
              SizedBox(height: 12),
              Text(
                'Download for Better Experience',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Download additional verses while online to access more inspirational content when offline.',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }
}

