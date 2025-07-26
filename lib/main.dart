import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'services/notification_service.dart';
import 'services/offline_service.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Firebase初期化
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    // バックグラウンドメッセージハンドラーを設定
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    
    // 通知サービス初期化
    await NotificationService.initialize();
    
    // オフラインサービス初期化
    await OfflineService().initialize();
  } catch (e) {
    print('Firebase initialization error: $e');
    // 開発中はFirebaseなしでも動作するように
  }
  
  runApp(const TripVaultApp());
}

// バックグラウンドメッセージハンドラー
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  print('バックグラウンドメッセージ受信: ${message.messageId}');
}