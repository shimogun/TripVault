# TripVault

旅行管理のためのFlutterアプリケーション

## 概要

TripVaultは、iOS・Android両対応のマルチプラットフォームFlutterアプリです。
旅行の計画、記録、共有を効率的に行うためのアプリケーションとして開発しています。

## 開発環境

- **フレームワーク**: Flutter
- **言語**: Dart
- **対応プラットフォーム**: iOS, Android
- **開発環境**: Android Studio推奨

## 現在の実装状況

### ✅ 完了済み
- 基本的なプロジェクト構造の構築
- マルチプラットフォーム対応の設定
- シンプルなUI（ボタン + テキスト表示）
- setState()を使った基本的な状態管理
- 単体テストの実装

### 📋 今後の予定
- 画面遷移の実装
- データ保存（ローカル・クラウド）
- 外部API連携
- Riverpodによる状態管理の導入
- デザイン改善

## セットアップ手順

### 前提条件
- Flutter SDK (3.0.0以上)
- Android Studio
- Xcode (iOS開発時)

### 実行方法

1. **依存関係のインストール**
   ```bash
   flutter pub get
   ```

2. **Android実行**
   ```bash
   flutter run
   ```

3. **テスト実行**
   ```bash
   flutter test
   ```

## プロジェクト構造

```
trip_vault/
├── lib/
│   └── main.dart              # メインアプリケーション
├── android/                   # Android固有の設定
├── ios/                       # iOS固有の設定（今後追加）
├── test/
│   └── widget_test.dart       # ウィジェットテスト
├── pubspec.yaml              # 依存関係定義
└── README.md                 # このファイル
```

## 開発ガイドライン

- **コメント**: 理解しやすいよう適度にコメントを記載
- **状態管理**: 現在はsetState()、将来的にRiverpod導入予定
- **コード品質**: flutter_lintsを使用したコード品質管理
- **テスト**: 新機能追加時は対応するテストも作成

## ライセンス

このプロジェクトは開発中のものです。