import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  
  // 通知権限を要求
  static Future<bool> requestNotificationPermission() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    return settings.authorizationStatus == AuthorizationStatus.authorized ||
           settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  // FCMトークンを取得
  static Future<String?> getFCMToken() async {
    try {
      String? token = await _firebaseMessaging.getToken();
      print('FCM Token: $token');
      return token;
    } catch (e) {
      print('FCM Token取得エラー: $e');
      return null;
    }
  }

  // 通知サービスを初期化
  static Future<void> initialize() async {
    try {
      // タイムゾーンデータを初期化
      tz.initializeTimeZones();
      
      // 通知権限を要求
      bool hasPermission = await requestNotificationPermission();
      if (!hasPermission) {
        print('通知権限が拒否されました');
        return;
      }

      // ローカル通知を初期化
      await _initializeLocalNotifications();

      // FCMトークンを取得
      await getFCMToken();

      // フォアグラウンド通知リスナーを設定
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // バックグラウンド通知リスナーを設定
      FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);

      // アプリが終了状態から通知で開かれた場合を処理
      RemoteMessage? initialMessage = await _firebaseMessaging.getInitialMessage();
      if (initialMessage != null) {
        _handleBackgroundMessage(initialMessage);
      }

      // トークン更新リスナー
      _firebaseMessaging.onTokenRefresh.listen((String token) {
        print('FCM Token更新: $token');
        // ここでサーバーに新しいトークンを送信
      });

      print('通知サービス初期化完了');
    } catch (e) {
      print('通知サービス初期化エラー: $e');
    }
  }

  // ローカル通知を初期化
  static Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  // フォアグラウンドでの通知処理
  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    print('フォアグラウンド通知受信: ${message.notification?.title}');
    
    // ローカル通知として表示
    await _showLocalNotification(
      title: message.notification?.title ?? 'TripVault',
      body: message.notification?.body ?? '新しい通知があります',
      payload: message.data.toString(),
    );
  }

  // バックグラウンドでの通知処理
  static Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    print('バックグラウンド通知タップ: ${message.notification?.title}');
    
    // 通知の種類に応じて適切な画面に遷移
    String? type = message.data['type'];
    switch (type) {
      case 'trip_reminder':
        // 旅行プランタブに遷移
        break;
      case 'weather_update':
        // 地図タブに遷移
        break;
      case 'document_expiry':
        // 書類タブに遷移
        break;
      default:
        // ホーム画面を表示
        break;
    }
  }

  // ローカル通知を表示
  static Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'tripvault_channel',
      'TripVault通知',
      channelDescription: 'TripVaultアプリからの通知',
      importance: Importance.high,
      priority: Priority.high,
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }

  // 通知タップ時の処理
  static void _onNotificationTapped(NotificationResponse response) {
    print('通知がタップされました: ${response.payload}');
    // ここで適切な画面に遷移する処理を実装
  }

  // 旅行リマインダー通知をスケジュール
  static Future<void> scheduleTripReminder({
    required String tripName,
    required DateTime reminderTime,
    required String message,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'trip_reminder_channel',
      '旅行リマインダー',
      channelDescription: '旅行の準備や出発のリマインダー',
      importance: Importance.high,
      priority: Priority.high,
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _localNotifications.zonedSchedule(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      '🧳 $tripName',
      message,
      tz.TZDateTime.from(reminderTime, tz.local),
      platformChannelSpecifics,
      payload: 'trip_reminder:$tripName',
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // 即座に通知を送信（テスト用）
  static Future<void> sendTestNotification() async {
    await _showLocalNotification(
      title: '🎉 TripVault',
      body: 'プッシュ通知が正常に動作しています！',
      payload: 'test_notification',
    );
  }

  // 持ち物チェックリマインダー
  static Future<void> sendPackingReminder({
    required String tripName,
    required int uncheckedItems,
  }) async {
    await _showLocalNotification(
      title: '📦 持ち物チェック',
      body: '$tripName - まだ$uncheckedItems個の持ち物がチェックされていません',
      payload: 'packing_reminder:$tripName',
    );
  }

  // 書類有効期限通知
  static Future<void> sendDocumentExpiryNotification({
    required String documentName,
    required int daysUntilExpiry,
  }) async {
    String urgencyIcon = daysUntilExpiry <= 30 ? '⚠️' : '📄';
    
    await _showLocalNotification(
      title: '$urgencyIcon 書類有効期限',
      body: '$documentNameの有効期限まで$daysUntilExpiry日です',
      payload: 'document_expiry:$documentName',
    );
  }

  // 天気アラート通知
  static Future<void> sendWeatherAlert({
    required String location,
    required String weatherCondition,
  }) async {
    await _showLocalNotification(
      title: '🌤️ 天気アラート',
      body: '$location - $weatherCondition',
      payload: 'weather_alert:$location',
    );
  }

  // 通知設定を取得
  static Future<NotificationSettings> getNotificationSettings() async {
    return await _firebaseMessaging.getNotificationSettings();
  }

  // アプリバッジをクリア
  static Future<void> clearBadge() async {
    await _localNotifications.cancelAll();
  }
}