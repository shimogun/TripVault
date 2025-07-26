import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';  // 一時無効化
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

// 一時的なダミークラス
class DummyXFile {
  final String path;
  final String name;
  
  DummyXFile({required this.path, required this.name});
}

class MediaService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // static final ImagePicker _picker = ImagePicker();  // 一時無効化

  // アルバムタイプの定義
  static const Map<String, Map<String, dynamic>> albumTypes = {
    'trip_moments': {
      'name': '旅行の思い出',
      'icon': Icons.photo_camera,
      'color': Colors.blue,
      'description': '旅行中に撮影した写真・動画',
    },
    'food': {
      'name': 'グルメ',
      'icon': Icons.restaurant,
      'color': Colors.orange,
      'description': '現地の料理・レストラン',
    },
    'scenery': {
      'name': '風景・観光地',
      'icon': Icons.landscape,
      'color': Colors.green,
      'description': '美しい風景や観光スポット',
    },
    'people': {
      'name': '人物・仲間',
      'icon': Icons.people,
      'color': Colors.purple,
      'description': '一緒に旅行した仲間たち',
    },
    'transportation': {
      'name': '交通手段',
      'icon': Icons.train,
      'color': Colors.teal,
      'description': '電車・飛行機・バスなど',
    },
    'shopping': {
      'name': 'ショッピング',
      'icon': Icons.shopping_bag,
      'color': Colors.pink,
      'description': 'お土産・ショッピング',
    },
    'events': {
      'name': 'イベント・体験',
      'icon': Icons.celebration,
      'color': Colors.amber,
      'description': 'イベントや特別な体験',
    },
    'other': {
      'name': 'その他',
      'icon': Icons.photo_library,
      'color': Colors.grey,
      'description': 'その他の写真・動画',
    },
  };

  // 写真を撮影またはギャラリーから選択（一時的にダミー実装）
  static Future<List<DummyXFile>?> pickMedia({
    required String source,  // 'camera' or 'gallery'
    bool allowMultiple = true,
    bool includeVideo = true,
  }) async {
    try {
      await Future.delayed(Duration(seconds: 1)); // 処理時間をシミュレート
      
      // ダミーファイルを返す
      return [
        DummyXFile(
          path: '/dummy/path/image_${DateTime.now().millisecondsSinceEpoch}.jpg',
          name: 'dummy_image.jpg',
        ),
      ];
    } catch (e) {
      print('メディア選択エラー: $e');
      return null;
    }
  }

  // メディアファイルをFirebase Storageにアップロード（一時的にダミー実装）
  static Future<Map<String, dynamic>?> uploadMedia({
    required String userId,
    required String tripId,
    required DummyXFile mediaFile,
    required String albumType,
    String? caption,
    String? location,
    DateTime? takenAt,
  }) async {
    try {
      await Future.delayed(Duration(seconds: 2)); // アップロード時間をシミュレート
      
      final String fileName = mediaFile.name;
      final String fileExtension = fileName.split('.').last.toLowerCase();
      final bool isVideo = ['mp4', 'mov', 'avi', 'mkv'].contains(fileExtension);
      
      // ダミーデータを作成
      final String mediaId = 'media_${DateTime.now().millisecondsSinceEpoch}';
      
      final Map<String, dynamic> mediaData = {
        'id': mediaId,
        'userId': userId,
        'tripId': tripId,
        'albumType': albumType,
        'fileName': fileName,
        'fileExtension': fileExtension,
        'isVideo': isVideo,
        'fileUrl': 'https://picsum.photos/400/300?random=${DateTime.now().millisecondsSinceEpoch}',
        'thumbnailUrl': 'https://picsum.photos/400/300?random=${DateTime.now().millisecondsSinceEpoch}',
        'storagePath': 'media/$userId/$tripId/dummy_$mediaId',
        'caption': caption ?? '',
        'location': location ?? '',
        'takenAt': (takenAt ?? DateTime.now()).toIso8601String(),
        'uploadDate': DateTime.now().toIso8601String(),
        'fileSize': 2048000, // 2MB
        'status': 'active',
        'likes': 0,
        'metadata': {
          'width': 400,
          'height': 300,
          'duration': isVideo ? 30 : null,
        },
      };
      
      print('メディアアップロード完了（ダミー）: $fileName');
      return mediaData;
      
    } catch (e) {
      print('メディアアップロードエラー: $e');
      return null;
    }
  }

  // 旅行のメディア一覧を取得
  static Future<List<Map<String, dynamic>>> getTripMedia(String tripId, {String? albumType}) async {
    try {
      Query query = _firestore
          .collection('media')
          .where('tripId', isEqualTo: tripId)
          .where('status', isEqualTo: 'active')
          .orderBy('takenAt', descending: true);
      
      if (albumType != null && albumType != 'all') {
        query = query.where('albumType', isEqualTo: albumType);
      }
      
      final QuerySnapshot snapshot = await query.get();
      
      return snapshot.docs.map((doc) {
        return {'id': doc.id, ...doc.data() as Map<String, dynamic>};
      }).toList();
      
    } catch (e) {
      print('メディア取得エラー: $e');
      return [];
    }
  }

  // アルバムタイプ別の統計を取得
  static Future<Map<String, int>> getAlbumStatistics(String tripId) async {
    try {
      final List<Map<String, dynamic>> allMedia = await getTripMedia(tripId);
      final Map<String, int> statistics = {};
      
      // 各アルバムタイプの件数を集計
      for (String albumType in albumTypes.keys) {
        statistics[albumType] = allMedia.where((media) => media['albumType'] == albumType).length;
      }
      
      statistics['total'] = allMedia.length;
      statistics['photos'] = allMedia.where((media) => media['isVideo'] == false).length;
      statistics['videos'] = allMedia.where((media) => media['isVideo'] == true).length;
      
      return statistics;
      
    } catch (e) {
      print('統計取得エラー: $e');
      return {};
    }
  }

  // メディアを削除
  static Future<bool> deleteMedia(String mediaId, String storagePath) async {
    try {
      // Firestoreから削除
      await _firestore.collection('media').doc(mediaId).update({
        'status': 'deleted',
        'deletedDate': DateTime.now().toIso8601String(),
      });
      
      // Firebase Storageから削除
      await _storage.ref().child(storagePath).delete();
      
      print('メディア削除完了: $mediaId');
      return true;
      
    } catch (e) {
      print('メディア削除エラー: $e');
      return false;
    }
  }

  // キャプションや場所情報を更新
  static Future<bool> updateMediaInfo({
    required String mediaId,
    String? caption,
    String? location,
    String? albumType,
  }) async {
    try {
      final Map<String, dynamic> updateData = {};
      
      if (caption != null) updateData['caption'] = caption;
      if (location != null) updateData['location'] = location;
      if (albumType != null) updateData['albumType'] = albumType;
      
      if (updateData.isNotEmpty) {
        updateData['updatedDate'] = DateTime.now().toIso8601String();
        await _firestore.collection('media').doc(mediaId).update(updateData);
      }
      
      return true;
      
    } catch (e) {
      print('メディア情報更新エラー: $e');
      return false;
    }
  }

  // いいね機能
  static Future<bool> toggleLike(String mediaId, bool isLiked) async {
    try {
      final int increment = isLiked ? 1 : -1;
      
      await _firestore.collection('media').doc(mediaId).update({
        'likes': FieldValue.increment(increment),
        'lastLiked': DateTime.now().toIso8601String(),
      });
      
      return true;
      
    } catch (e) {
      print('いいね更新エラー: $e');
      return false;
    }
  }

  // ローカルキャッシュにメディア情報を保存
  static Future<void> cacheMediaLocally(String tripId, List<Map<String, dynamic>> mediaList) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String mediaJson = jsonEncode(mediaList);
      await prefs.setString('cached_media_$tripId', mediaJson);
      print('メディアデータローカルキャッシュ完了');
    } catch (e) {
      print('メディアキャッシュエラー: $e');
    }
  }

  // ローカルキャッシュからメディア情報を取得
  static Future<List<Map<String, dynamic>>> getCachedMedia(String tripId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? mediaJson = prefs.getString('cached_media_$tripId');
      
      if (mediaJson == null) return [];
      
      final List<dynamic> mediaList = jsonDecode(mediaJson);
      return mediaList.cast<Map<String, dynamic>>();
      
    } catch (e) {
      print('キャッシュメディア取得エラー: $e');
      return [];
    }
  }

  // サムネイル用の最適化された画像Widgetを生成
  static Widget buildThumbnail({
    required String imageUrl,
    required double size,
    BoxFit fit = BoxFit.cover,
    bool isVideo = false,
  }) {
    return Container(
      width: size,
      height: size,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              width: size,
              height: size,
              fit: fit,
              placeholder: (context, url) => Container(
                color: Colors.grey[300],
                child: const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey[300],
                child: const Icon(Icons.error, color: Colors.grey),
              ),
            ),
          ),
          if (isVideo)
            Positioned(
              bottom: 4,
              right: 4,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ファイルタイプアイコンを取得
  static IconData getFileTypeIcon(String fileExtension) {
    switch (fileExtension.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'webp':
        return Icons.image;
      case 'mp4':
      case 'mov':
      case 'avi':
      case 'mkv':
      case 'webm':
        return Icons.videocam;
      default:
        return Icons.description;
    }
  }

  // メディアファイルのサイズを人間が読める形式に変換
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  // 日付でグループ化
  static Map<String, List<Map<String, dynamic>>> groupByDate(List<Map<String, dynamic>> mediaList) {
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    
    for (var media in mediaList) {
      final DateTime takenAt = DateTime.parse(media['takenAt']);
      final String dateKey = '${takenAt.year}-${takenAt.month.toString().padLeft(2, '0')}-${takenAt.day.toString().padLeft(2, '0')}';
      
      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(media);
    }
    
    return grouped;
  }
}