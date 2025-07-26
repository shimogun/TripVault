# TripVault - Firebase & Google Maps 設定手順

この手順書に従って、TripVaultアプリの本番環境設定を行います。

## 🔥 **ステップ1: Firebase Console プロジェクト作成**

### 1.1 Firebase Console にアクセス
```
1. ブラウザで https://console.firebase.google.com/ を開く
2. Googleアカウントでログイン
3. 「プロジェクトを追加」をクリック
```

### 1.2 プロジェクト基本設定
```
プロジェクト名: TripVault
プロジェクトID: tripvault-[ランダム文字列] (自動生成)
```

### 1.3 Google Analytics 設定
```
✅ 「このプロジェクトでGoogle Analyticsを有効にする」にチェック
→ 「続行」をクリック

Analytics アカウント: 「Default Account for Firebase」を選択
→ 「プロジェクトを作成」をクリック
```

### 1.4 プロジェクト作成完了
```
数分でプロジェクトが作成されます
→ 「続行」をクリックしてFirebase Console メイン画面へ
```

## 📱 **ステップ2: Android アプリの追加**

### 2.1 Android アプリ登録
```
1. Firebase Console メイン画面で「Android」アイコンをクリック
2. 以下の情報を入力:

Android パッケージ名: com.example.trip_vault
アプリのニックネーム: TripVault Android
デバッグ用署名証明書 SHA-1: [開発時は空欄でOK]

→ 「アプリを登録」をクリック
```

### 2.2 google-services.json をダウンロード
```
1. 「google-services.json をダウンロード」をクリック
2. ダウンロードしたファイルを以下に配置:
   /Users/a/TripVault/android/app/google-services.json

⚠️ 重要: このファイルは必ず android/app/ ディレクトリに配置してください
```

### 2.3 Firebase SDK 設定
```
既にpubspec.yamlに設定済みなので、この手順はスキップ
→ 「次へ」をクリック
→ 「コンソールに進む」をクリック
```

## 🔧 **ステップ3: Firebase サービス有効化**

### 3.1 Authentication 有効化
```
1. 左サイドバー「Authentication」をクリック
2. 「始める」をクリック
3. 「Sign-in method」タブをクリック
4. 以下のプロバイダを有効化:

【Google】
- 「Google」をクリック
- 「有効にする」をON
- プロジェクトのサポート メール: [あなたのGmailアドレス]
- 「保存」をクリック

【メール/パスワード】  
- 「メール/パスワード」をクリック
- 「有効にする」をON
- 「保存」をクリック
```

### 3.2 Firestore Database 有効化
```
1. 左サイドバー「Firestore Database」をクリック
2. 「データベースの作成」をクリック
3. セキュリティルール: 「テストモードで開始」を選択
   → 「次へ」をクリック
4. ロケーション: 「asia-northeast1 (Tokyo)」を選択
   → 「完了」をクリック
```

### 3.3 Storage 有効化
```
1. 左サイドバー「Storage」をクリック
2. 「始める」をクリック
3. セキュリティルール: 「テストモードで開始」を選択
   → 「次へ」をクリック
4. ロケーション: 「asia-northeast1 (Tokyo)」を選択
   → 「完了」をクリック
```

## 🗺️ **ステップ4: Google Maps API 設定**

### 4.1 Google Cloud Console アクセス
```
1. https://console.cloud.google.com/ を開く
2. 同じGoogleアカウントでログイン
3. 上部のプロジェクト選択で「TripVault」を選択
```

### 4.2 Maps API 有効化
```
1. 左サイドバー「APIとサービス」→「ライブラリ」をクリック
2. 以下のAPIを検索して有効化:

【Maps SDK for Android】
- 検索: "Maps SDK for Android"
- 「Maps SDK for Android」をクリック
- 「有効にする」をクリック

【Places API】
- 検索: "Places API"  
- 「Places API」をクリック
- 「有効にする」をクリック

【Geocoding API】
- 検索: "Geocoding API"
- 「Geocoding API」をクリック  
- 「有効にする」をクリック
```

