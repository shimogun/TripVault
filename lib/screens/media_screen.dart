import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../constants/app_theme.dart';

class MediaScreen extends StatelessWidget {
  const MediaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.photo_camera,
              size: 64,
              color: AppTheme.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              AppStrings.mediaTab,
              style: AppTextStyles.h2,
            ),
            const SizedBox(height: 8),
            Text(
              '写真・動画管理機能（実装予定）',
              style: AppTextStyles.body2,
            ),
          ],
        ),
      ),
    );
  }
}