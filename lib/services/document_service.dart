import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
// import 'package:file_picker/file_picker.dart';  // 一時無効化
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qr_flutter/qr_flutter.dart';

class DocumentService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 書類タイプの定義
  static const Map<String, Map<String, dynamic>> documentTypes = {
    'passport': {
      'name': 'パスポート',
      'icon': Icons.badge,
      'color': Colors.blue,
      'required': true,
    },
    'visa': {
      'name': 'ビザ',
      'icon': Icons.assignment,
      'color': Colors.green,
      'required': false,
    },
    'ticket': {
      'name': '航空券',
      'icon': Icons.flight,
      'color': Colors.orange,
      'required': true,
    },
    'hotel': {
      'name': 'ホテル予約',
      'icon': Icons.hotel,
      'color': Colors.purple,
      'required': false,
    },
    'insurance': {
      'name': '海外旅行保険',
      'icon': Icons.security,
      'color': Colors.red,
      'required': true,
    },
    'license': {
      'name': '国際運転免許証',
      'icon': Icons.drive_eta,
      'color': Colors.teal,
      'required': false,
    },
    'other': {
      'name': 'その他',
      'icon': Icons.description,
      'color': Colors.grey,
      'required': false,
    },
  };

  // 書類をアップロード（一時的にダミー実装）
  static Future<Map<String, dynamic>?> uploadDocument({
    required String userId,
    required String tripId,
    required String documentType,
    required String title,
    String? description,
    DateTime? expiryDate,
  }) async {
    try {
      // ダミー実装 - 実際のファイル選択とアップロードはskip
      await Future.delayed(Duration(seconds: 1)); // 処理時間をシミュレート
      
      String documentId = 'doc_${DateTime.now().millisecondsSinceEpoch}';
      
      Map<String, dynamic> documentData = {
        'id': documentId,
        'userId': userId,
        'tripId': tripId,
        'type': documentType,
        'title': title,
        'description': description ?? '',
        'fileName': 'dummy_file.pdf',
        'fileExtension': 'pdf',
        'fileUrl': 'https://example.com/dummy_file.pdf',
        'storagePath': 'documents/$userId/$tripId/dummy_$documentId',
        'expiryDate': expiryDate?.toIso8601String(),
        'uploadDate': DateTime.now().toIso8601String(),
        'status': 'active',
        'fileSize': 1024000,
      };

      print('書類アップロード完了（ダミー）: $title');
      return documentData;
      
    } catch (e) {
      print('書類アップロードエラー: $e');
      return null;
    }
  }

  // 書類一覧を取得
  static Future<List<Map<String, dynamic>>> getDocuments(String tripId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('documents')
          .where('tripId', isEqualTo: tripId)
          .where('status', isEqualTo: 'active')
          .orderBy('uploadDate', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        return {'id': doc.id, ...doc.data() as Map<String, dynamic>};
      }).toList();
      
    } catch (e) {
      print('書類取得エラー: $e');
      return [];
    }
  }

  // 書類を削除
  static Future<bool> deleteDocument(String documentId, String storagePath) async {
    try {
      // Firestoreから削除
      await _firestore.collection('documents').doc(documentId).update({
        'status': 'deleted',
        'deletedDate': DateTime.now().toIso8601String(),
      });

      // Firebase Storageから削除
      await _storage.ref().child(storagePath).delete();

      print('書類削除完了: $documentId');
      return true;
      
    } catch (e) {
      print('書類削除エラー: $e');
      return false;
    }
  }

  // QRコードデータを生成
  static String generateQRData(Map<String, dynamic> documentData) {
    Map<String, dynamic> qrData = {
      'type': 'tripvault_document',
      'documentId': documentData['id'],
      'title': documentData['title'],
      'docType': documentData['type'],
      'expiryDate': documentData['expiryDate'],
      'emergencyAccess': true,
      'generated': DateTime.now().toIso8601String(),
    };

    return jsonEncode(qrData);
  }

  // QRコードを生成
  static Widget generateQRCode(Map<String, dynamic> documentData, {double size = 200}) {
    String qrData = generateQRData(documentData);
    
    return QrImageView(
      data: qrData,
      version: QrVersions.auto,
      size: size,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      errorStateBuilder: (context, error) {
        return Container(
          width: size,
          height: size,
          color: Colors.red[100],
          child: Center(
            child: Text(
              'QRコード生成エラー',
              style: TextStyle(color: Colors.red),
            ),
          ),
        );
      },
    );
  }

  // 緊急アクセス用の簡易データを生成
  static Map<String, dynamic> generateEmergencyAccessData(List<Map<String, dynamic>> documents) {
    Map<String, dynamic> emergencyData = {
      'type': 'emergency_access',
      'documents': documents.map((doc) => {
        'type': doc['type'],
        'title': doc['title'],
        'expiryDate': doc['expiryDate'],
        'status': _getDocumentStatus(doc),
      }).toList(),
      'generated': DateTime.now().toIso8601String(),
      'totalDocuments': documents.length,
    };

    return emergencyData;
  }

  // 書類の状態を判定
  static String _getDocumentStatus(Map<String, dynamic> document) {
    if (document['expiryDate'] == null) return 'valid';
    
    DateTime expiryDate = DateTime.parse(document['expiryDate']);
    DateTime now = DateTime.now();
    
    if (expiryDate.isBefore(now)) {
      return 'expired';
    } else if (expiryDate.difference(now).inDays <= 30) {
      return 'expiring_soon';
    } else {
      return 'valid';
    }
  }

  // 書類の有効期限チェック
  static List<Map<String, dynamic>> checkExpiringDocuments(List<Map<String, dynamic>> documents) {
    return documents.where((doc) {
      if (doc['expiryDate'] == null) return false;
      
      DateTime expiryDate = DateTime.parse(doc['expiryDate']);
      DateTime now = DateTime.now();
      
      return expiryDate.difference(now).inDays <= 30 && expiryDate.isAfter(now);
    }).toList();
  }

  // 期限切れ書類チェック
  static List<Map<String, dynamic>> checkExpiredDocuments(List<Map<String, dynamic>> documents) {
    return documents.where((doc) {
      if (doc['expiryDate'] == null) return false;
      
      DateTime expiryDate = DateTime.parse(doc['expiryDate']);
      return expiryDate.isBefore(DateTime.now());
    }).toList();
  }

  // 書類の完成度を計算
  static Map<String, dynamic> calculateDocumentCompleteness(List<Map<String, dynamic>> documents) {
    List<String> requiredTypes = documentTypes.entries
        .where((entry) => entry.value['required'] == true)
        .map((entry) => entry.key)
        .toList();

    List<String> availableTypes = documents
        .map((doc) => doc['type'] as String)
        .toSet()
        .toList();

    List<String> missingRequired = requiredTypes
        .where((type) => !availableTypes.contains(type))
        .toList();

    int totalRequired = requiredTypes.length;
    int completedRequired = totalRequired - missingRequired.length;
    double completeness = totalRequired > 0 ? (completedRequired / totalRequired) : 1.0;

    return {
      'completeness': completeness,
      'totalRequired': totalRequired,
      'completedRequired': completedRequired,
      'missingRequired': missingRequired,
      'totalDocuments': documents.length,
    };
  }

  // ローカルに書類データをキャッシュ
  static Future<void> cacheDocumentsLocally(String tripId, List<Map<String, dynamic>> documents) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String documentsJson = jsonEncode(documents);
      await prefs.setString('cached_documents_$tripId', documentsJson);
      print('書類データローカルキャッシュ完了');
    } catch (e) {
      print('書類キャッシュエラー: $e');
    }
  }

  // ローカルキャッシュから書類データを取得
  static Future<List<Map<String, dynamic>>> getCachedDocuments(String tripId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? documentsJson = prefs.getString('cached_documents_$tripId');
      
      if (documentsJson == null) return [];
      
      List<dynamic> documentsList = jsonDecode(documentsJson);
      return documentsList.cast<Map<String, dynamic>>();
      
    } catch (e) {
      print('キャッシュ書類取得エラー: $e');
      return [];
    }
  }

  // ファイルタイプアイコンを取得
  static IconData getFileTypeIcon(String fileExtension) {
    switch (fileExtension.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Icons.image;
      default:
        return Icons.description;
    }
  }

  // ファイルサイズを人間が読める形式に変換
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}