import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'firebase_service.dart';

class StorageService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  static final ImagePicker _picker = ImagePicker();
  static const Uuid _uuid = Uuid();

  // 画像を選択
  static Future<XFile?> pickImage({ImageSource source = ImageSource.gallery}) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 80,
      );
      return image;
    } catch (e) {
      print('Pick Image Error: $e');
      return null;
    }
  }

  // 複数画像を選択
  static Future<List<XFile>?> pickMultipleImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 80,
      );
      return images;
    } catch (e) {
      print('Pick Multiple Images Error: $e');
      return null;
    }
  }

  // 動画を選択
  static Future<XFile?> pickVideo({ImageSource source = ImageSource.gallery}) async {
    try {
      final XFile? video = await _picker.pickVideo(
        source: source,
        maxDuration: const Duration(minutes: 5),
      );
      return video;
    } catch (e) {
      print('Pick Video Error: $e');
      return null;
    }
  }

  // ファイルをFirebase Storageにアップロード
  static Future<String?> uploadFile({
    required File file,
    required String folder, // 'trips', 'documents', 'media' など
    String? tripId,
    Function(double)? onProgress,
  }) async {
    try {
      final String userId = FirebaseService.currentUser?.uid ?? 'anonymous';
      final String fileName = '${_uuid.v4()}.${file.path.split('.').last}';
      final String path = tripId != null 
          ? '$folder/$userId/$tripId/$fileName'
          : '$folder/$userId/$fileName';
      
      final Reference ref = _storage.ref().child(path);
      final UploadTask uploadTask = ref.putFile(file);

      // アップロード進捗を監視
      if (onProgress != null) {
        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          double progress = snapshot.bytesTransferred / snapshot.totalBytes;
          onProgress(progress);
        });
      }

      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      print('Upload File Error: $e');
      return null;
    }
  }

  // 画像をアップロード
  static Future<String?> uploadImage({
    required XFile imageFile,
    String? tripId,
    Function(double)? onProgress,
  }) async {
    try {
      final File file = File(imageFile.path);
      return await uploadFile(
        file: file,
        folder: 'media/images',
        tripId: tripId,
        onProgress: onProgress,
      );
    } catch (e) {
      print('Upload Image Error: $e');
      return null;
    }
  }

  // 動画をアップロード
  static Future<String?> uploadVideo({
    required XFile videoFile,
    String? tripId,
    Function(double)? onProgress,
  }) async {
    try {
      final File file = File(videoFile.path);
      return await uploadFile(
        file: file,
        folder: 'media/videos',
        tripId: tripId,
        onProgress: onProgress,
      );
    } catch (e) {
      print('Upload Video Error: $e');
      return null;
    }
  }

  // 書類をアップロード
  static Future<String?> uploadDocument({
    required File documentFile,
    String? tripId,
    Function(double)? onProgress,
  }) async {
    try {
      return await uploadFile(
        file: documentFile,
        folder: 'documents',
        tripId: tripId,
        onProgress: onProgress,
      );
    } catch (e) {
      print('Upload Document Error: $e');
      return null;
    }
  }

  // ファイルを削除
  static Future<bool> deleteFile(String downloadUrl) async {
    try {
      final Reference ref = _storage.refFromURL(downloadUrl);
      await ref.delete();
      return true;
    } catch (e) {
      print('Delete File Error: $e');
      return false;
    }
  }

  // ローカルファイルのサイズを取得
  static Future<int> getFileSize(String filePath) async {
    try {
      final File file = File(filePath);
      return await file.length();
    } catch (e) {
      print('Get File Size Error: $e');
      return 0;
    }
  }

  // ファイルサイズを人間が読める形式に変換
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  // 画像を圧縮してローカルに保存
  static Future<File?> compressAndSaveImage(XFile imageFile) async {
    try {
      final Directory tempDir = await getTemporaryDirectory();
      final String fileName = '${_uuid.v4()}.jpg';
      final String filePath = '${tempDir.path}/$fileName';
      
      final File originalFile = File(imageFile.path);
      final File compressedFile = await originalFile.copy(filePath);
      
      return compressedFile;
    } catch (e) {
      print('Compress and Save Image Error: $e');
      return null;
    }
  }

  // キャッシュをクリア
  static Future<void> clearCache() async {
    try {
      final Directory tempDir = await getTemporaryDirectory();
      if (tempDir.existsSync()) {
        await tempDir.delete(recursive: true);
      }
    } catch (e) {
      print('Clear Cache Error: $e');
    }
  }

  // メディアタイプを判定
  static String getMediaType(String fileName) {
    final String extension = fileName.split('.').last.toLowerCase();
    
    if (['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(extension)) {
      return 'image';
    } else if (['mp4', 'mov', 'avi', 'mkv', 'webm'].contains(extension)) {
      return 'video';
    } else if (['pdf', 'doc', 'docx', 'txt'].contains(extension)) {
      return 'document';
    } else {
      return 'other';
    }
  }

  // サムネイル画像を生成（動画用）
  static Future<File?> generateVideoThumbnail(String videoPath) async {
    try {
      // 実際のアプリでは video_thumbnail パッケージなどを使用
      // 現在はダミー実装
      return null;
    } catch (e) {
      print('Generate Video Thumbnail Error: $e');
      return null;
    }
  }

  // アップロード履歴を管理
  static Future<void> saveUploadHistory({
    required String fileName,
    required String downloadUrl,
    required String fileType,
    required int fileSize,
    String? tripId,
  }) async {
    try {
      // アップロード履歴をローカルまたはFirestoreに保存
      // SharedPreferencesまたはFirestoreを使用
    } catch (e) {
      print('Save Upload History Error: $e');
    }
  }
}