import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import 'itinerary_screen.dart';
import 'documents_screen.dart';
import 'map_screen.dart';
import 'media_screen.dart';
import 'settings_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const ItineraryScreen(),
    const DocumentsScreen(),
    const MapScreen(),
    const MediaScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.security, color: Colors.blue),
            SizedBox(width: 8),
            Text(AppConstants.appName),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: const Row(
              children: [
                Icon(Icons.people, size: 18, color: Colors.grey),
                SizedBox(width: 4),
                Text('4名参加', style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: AppStrings.itineraryTab,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.description),
            label: AppStrings.documentsTab,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: AppStrings.mapTab,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.photo_camera),
            label: AppStrings.mediaTab,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: AppStrings.settingsTab,
          ),
        ],
      ),
    );
  }
}