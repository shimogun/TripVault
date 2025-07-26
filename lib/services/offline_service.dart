import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OfflineService {
  static final OfflineService _instance = OfflineService._internal();
  factory OfflineService() => _instance;
  OfflineService._internal();

  static const String _tripsKey = 'offline_trips';
  static const String _activitiesKey = 'offline_activities';
  static const String _packingItemsKey = 'offline_packing_items';
  static const String _documentsKey = 'offline_documents';
  static const String _pendingChangesKey = 'pending_changes';
  static const String _lastSyncKey = 'last_sync_timestamp';

  bool _isOnline = true;
  late ConnectivityResult _connectionStatus;
  final Connectivity _connectivity = Connectivity();

  // ネットワーク状態を監視
  Stream<bool> get onlineStatusStream => _connectivity.onConnectivityChanged.map(
    (ConnectivityResult result) {
      _connectionStatus = result;
      _isOnline = result != ConnectivityResult.none;
      
      if (_isOnline) {
        _syncPendingChanges();
      }
      
      return _isOnline;
    },
  );

  bool get isOnline => _isOnline;

  // オフライン初期化
  Future<void> initialize() async {
    _connectionStatus = await _connectivity.checkConnectivity();
    _isOnline = _connectionStatus != ConnectivityResult.none;
    
    if (_isOnline) {
      await _syncPendingChanges();
    }
    
    print('オフラインサービス初期化完了 - オンライン状態: $_isOnline');
  }

  // ローカルに旅行データを保存
  Future<void> saveTripOffline(Map<String, dynamic> tripData) async {
    final prefs = await SharedPreferences.getInstance();
    final trips = await _getOfflineTrips();
    
    // 既存の旅行を更新または新規追加
    final existingIndex = trips.indexWhere((trip) => trip['id'] == tripData['id']);
    if (existingIndex != -1) {
      trips[existingIndex] = tripData;
    } else {
      trips.add(tripData);
    }
    
    await prefs.setString(_tripsKey, jsonEncode(trips));
    
    // オンライン時は即座に同期、オフライン時は変更を記録
    if (_isOnline) {
      await _syncTripToFirestore(tripData);
    } else {
      await _addPendingChange('trip', 'update', tripData);
    }
  }

  // ローカルからトリップを取得
  Future<List<Map<String, dynamic>>> _getOfflineTrips() async {
    final prefs = await SharedPreferences.getInstance();
    final tripsJson = prefs.getString(_tripsKey);
    if (tripsJson == null) return [];
    
    try {
      final List<dynamic> tripsList = jsonDecode(tripsJson);
      return tripsList.cast<Map<String, dynamic>>();
    } catch (e) {
      print('オフライントリップ読み込みエラー: $e');
      return [];
    }
  }

  // 活動データをオフライン保存
  Future<void> saveActivityOffline(String tripId, Map<String, dynamic> activityData) async {
    final prefs = await SharedPreferences.getInstance();
    final activitiesJson = prefs.getString(_activitiesKey) ?? '{}';
    
    try {
      Map<String, dynamic> allActivities = jsonDecode(activitiesJson);
      
      if (allActivities[tripId] == null) {
        allActivities[tripId] = [];
      }
      
      List<dynamic> tripActivities = allActivities[tripId];
      final existingIndex = tripActivities.indexWhere((activity) => activity['id'] == activityData['id']);
      
      if (existingIndex != -1) {
        tripActivities[existingIndex] = activityData;
      } else {
        tripActivities.add(activityData);
      }
      
      allActivities[tripId] = tripActivities;
      await prefs.setString(_activitiesKey, jsonEncode(allActivities));
      
      if (_isOnline) {
        await _syncActivityToFirestore(tripId, activityData);
      } else {
        await _addPendingChange('activity', 'update', {'tripId': tripId, ...activityData});
      }
    } catch (e) {
      print('オフライン活動保存エラー: $e');
    }
  }

  // 持ち物リストをオフライン保存
  Future<void> savePackingItemOffline(String tripId, Map<String, dynamic> itemData) async {
    final prefs = await SharedPreferences.getInstance();
    final itemsJson = prefs.getString(_packingItemsKey) ?? '{}';
    
    try {
      Map<String, dynamic> allItems = jsonDecode(itemsJson);
      
      if (allItems[tripId] == null) {
        allItems[tripId] = [];
      }
      
      List<dynamic> tripItems = allItems[tripId];
      final existingIndex = tripItems.indexWhere((item) => item['id'] == itemData['id']);
      
      if (existingIndex != -1) {
        tripItems[existingIndex] = itemData;
      } else {
        tripItems.add(itemData);
      }
      
      allItems[tripId] = tripItems;
      await prefs.setString(_packingItemsKey, jsonEncode(allItems));
      
      if (_isOnline) {
        await _syncPackingItemToFirestore(tripId, itemData);
      } else {
        await _addPendingChange('packing_item', 'update', {'tripId': tripId, ...itemData});
      }
    } catch (e) {
      print('オフライン持ち物保存エラー: $e');
    }
  }

  // オフラインデータを取得
  Future<List<Map<String, dynamic>>> getOfflineTrips() async {
    return await _getOfflineTrips();
  }

  Future<List<Map<String, dynamic>>> getOfflineActivities(String tripId) async {
    final prefs = await SharedPreferences.getInstance();
    final activitiesJson = prefs.getString(_activitiesKey) ?? '{}';
    
    try {
      Map<String, dynamic> allActivities = jsonDecode(activitiesJson);
      List<dynamic> tripActivities = allActivities[tripId] ?? [];
      return tripActivities.cast<Map<String, dynamic>>();
    } catch (e) {
      print('オフライン活動取得エラー: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getOfflinePackingItems(String tripId) async {
    final prefs = await SharedPreferences.getInstance();
    final itemsJson = prefs.getString(_packingItemsKey) ?? '{}';
    
    try {
      Map<String, dynamic> allItems = jsonDecode(itemsJson);
      List<dynamic> tripItems = allItems[tripId] ?? [];
      return tripItems.cast<Map<String, dynamic>>();
    } catch (e) {
      print('オフライン持ち物取得エラー: $e');
      return [];
    }
  }

  // 保留中の変更を記録
  Future<void> _addPendingChange(String type, String action, Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final pendingJson = prefs.getString(_pendingChangesKey) ?? '[]';
    
    try {
      List<dynamic> pendingChanges = jsonDecode(pendingJson);
      
      pendingChanges.add({
        'type': type,
        'action': action,
        'data': data,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
      
      await prefs.setString(_pendingChangesKey, jsonEncode(pendingChanges));
      print('保留中の変更を追加: $type - $action');
    } catch (e) {
      print('保留中変更追加エラー: $e');
    }
  }

  // 保留中の変更を同期
  Future<void> _syncPendingChanges() async {
    if (!_isOnline) return;
    
    final prefs = await SharedPreferences.getInstance();
    final pendingJson = prefs.getString(_pendingChangesKey) ?? '[]';
    
    try {
      List<dynamic> pendingChanges = jsonDecode(pendingJson);
      
      if (pendingChanges.isEmpty) return;
      
      print('保留中の変更を同期中: ${pendingChanges.length}件');
      
      for (var change in pendingChanges) {
        await _processPendingChange(change);
      }
      
      // 同期完了後、保留中の変更をクリア
      await prefs.remove(_pendingChangesKey);
      await _updateLastSyncTime();
      
      print('すべての保留中変更の同期完了');
    } catch (e) {
      print('保留中変更同期エラー: $e');
    }
  }

  // 個別の保留中変更を処理
  Future<void> _processPendingChange(Map<String, dynamic> change) async {
    try {
      switch (change['type']) {
        case 'trip':
          await _syncTripToFirestore(change['data']);
          break;
        case 'activity':
          final data = change['data'];
          await _syncActivityToFirestore(data['tripId'], data);
          break;
        case 'packing_item':
          final data = change['data'];
          await _syncPackingItemToFirestore(data['tripId'], data);
          break;
      }
    } catch (e) {
      print('保留中変更処理エラー: $e');
      // エラーが発生した場合は再試行のため保留
      rethrow;
    }
  }

  // Firestoreへの同期メソッド
  Future<void> _syncTripToFirestore(Map<String, dynamic> tripData) async {
    try {
      await FirebaseFirestore.instance
          .collection('trips')
          .doc(tripData['id'])
          .set(tripData, SetOptions(merge: true));
      print('Trip同期完了: ${tripData['id']}');
    } catch (e) {
      print('Trip同期エラー: $e');
      rethrow;
    }
  }

  Future<void> _syncActivityToFirestore(String tripId, Map<String, dynamic> activityData) async {
    try {
      await FirebaseFirestore.instance
          .collection('trips')
          .doc(tripId)
          .collection('activities')
          .doc(activityData['id'])
          .set(activityData, SetOptions(merge: true));
      print('Activity同期完了: ${activityData['id']}');
    } catch (e) {
      print('Activity同期エラー: $e');
      rethrow;
    }
  }

  Future<void> _syncPackingItemToFirestore(String tripId, Map<String, dynamic> itemData) async {
    try {
      await FirebaseFirestore.instance
          .collection('trips')
          .doc(tripId)
          .collection('packingItems')
          .doc(itemData['id'])
          .set(itemData, SetOptions(merge: true));
      print('PackingItem同期完了: ${itemData['id']}');
    } catch (e) {
      print('PackingItem同期エラー: $e');
      rethrow;
    }
  }

  // 最終同期時刻を更新
  Future<void> _updateLastSyncTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastSyncKey, DateTime.now().millisecondsSinceEpoch);
  }

  // 最終同期時刻を取得
  Future<DateTime?> getLastSyncTime() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getInt(_lastSyncKey);
    return timestamp != null ? DateTime.fromMillisecondsSinceEpoch(timestamp) : null;
  }

  // Firestoreからローカルにデータを同期
  Future<void> syncFromFirestore(String userId) async {
    if (!_isOnline) return;
    
    try {
      print('Firestoreからデータ同期開始');
      
      // トリップデータを同期
      final tripsSnapshot = await FirebaseFirestore.instance
          .collection('trips')
          .where('userId', isEqualTo: userId)
          .get();
      
      List<Map<String, dynamic>> trips = [];
      for (var doc in tripsSnapshot.docs) {
        trips.add({'id': doc.id, ...doc.data()});
      }
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tripsKey, jsonEncode(trips));
      
      await _updateLastSyncTime();
      print('Firestore同期完了: ${trips.length}件のトリップ');
      
    } catch (e) {
      print('Firestore同期エラー: $e');
    }
  }

  // オフラインデータをクリア
  Future<void> clearOfflineData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tripsKey);
    await prefs.remove(_activitiesKey);
    await prefs.remove(_packingItemsKey);
    await prefs.remove(_documentsKey);
    await prefs.remove(_pendingChangesKey);
    print('オフラインデータクリア完了');
  }

  // 同期状態を取得
  Future<Map<String, dynamic>> getSyncStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final pendingJson = prefs.getString(_pendingChangesKey) ?? '[]';
    final lastSync = await getLastSyncTime();
    
    List<dynamic> pendingChanges = [];
    try {
      pendingChanges = jsonDecode(pendingJson);
    } catch (e) {
      print('同期状態取得エラー: $e');
    }
    
    return {
      'isOnline': _isOnline,
      'pendingChanges': pendingChanges.length,
      'lastSync': lastSync,
      'hasOfflineData': await _hasOfflineData(),
    };
  }

  // オフラインデータの有無をチェック
  Future<bool> _hasOfflineData() async {
    final trips = await _getOfflineTrips();
    return trips.isNotEmpty;
  }

  // 手動同期を実行
  Future<bool> performManualSync(String userId) async {
    if (!_isOnline) {
      print('オフライン状態のため同期できません');
      return false;
    }
    
    try {
      await _syncPendingChanges();
      await syncFromFirestore(userId);
      return true;
    } catch (e) {
      print('手動同期エラー: $e');
      return false;
    }
  }
}