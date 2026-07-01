import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// Service to monitor network connectivity and provide offline/online status
class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  StreamController<ConnectivityStatus>? _statusController;
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  
  ConnectivityStatus _currentStatus = ConnectivityStatus.online;

  /// Initialize connectivity monitoring
  Future<void> initialize() async {
    _statusController = StreamController<ConnectivityStatus>.broadcast();
    
    // Check initial connectivity
    final result = await _connectivity.checkConnectivity();
    _updateStatus(result);
    
    // Listen for connectivity changes
    _subscription = _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) {
      _updateStatus(results);
    });
  }

  /// Update connectivity status based on results
  void _updateStatus(List<ConnectivityResult> results) {
    final wasOffline = _currentStatus == ConnectivityStatus.offline;
    
    if (results.contains(ConnectivityResult.mobile) ||
        results.contains(ConnectivityResult.wifi) ||
        results.contains(ConnectivityResult.ethernet)) {
      _currentStatus = ConnectivityStatus.online;
    } else {
      _currentStatus = ConnectivityStatus.offline;
    }

    // Notify listeners
    _statusController?.add(_currentStatus);

    // Log status change
    if (kDebugMode) {
      if (_currentStatus == ConnectivityStatus.online && wasOffline) {
        debugPrint('📡 Connection restored - triggering sync');
      } else if (_currentStatus == ConnectivityStatus.offline) {
        debugPrint('📡 No connection - working offline');
      }
    }
  }

  /// Get current connectivity status
  ConnectivityStatus get currentStatus => _currentStatus;

  /// Check if currently online
  bool get isOnline => _currentStatus == ConnectivityStatus.online;

  /// Check if currently offline
  bool get isOffline => _currentStatus == ConnectivityStatus.offline;

  /// Stream of connectivity status changes
  Stream<ConnectivityStatus> get statusStream => 
      _statusController?.stream ?? const Stream.empty();

  /// Dispose resources
  void dispose() {
    _subscription?.cancel();
    _statusController?.close();
  }
}

/// Connectivity status enum
enum ConnectivityStatus {
  online,
  offline,
}

