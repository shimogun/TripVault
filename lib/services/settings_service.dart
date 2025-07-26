import 'package:shared_preferences/shared_preferences.dart';
import 'firestore_service.dart';

class SettingsService {
  // SharedPreferencesのキー
  static const String _keyDarkMode = 'dark_mode';
  static const String _keyLanguage = 'language';
  static const String _keyCurrency = 'currency';
  static const String _keyTimezone = 'timezone';
  static const String _keyNotifications = 'notifications_enabled';
  static const String _keyAutoSync = 'auto_sync_enabled';
  static const String _keyFirstLaunch = 'first_launch';

  // 設定値をローカルに保存
  static Future<void> setBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
    
    // ログイン済みの場合はクラウドにも同期
    await _syncToCloud(key, value);
  }

  static Future<void> setString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
    
    // ログイン済みの場合はクラウドにも同期
    await _syncToCloud(key, value);
  }

  static Future<void> setInt(String key, int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(key, value);
    
    // ログイン済みの場合はクラウドにも同期
    await _syncToCloud(key, value);
  }

  // 設定値をローカルから取得
  static Future<bool> getBool(String key, {bool defaultValue = false}) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key) ?? defaultValue;
  }

  static Future<String> getString(String key, {String defaultValue = ''}) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key) ?? defaultValue;
  }

  static Future<int> getInt(String key, {int defaultValue = 0}) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(key) ?? defaultValue;
  }

  // 特定の設定項目用のメソッド

  // ダークモード
  static Future<void> setDarkMode(bool enabled) async {
    await setBool(_keyDarkMode, enabled);
  }

  static Future<bool> isDarkMode() async {
    return await getBool(_keyDarkMode);
  }

  // 言語設定
  static Future<void> setLanguage(String language) async {
    await setString(_keyLanguage, language);
  }

  static Future<String> getLanguage() async {
    return await getString(_keyLanguage, defaultValue: '日本語');
  }

  // 通貨設定
  static Future<void> setCurrency(String currency) async {
    await setString(_keyCurrency, currency);
  }

  static Future<String> getCurrency() async {
    return await getString(_keyCurrency, defaultValue: 'JPY');
  }

  // タイムゾーン設定
  static Future<void> setTimezone(String timezone) async {
    await setString(_keyTimezone, timezone);
  }

  static Future<String> getTimezone() async {
    return await getString(_keyTimezone, defaultValue: 'Asia/Tokyo');
  }

  // 通知設定
  static Future<void> setNotificationsEnabled(bool enabled) async {
    await setBool(_keyNotifications, enabled);
  }

  static Future<bool> isNotificationsEnabled() async {
    return await getBool(_keyNotifications, defaultValue: true);
  }

  // 自動同期設定
  static Future<void> setAutoSyncEnabled(bool enabled) async {
    await setBool(_keyAutoSync, enabled);
  }

  static Future<bool> isAutoSyncEnabled() async {
    return await getBool(_keyAutoSync, defaultValue: true);
  }

  // 初回起動フラグ
  static Future<void> setFirstLaunch(bool isFirst) async {
    await setBool(_keyFirstLaunch, isFirst);
  }

  static Future<bool> isFirstLaunch() async {
    return await getBool(_keyFirstLaunch, defaultValue: true);
  }

  // 全設定をエクスポート
  static Future<Map<String, dynamic>> exportSettings() async {
    return {
      'darkMode': await isDarkMode(),
      'language': await getLanguage(),
      'currency': await getCurrency(),
      'timezone': await getTimezone(),
      'notificationsEnabled': await isNotificationsEnabled(),
      'autoSyncEnabled': await isAutoSyncEnabled(),
    };
  }

  // 設定をインポート
  static Future<void> importSettings(Map<String, dynamic> settings) async {
    if (settings.containsKey('darkMode')) {
      await setDarkMode(settings['darkMode']);
    }
    if (settings.containsKey('language')) {
      await setLanguage(settings['language']);
    }
    if (settings.containsKey('currency')) {
      await setCurrency(settings['currency']);
    }
    if (settings.containsKey('timezone')) {
      await setTimezone(settings['timezone']);
    }
    if (settings.containsKey('notificationsEnabled')) {
      await setNotificationsEnabled(settings['notificationsEnabled']);
    }
    if (settings.containsKey('autoSyncEnabled')) {
      await setAutoSyncEnabled(settings['autoSyncEnabled']);
    }
  }

  // クラウドから設定を同期
  static Future<void> syncFromCloud() async {
    try {
      final doc = await FirestoreService.getUserPreferences();
      if (doc != null && doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        await importSettings(data);
      }
    } catch (e) {
      print('Sync From Cloud Error: $e');
    }
  }

  // クラウドに設定を同期
  static Future<void> _syncToCloud(String key, dynamic value) async {
    try {
      final settings = await exportSettings();
      await FirestoreService.saveUserPreferences(settings);
    } catch (e) {
      print('Sync To Cloud Error: $e');
    }
  }

  // 設定をリセット
  static Future<void> resetSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // キャッシュサイズを取得
  static Future<String> getCacheSize() async {
    try {
      // 実際のキャッシュサイズを計算
      // path_providerとdartのFileクラスを使用して計算
      return '0 MB'; // プレースホルダー
    } catch (e) {
      return '不明';
    }
  }

  // キャッシュをクリア
  static Future<void> clearCache() async {
    try {
      // アプリのキャッシュをクリア
      // ストレージサービスのclearCacheメソッドを呼び出し
    } catch (e) {
      print('Clear Cache Error: $e');
    }
  }

  // アプリのバージョン情報を取得
  static Future<Map<String, String>> getAppInfo() async {
    try {
      // package_info_plusパッケージを使用してアプリ情報を取得
      return {
        'version': '1.0.0',
        'buildNumber': '1',
        'packageName': 'com.example.trip_vault',
      };
    } catch (e) {
      return {
        'version': '不明',
        'buildNumber': '不明',
        'packageName': '不明',
      };
    }
  }

  // デバッグ情報を取得
  static Future<Map<String, dynamic>> getDebugInfo() async {
    return {
      'settings': await exportSettings(),
      'appInfo': await getAppInfo(),
      'cacheSize': await getCacheSize(),
    };
  }
}