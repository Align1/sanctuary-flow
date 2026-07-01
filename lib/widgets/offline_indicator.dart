import 'package:flutter/material.dart';
import 'package:rooted/services/connectivity_service.dart';
import 'package:rooted/services/sync_service.dart';
import 'dart:async';

/// Widget to display offline/online status and sync information
class OfflineIndicator extends StatefulWidget {
  final bool showWhenOnline;
  final EdgeInsetsGeometry? margin;

  const OfflineIndicator({
    super.key,
    this.showWhenOnline = false,
    this.margin,
  });

  @override
  State<OfflineIndicator> createState() => _OfflineIndicatorState();
}

class _OfflineIndicatorState extends State<OfflineIndicator> {
  final ConnectivityService _connectivityService = ConnectivityService();
  final SyncService _syncService = SyncService();
  
  StreamSubscription<ConnectivityStatus>? _subscription;
  ConnectivityStatus _status = ConnectivityStatus.online;
  SyncStatus? _syncStatus;

  @override
  void initState() {
    super.initState();
    _status = _connectivityService.currentStatus;
    _loadSyncStatus();
    
    _subscription = _connectivityService.statusStream.listen((status) {
      if (mounted) {
        setState(() {
          _status = status;
        });
        _loadSyncStatus();
      }
    });
  }

  Future<void> _loadSyncStatus() async {
    final status = await _syncService.getSyncStatus();
    if (mounted) {
      setState(() {
        _syncStatus = status;
      });
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Hide when online if showWhenOnline is false
    if (_status == ConnectivityStatus.online && !widget.showWhenOnline) {
      return const SizedBox.shrink();
    }

    final isOffline = _status == ConnectivityStatus.offline;
    final hasPendingSync = (_syncStatus?.pendingItems ?? 0) > 0;

    return Container(
      margin: widget.margin ?? const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isOffline 
            ? Colors.orange.shade50 
            : (hasPendingSync ? Colors.blue.shade50 : Colors.green.shade50),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isOffline 
              ? Colors.orange.shade300 
              : (hasPendingSync ? Colors.blue.shade300 : Colors.green.shade300),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isOffline 
                ? Icons.cloud_off 
                : (hasPendingSync ? Icons.cloud_sync : Icons.cloud_done),
            color: isOffline 
                ? Colors.orange.shade700 
                : (hasPendingSync ? Colors.blue.shade700 : Colors.green.shade700),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _getTitle(),
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: isOffline 
                        ? Colors.orange.shade900 
                        : (hasPendingSync ? Colors.blue.shade900 : Colors.green.shade900),
                  ),
                ),
                if (_syncStatus != null)
                  Text(
                    _syncStatus!.statusMessage,
                    style: TextStyle(
                      fontSize: 11,
                      color: isOffline 
                          ? Colors.orange.shade700 
                          : (hasPendingSync ? Colors.blue.shade700 : Colors.green.shade700),
                    ),
                  ),
              ],
            ),
          ),
          if (isOffline && hasPendingSync)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${_syncStatus!.pendingItems}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade900,
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _getTitle() {
    if (_status == ConnectivityStatus.offline) {
      return 'Working Offline';
    }
    
    if (_syncStatus?.isSyncing ?? false) {
      return 'Syncing...';
    }
    
    if ((_syncStatus?.pendingItems ?? 0) > 0) {
      return 'Pending Sync';
    }
    
    return 'All Synced';
  }
}

/// Compact offline indicator for app bar
class CompactOfflineIndicator extends StatefulWidget {
  const CompactOfflineIndicator({super.key});

  @override
  State<CompactOfflineIndicator> createState() => _CompactOfflineIndicatorState();
}

class _CompactOfflineIndicatorState extends State<CompactOfflineIndicator> {
  final ConnectivityService _connectivityService = ConnectivityService();
  StreamSubscription<ConnectivityStatus>? _subscription;
  ConnectivityStatus _status = ConnectivityStatus.online;

  @override
  void initState() {
    super.initState();
    _status = _connectivityService.currentStatus;
    
    _subscription = _connectivityService.statusStream.listen((status) {
      if (mounted) {
        setState(() {
          _status = status;
        });
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_status == ConnectivityStatus.online) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.orange.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.cloud_off,
            size: 14,
            color: Colors.orange.shade700,
          ),
          const SizedBox(width: 4),
          Text(
            'Offline',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.orange.shade900,
            ),
          ),
        ],
      ),
    );
  }
}

/// Sync status card for settings
class SyncStatusCard extends StatefulWidget {
  const SyncStatusCard({super.key});

  @override
  State<SyncStatusCard> createState() => _SyncStatusCardState();
}

class _SyncStatusCardState extends State<SyncStatusCard> {
  final SyncService _syncService = SyncService();
  final ConnectivityService _connectivityService = ConnectivityService();
  
  SyncStatus? _syncStatus;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    setState(() => _isLoading = true);
    final status = await _syncService.getSyncStatus();
    if (mounted) {
      setState(() {
        _syncStatus = status;
        _isLoading = false;
      });
    }
  }

  Future<void> _triggerSync() async {
    if (!_connectivityService.isOnline) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cannot sync while offline'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    setState(() => _isLoading = true);
    final result = await _syncService.syncNow();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor: result.success ? Colors.green : Colors.red,
        ),
      );
      await _loadStatus();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _syncStatus == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _syncStatus!.isOnline ? Icons.cloud_done : Icons.cloud_off,
                  color: _syncStatus!.isOnline ? Colors.green : Colors.orange,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sync Status',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        _syncStatus!.statusMessage,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                if (_syncStatus!.isOnline && !_syncStatus!.isSyncing)
                  IconButton(
                    icon: const Icon(Icons.sync),
                    onPressed: _triggerSync,
                    tooltip: 'Sync now',
                  ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Offline Verses', '${_syncStatus!.offlineVerses}'),
            _buildInfoRow('Your Verses', '${_syncStatus!.userVerses}'),
            if (_syncStatus!.pendingItems > 0)
              _buildInfoRow(
                'Pending Sync',
                '${_syncStatus!.pendingItems}',
                color: Colors.orange,
              ),
            const SizedBox(height: 12),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Auto-sync when online'),
              subtitle: const Text('Automatically sync when connection is restored'),
              value: _syncStatus!.autoSyncEnabled,
              onChanged: (value) async {
                await _syncService.setAutoSync(value);
                await _loadStatus();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: color ?? Colors.grey.shade700,
              fontSize: 13,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: color ?? Colors.black87,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

