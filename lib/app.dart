import 'package:flutter/material.dart';
import 'constants/app_constants.dart';
import 'constants/app_theme.dart';
import 'screens/main_screen.dart';

class TripVaultApp extends StatelessWidget {
  const TripVaultApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}