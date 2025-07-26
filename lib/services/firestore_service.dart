import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_service.dart';

class FirestoreService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ユーザーIDを取得
  static String? get _userId => FirebaseService.currentUser?.uid;

  // === 旅行プラン関連 ===

  // 旅行を作成
  static Future<String?> createTrip(Map<String, dynamic> tripData) async {
    try {
      if (_userId == null) return null;
      
      tripData['userId'] = _userId;
      tripData['createdAt'] = FieldValue.serverTimestamp();
      tripData['updatedAt'] = FieldValue.serverTimestamp();
      
      DocumentReference docRef = await _firestore.collection('trips').add(tripData);
      return docRef.id;
    } catch (e) {
      print('Create Trip Error: $e');
      return null;
    }
  }

  // ユーザーの旅行リストを取得
  static Stream<QuerySnapshot> getUserTrips() {
    if (_userId == null) return const Stream.empty();
    
    return _firestore
        .collection('trips')
        .where('userId', isEqualTo: _userId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // 旅行の詳細を取得
  static Stream<DocumentSnapshot> getTripDetails(String tripId) {
    return _firestore.collection('trips').doc(tripId).snapshots();
  }

  // 旅行データを更新
  static Future<void> updateTrip(String tripId, Map<String, dynamic> data) async {
    try {
      data['updatedAt'] = FieldValue.serverTimestamp();
      await _firestore.collection('trips').doc(tripId).update(data);
    } catch (e) {
      print('Update Trip Error: $e');
    }
  }

  // === 旅行アクティビティ関連 ===

  // アクティビティを追加
  static Future<String?> addActivity(String tripId, Map<String, dynamic> activityData) async {
    try {
      activityData['tripId'] = tripId;
      activityData['createdAt'] = FieldValue.serverTimestamp();
      
      DocumentReference docRef = await _firestore
          .collection('trips')
          .doc(tripId)
          .collection('activities')
          .add(activityData);
      return docRef.id;
    } catch (e) {
      print('Add Activity Error: $e');
      return null;
    }
  }

  // アクティビティリストを取得
  static Stream<QuerySnapshot> getTripActivities(String tripId) {
    return _firestore
        .collection('trips')
        .doc(tripId)
        .collection('activities')
        .orderBy('date')
        .orderBy('time')
        .snapshots();
  }

  // アクティビティを更新
  static Future<void> updateActivity(String tripId, String activityId, Map<String, dynamic> data) async {
    try {
      await _firestore
          .collection('trips')
          .doc(tripId)
          .collection('activities')
          .doc(activityId)
          .update(data);
    } catch (e) {
      print('Update Activity Error: $e');
    }
  }

  // === 持ち物チェックリスト関連 ===

  // 持ち物アイテムを追加
  static Future<String?> addPackingItem(String tripId, Map<String, dynamic> itemData) async {
    try {
      itemData['tripId'] = tripId;
      itemData['createdAt'] = FieldValue.serverTimestamp();
      
      DocumentReference docRef = await _firestore
          .collection('trips')
          .doc(tripId)
          .collection('packingItems')
          .add(itemData);
      return docRef.id;
    } catch (e) {
      print('Add Packing Item Error: $e');
      return null;
    }
  }

  // 持ち物リストを取得
  static Stream<QuerySnapshot> getPackingItems(String tripId) {
    return _firestore
        .collection('trips')
        .doc(tripId)
        .collection('packingItems')
        .orderBy('category')
        .orderBy('name')
        .snapshots();
  }

  // 持ち物アイテムを更新
  static Future<void> updatePackingItem(String tripId, String itemId, Map<String, dynamic> data) async {
    try {
      await _firestore
          .collection('trips')
          .doc(tripId)
          .collection('packingItems')
          .doc(itemId)
          .update(data);
    } catch (e) {
      print('Update Packing Item Error: $e');
    }
  }

  // === 旅行書類関連 ===

  // 書類を追加
  static Future<String?> addDocument(String tripId, Map<String, dynamic> documentData) async {
    try {
      documentData['tripId'] = tripId;
      documentData['userId'] = _userId;
      documentData['createdAt'] = FieldValue.serverTimestamp();
      
      DocumentReference docRef = await _firestore
          .collection('trips')
          .doc(tripId)
          .collection('documents')
          .add(documentData);
      return docRef.id;
    } catch (e) {
      print('Add Document Error: $e');
      return null;
    }
  }

  // 書類リストを取得
  static Stream<QuerySnapshot> getTripDocuments(String tripId) {
    return _firestore
        .collection('trips')
        .doc(tripId)
        .collection('documents')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // === 写真・メディア関連 ===

  // メディアアイテムを追加
  static Future<String?> addMediaItem(String tripId, Map<String, dynamic> mediaData) async {
    try {
      mediaData['tripId'] = tripId;
      mediaData['userId'] = _userId;
      mediaData['createdAt'] = FieldValue.serverTimestamp();
      
      DocumentReference docRef = await _firestore
          .collection('trips')
          .doc(tripId)
          .collection('media')
          .add(mediaData);
      return docRef.id;
    } catch (e) {
      print('Add Media Item Error: $e');
      return null;
    }
  }

  // メディアリストを取得
  static Stream<QuerySnapshot> getTripMedia(String tripId) {
    return _firestore
        .collection('trips')
        .doc(tripId)
        .collection('media')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // === 観光スポット関連 ===

  // 観光スポットを追加
  static Future<String?> addTouristSpot(String tripId, Map<String, dynamic> spotData) async {
    try {
      spotData['tripId'] = tripId;
      spotData['createdAt'] = FieldValue.serverTimestamp();
      
      DocumentReference docRef = await _firestore
          .collection('trips')
          .doc(tripId)
          .collection('touristSpots')
          .add(spotData);
      return docRef.id;
    } catch (e) {
      print('Add Tourist Spot Error: $e');
      return null;
    }
  }

  // 観光スポットリストを取得
  static Stream<QuerySnapshot> getTouristSpots(String tripId) {
    return _firestore
        .collection('trips')
        .doc(tripId)
        .collection('touristSpots')
        .orderBy('rating', descending: true)
        .snapshots();
  }

  // === 設定・プリファレンス ===

  // ユーザー設定を保存
  static Future<void> saveUserPreferences(Map<String, dynamic> preferences) async {
    try {
      if (_userId == null) return;
      
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('preferences')
          .doc('settings')
          .set(preferences, SetOptions(merge: true));
    } catch (e) {
      print('Save User Preferences Error: $e');
    }
  }

  // ユーザー設定を取得
  static Future<DocumentSnapshot?> getUserPreferences() async {
    try {
      if (_userId == null) return null;
      
      return await _firestore
          .collection('users')
          .doc(_userId)
          .collection('preferences')
          .doc('settings')
          .get();
    } catch (e) {
      print('Get User Preferences Error: $e');
      return null;
    }
  }

  // === ユーティリティ ===

  // Firestore Timestampを DateTime に変換
  static DateTime? timestampToDateTime(Timestamp? timestamp) {
    return timestamp?.toDate();
  }

  // バッチ処理でデータを一括更新
  static Future<void> batchUpdate(List<Map<String, dynamic>> updates) async {
    try {
      WriteBatch batch = _firestore.batch();
      
      for (var update in updates) {
        DocumentReference docRef = _firestore.doc(update['path']);
        batch.update(docRef, update['data']);
      }
      
      await batch.commit();
    } catch (e) {
      print('Batch Update Error: $e');
    }
  }
}