### 4.3 API キー作成
```
1. 左サイドバー「APIとサービス」→「認証情報」をクリック
2. 「+ 認証情報を作成」→「APIキー」をクリック
3. APIキーが生成されます → 「コピー」をクリック
4. キーを安全な場所に保存

⚠️ 重要: このAPIキーは後で使用します
```

### 4.4 API キー制限設定
```
1. 作成されたAPIキーの「編集」をクリック
2. 「アプリケーションの制限」:
   - 「Androidアプリ」を選択
   - パッケージ名: com.example.trip_vault
   - SHA-1証明書フィンガープリント: [開発時は空欄でOK]

3. 「APIの制限」:
   - 「キーを制限」を選択
   - 以下をチェック:
     ✅ Maps SDK for Android
     ✅ Places API  
     ✅ Geocoding API

4. 「保存」をクリック
```

## ⚙️ **ステップ5: Flutter プロジェクト設定**

### 5.1 Firebase CLI インストール
```bash
# Node.js がインストールされていない場合
brew install node

# Firebase CLI インストール
npm install -g firebase-tools

# Firebase にログイン
firebase login
```

### 5.2 FlutterFire CLI インストール
```bash
# FlutterFire CLI インストール  
dart pub global activate flutterfire_cli

# PATHに追加（.zshrc または .bash_profile に追加）
export PATH="$PATH":"$HOME/.pub-cache/bin"
```

### 5.3 Firebase 設定ファイル生成
```bash
# TripVault プロジェクトディレクトリに移動
cd /Users/a/TripVault

# Firebase プロジェクトを初期化
firebase init

# 以下を選択:
# ◯ Firestore: Configure security rules and indexes files
# ◯ Storage: Configure a security rules file for Cloud Storage  
# ◯ Emulators: Set up local emulators

# FlutterFire 設定
flutterfire configure

# プロジェクト選択: TripVault を選択
# プラットフォーム: android を選択
```

### 5.4 firebase_options.dart が自動生成される
```dart
// lib/firebase_options.dart が作成されます
// このファイルにFirebaseの設定が含まれます
```

## 📱 **ステップ6: Android 設定ファイル更新**

### 6.1 AndroidManifest.xml に Google Maps API キー追加
```bash
# ファイル編集: android/app/src/main/AndroidManifest.xml
```

```xml
<application 内に以下を追加>

<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="[ステップ4.3で取得したAPIキー]" />
```

### 6.2 権限追加確認
```xml
<!-- 既に追加済みですが、確認してください -->
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

## 🚀 **ステップ7: アプリ起動テスト**

### 7.1 依存関係更新
```bash
cd /Users/a/TripVault
flutter clean
flutter pub get
```

### 7.2 アプリ起動
```bash
flutter run -d emulator-5554
```

### 7.3 機能テスト
```
✅ アプリが正常に起動する
✅ 設定タブでGoogleログインが機能する  
✅ 地図タブで地図が表示される
✅ 写真タブで画像選択ができる
✅ 旅行プランが保存される
```

## 🔐 **ステップ8: セキュリティルール設定（本番用）**

### 8.1 Firestore セキュリティルール
```javascript
// Firebase Console → Firestore Database → ルール
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

### 8.2 Storage セキュリティルール
```javascript  
// Firebase Console → Storage → ルール
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /trips/{userId}/{tripId}/{allPaths=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

## ✅ **設定完了チェックリスト**

### Firebase 設定
- [ ] Firebase プロジェクト作成完了
- [ ] google-services.json 配置完了  
- [ ] Authentication (Google・メール) 有効化
- [ ] Firestore Database 作成完了
- [ ] Storage 設定完了

### Google Maps 設定
- [ ] Maps SDK for Android 有効化
- [ ] Places API 有効化
- [ ] Geocoding API 有効化  
- [ ] APIキー作成・制限設定完了
- [ ] AndroidManifest.xml にAPIキー追加

### Flutter 設定
- [ ] Firebase CLI インストール
- [ ] FlutterFire CLI インストール
- [ ] firebase_options.dart 生成完了
- [ ] アプリ起動テスト成功

## 🎉 **設定完了！**

すべての手順が完了すると、TripVaultアプリは完全に機能する本格的な旅行管理アプリとして動作します！

**次回からは `flutter run` だけでアプリが起動できます** 🚀