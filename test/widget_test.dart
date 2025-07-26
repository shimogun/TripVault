import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:trip_vault/main.dart';

void main() {
  group('TripVault App Tests', () {
    testWidgets('基本的なUI要素が表示されることを確認', (WidgetTester tester) async {
      // アプリを構築してフレームをトリガー
      await tester.pumpWidget(const TripVaultApp());

      // 基本的なテキストが表示されることを確認
      expect(find.text('TripVaultへようこそ！'), findsOneWidget);
      expect(find.text('ボタンを押してください'), findsOneWidget);
      expect(find.text('0'), findsOneWidget);
    });

    testWidgets('カウンターボタンが正常に動作することを確認', (WidgetTester tester) async {
      // アプリを構築
      await tester.pumpWidget(const TripVaultApp());

      // 初期状態の確認
      expect(find.text('0'), findsOneWidget);
      expect(find.text('1'), findsNothing);

      // FloatingActionButtonをタップ
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      // カウンターが増加したことを確認
      expect(find.text('0'), findsNothing);
      expect(find.text('1'), findsOneWidget);
      expect(find.text('ボタンが 1 回押されました！'), findsOneWidget);
    });

    testWidgets('リセットボタンが正常に動作することを確認', (WidgetTester tester) async {
      // アプリを構築
      await tester.pumpWidget(const TripVaultApp());

      // カウンターを増加
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();
      expect(find.text('1'), findsOneWidget);

      // リセットボタンをタップ
      await tester.tap(find.text('リセット'));
      await tester.pump();

      // カウンターがリセットされたことを確認
      expect(find.text('0'), findsOneWidget);
      expect(find.text('カウンターがリセットされました'), findsOneWidget);
    });
  });
}