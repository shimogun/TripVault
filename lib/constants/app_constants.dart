class AppConstants {
  static const String appName = 'TripVault';
  static const String appVersion = '1.0.0';
  
  // Firebase collections
  static const String tripsCollection = 'trips';
  static const String usersCollection = 'users';
  static const String activitiesCollection = 'activities';
  static const String packingItemsCollection = 'packingItems';
  static const String documentsCollection = 'documents';
  static const String mediaCollection = 'media';
  
  // Local storage keys
  static const String userPrefsKey = 'user_preferences';
  static const String themeKey = 'app_theme';
  static const String languageKey = 'app_language';
  
  // Default values
  static const String defaultTripId = 'default_trip';
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const int maxVideoSize = 50 * 1024 * 1024; // 50MB
}

class AppStrings {
  // Navigation labels
  static const String itineraryTab = '旅行プラン';
  static const String documentsTab = '旅行書類';
  static const String mapTab = '地図';
  static const String mediaTab = '写真・動画';
  static const String settingsTab = '設定';
  
  // Common actions
  static const String add = '追加';
  static const String edit = '編集';
  static const String delete = '削除';
  static const String save = '保存';
  static const String cancel = 'キャンセル';
  static const String confirm = '確認';
  
  // Status messages
  static const String loading = '読み込み中...';
  static const String error = 'エラーが発生しました';
  static const String noData = 'データがありません';
  static const String offline = 'オフライン';
  static const String syncing = '同期中...';
}