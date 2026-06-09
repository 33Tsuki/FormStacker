import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

import 'app_globals.dart';
import 'sync_service.dart';

class ConnectivityService {
  ConnectivityService._internal();
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;

  final Connectivity _connectivity = Connectivity();
  bool _wasOffline = false;

  /// Notifier for UI to observe online/offline state.
  final ValueNotifier<bool> isOnline = ValueNotifier(true);

  Future<void> initialize() async {
    final result = await _connectivity.checkConnectivity();
    final connected = _isConnectedResult(result);
    _wasOffline = !connected;
    isOnline.value = connected;
    _connectivity.onConnectivityChanged.listen((result) async {
      final connected = _isConnectedResult(result);
      isOnline.value = connected;
      if (connected && _wasOffline) {
        final syncedCount = await SyncService().syncAllPending();
        _showSnackBar('Back online. Syncing pending responses...');
        debugPrint('ConnectivityService restored network, synced $syncedCount records');
      }
      _wasOffline = !connected;
    });
  }

  bool _isConnectedResult(ConnectivityResult result) {
    return result == ConnectivityResult.mobile ||
        result == ConnectivityResult.wifi ||
        result == ConnectivityResult.ethernet;
  }

  void _showSnackBar(String message) {
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
