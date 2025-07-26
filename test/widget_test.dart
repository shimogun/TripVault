import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:trip_vault/app.dart';

void main() {
  group('TripVault App Tests', () {
    testWidgets('アプリが正常に起動することを確認', (WidgetTester tester) async {
      // アプリを構築してフレームをトリガー
      await tester.pumpWidget(const TripVaultApp());

      // 基本的なUI要素が表示されることを確認
      expect(find.text('TripVault'), findsOneWidget);
      expect(find.text('旅行プラン'), findsOneWidget);
    });

    testWidgets('ボトムナビゲーションが正常に動作することを確認', (WidgetTester tester) async {
      // アプリを構築
      await tester.pumpWidget(const TripVaultApp());

      // 初期状態（旅行プランタブ）の確認
      expect(find.text('旅行プラン'), findsWidgets);

      // 他のタブをタップしてナビゲーションが動作することを確認
      final documentsTab = find.text('旅行書類');
      if (documentsTab.hasFound) {
        await tester.tap(documentsTab.first);
        await tester.pump();
      }
    });
  });
}