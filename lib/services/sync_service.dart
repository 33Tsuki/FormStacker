import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import '../db/database_helper.dart';
import '../models/form_response.dart';

enum SyncState { idle, syncing, success, failed }

class SyncService {
  SyncService._internal();
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Connectivity _connectivity = Connectivity();

  /// Notifier for UI to observe sync state changes.
  final ValueNotifier<SyncState> syncState = ValueNotifier(SyncState.idle);

  Future<bool> isConnected() async {
    final status = await _connectivity.checkConnectivity();
    return status == ConnectivityResult.mobile ||
        status == ConnectivityResult.wifi ||
        status == ConnectivityResult.ethernet;
  }

  void _setSyncState(SyncState state) {
    syncState.value = state;
    if (state == SyncState.success || state == SyncState.failed) {
      Future.delayed(const Duration(seconds: 4), () {
        // Only reset if still showing the same terminal state
        if (syncState.value == state) {
          syncState.value = SyncState.idle;
        }
      });
    }
  }

  Future<bool> syncResponse(FormResponse response) async {
    if (response.id == null) {
      debugPrint('SyncService.syncResponse skipped because response has no local id');
      return false;
    }

    final connected = await isConnected();
    if (!connected) {
      debugPrint('SyncService.syncResponse skipped because device is offline');
      return false;
    }

    _setSyncState(SyncState.syncing);

    try {
      final data = {
        'name': response.name,
        'email': response.email,
        'dob': response.dob.toIso8601String(),
        'age': response.age,
        'gender': response.gender,
        'yearsOfExperience': response.yearsOfExperience,
        'rating': response.rating,
        'agreed': response.agreed,
        'photoPath': response.photoPath,
        'resumePath': response.resumePath,
        'languages': response.languages,
        'heightFeet': response.heightFeet,
        'heightInches': response.heightInches,
        'weight': response.weight,
        'submittedAt': response.createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
      };

      final docRef = await _firestore.collection('responses').add(data);
      await DatabaseHelper.instance.markAsSynced(response.id!, docRef.id);
      debugPrint('SyncService.syncResponse succeeded for local id ${response.id}');
      _setSyncState(SyncState.success);
      return true;
    } catch (error, stackTrace) {
      debugPrint('SyncService.syncResponse failed: $error');
      debugPrint('$stackTrace');
      _setSyncState(SyncState.failed);
      return false;
    }
  }

  Future<int> syncAllPending() async {
    final pending = await DatabaseHelper.instance.getUnsyncedResponses();
    if (pending.isEmpty) {
      debugPrint('SyncService.syncAllPending found no pending responses');
      return 0;
    }

    final connected = await isConnected();
    if (!connected) {
      debugPrint('SyncService.syncAllPending skipped because device is offline');
      return 0;
    }

    _setSyncState(SyncState.syncing);

    var syncedCount = 0;
    var hadFailure = false;
    for (final response in pending) {
      try {
        final synced = await syncResponse(response);
        if (synced) {
          syncedCount++;
        } else {
          hadFailure = true;
        }
      } catch (_) {
        hadFailure = true;
      }
    }

    if (hadFailure && syncedCount == 0) {
      _setSyncState(SyncState.failed);
    } else {
      _setSyncState(SyncState.success);
    }

    debugPrint('SyncService.syncAllPending synced $syncedCount responses');
    return syncedCount;
  }
}
