# TripVault - 実装ガイド

このドキュメントでは、TripVaultアプリの実際の本番環境での使用に向けた実装手順を説明します。

## 🚀 実装完了済み機能

### ✅ 完成した機能
1. **Firebase認証システム** - Googleログイン・メールログイン対応
2. **Firestore データベース** - 旅行データ、アクティビティ、持ち物リスト管理
3. **ファイルアップロード機能** - Firebase Storage統合
4. **地図サービス** - Google Maps API対応準備
5. **設定管理** - ローカル・クラウド同期対応

### 📦 追加されたパッケージ
- `firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_storage`
- `google_sign_in` - Google認証
- `google_maps_flutter`, `geolocator`, `geocoding` - 地図・位置情報
- `image_picker`, `cached_network_image` - 画像処理
- `shared_preferences` - ローカル設定保存
- `provider` - 状態管理

## 🔧 次に必要な設定

### 1. Firebase プロジェクト設定

1. **Firebase Console でプロジェクト作成**
   ```
   1. https://console.firebase.google.com/ にアクセス
   2. 「プロジェクトを追加」をクリック
   3. プロジェクト名: "TripVault" 
   4. Google Analytics を有効化
   ```

2. **Android アプリの追加**
   ```
   パッケージ名: com.example.trip_vault
   アプリのニックネーム: TripVault Android
   SHA-1 証明書フィンガープリント: (開発用は不要、本番時に追加)
   ```

3. **google-services.json のダウンロード**
   ```
   android/app/ ディレクトリに配置
   ```

4. **Firebase CLI 設定**
   ```bash
   npm install -g firebase-tools
   firebase login
   cd /path/to/TripVault
   firebase init
   flutterfire configure
   ```

### 2. Google Maps API 設定

1. **Google Cloud Console**
   ```
   1. https://console.cloud.google.com/ にアクセス
   2. Maps SDK for Android を有効化
   3. Maps SDK for iOS を有効化
   4. Places API を有効化
   5. Directions API を有効化
   ```

2. **APIキーの設定**
   ```
   android/app/src/main/AndroidManifest.xml に追加:
   <meta-data
       android:name="com.google.android.geo.API_KEY"
       android:value="YOUR_GOOGLE_MAPS_API_KEY"/>
   ```

### 3. 必要なファイル作成

**`lib/firebase_options.dart`** (flutterfire configure で自動生成)
```dart
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    // 自動生成される設定
  }
}
```

**`.env`** (環境変数)
```
GOOGLE_MAPS_API_KEY=your_api_key_here
FIREBASE_PROJECT_ID=your_project_id
```

### 4. 権限設定

**`android/app/src/main/AndroidManifest.xml`**
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
```

**`ios/Runner/Info.plist`**
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>このアプリは現在地を取得して近くの観光スポットを表示します</string>
<key>NSCameraUsageDescription</key>
<string>旅行の写真を撮影するためにカメラを使用します</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>旅行の写真をアップロードするために写真ライブラリにアクセスします</string>
```

## 🔄 データ構造

### Firestore コレクション設計

```
users/
  {userId}/
    - email: string
    - displayName: string
    - photoURL: string
    - createdAt: timestamp
    - preferences/
        settings/
          - darkMode: boolean
          - language: string
          - currency: string

trips/
  {tripId}/
    - userId: string
    - title: string
    - destination: string
    - startDate: timestamp
    - endDate: timestamp
    - activities/
        {activityId}/
          - time: string
          - activity: string
          - location: string
          - participants: array
          - completed: boolean
    - packingItems/
        {itemId}/
          - name: string
          - category: string
          - packed: boolean
    - documents/
        {documentId}/
          - type: string
          - title: string
          - fileUrl: string
          - status: string
    - media/
        {mediaId}/
          - type: string (image/video)
          - url: string
          - caption: string
          - author: string
```

## 🚀 デプロイ準備

### 1. Firebase Security Rules

**Firestore Rules**
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // ユーザーは自分のデータのみアクセス可能
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // 旅行データは作成者のみアクセス可能
    match /trips/{tripId} {
      allow read, write: if request.auth != null && 
        request.auth.uid == resource.data.userId;
    }
  }
}
```

**Storage Rules**
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /{allPaths=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

### 2. ビルド設定

**Android (release)**
```bash
flutter build apk --release
flutter build appbundle --release
```

**iOS**
```bash
flutter build ios --release
```

## 🧪 テスト

### 1. 単体テスト
```bash
flutter test
```

### 2. 統合テスト
```bash
flutter drive --target=test_driver/app.dart
```

## 📱 機能拡張案

### 今後追加できる機能
1. **リアルタイムチャット** - Firestore リアルタイム更新
2. **旅行の共有** - 複数ユーザーでの旅行計画共有
3. **支出管理** - 旅行費用の記録・分析
4. **天気情報** - Weather API 統合
5. **翻訳機能** - Google Translate API
6. **QRコード** - 書類のQRコード生成・読み取り
7. **バックアップ** - データの自動バックアップ
8. **ダークモード** - 完全なテーマ切り替え

## 🔐 セキュリティ考慮事項

1. **API キーの保護** - 環境変数を使用
2. **ユーザーデータの暗号化** - Firebase の暗号化機能を活用
3. **アクセス制御** - Firestore Security Rules の厳密な設定
4. **認証の強化** - 多要素認証の検討

## 📋 チェックリスト

### 本番リリース前の確認事項
- [ ] Firebase プロジェクト設定完了
- [ ] Google Maps API キー設定
- [ ] Firestore Security Rules 設定
- [ ] Firebase Storage Rules 設定
- [ ] Android/iOS 権限設定
- [ ] アプリアイコン・スプラッシュスクリーン設定
- [ ] Google Play/App Store 準備
- [ ] テスト実行（単体・統合・手動）
- [ ] パフォーマンステスト
- [ ] セキュリティ監査

TripVaultアプリの本格的な実装とデプロイの準備が整いました！🎉