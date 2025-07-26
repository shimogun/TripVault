import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'services/firebase_service.dart';
import 'services/maps_service.dart';
import 'services/notification_service.dart';
import 'services/offline_service.dart';
import 'services/document_service.dart';
import 'services/media_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Firebase初期化（実際の使用時にはfirebase_options.dartが必要）
  try {
    await Firebase.initializeApp();
    
    // バックグラウンドメッセージハンドラーを設定
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    
    // 通知サービス初期化
    await NotificationService.initialize();
    
    // オフラインサービス初期化
    await OfflineService().initialize();
  } catch (e) {
    print('Firebase initialization error: $e');
    // 開発中はFirebaseなしでも動作するように
  }
  
  runApp(const TripVaultApp());
}

// バックグラウンドメッセージハンドラー
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('バックグラウンドメッセージ受信: ${message.messageId}');
}

class TripVaultApp extends StatelessWidget {
  const TripVaultApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TripVault',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}

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
            Text('TripVault'),
          ],
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
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
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: '旅行プラン',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.description),
            label: '旅行書類',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: '地図',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.photo_camera),
            label: '写真・動画',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: '設定',
          ),
        ],
      ),
    );
  }
}

class TripDay {
  final int id;
  final String date;
  final String title;
  final List<TripActivity> activities;

  TripDay({
    required this.id,
    required this.date,
    required this.title,
    required this.activities,
  });
}

class TripActivity {
  final int id;
  final String time;
  final String activity;
  final String location;
  final List<String> participants;
  bool completed;

  TripActivity({
    required this.id,
    required this.time,
    required this.activity,
    required this.location,
    required this.participants,
    this.completed = false,
  });
}

class PackingItem {
  final int id;
  final String name;
  final String category;
  bool packed;

  PackingItem({
    required this.id,
    required this.name,
    required this.category,
    this.packed = false,
  });
}

class ItineraryScreen extends StatefulWidget {
  const ItineraryScreen({super.key});

  @override
  State<ItineraryScreen> createState() => _ItineraryScreenState();
}

class _ItineraryScreenState extends State<ItineraryScreen> {
  int? _editingDayId;
  String _newTime = '';
  String _newActivity = '';
  String _newLocation = '';
  String _selectedFilter = 'all'; // all, me, my_activities

  final List<String> _allMembers = ['あなた', 'メンバー2', 'メンバー3', 'メンバー4'];

  List<PackingItem> _packingItems = [
    PackingItem(id: 1, name: 'パスポート', category: '必需品'),
    PackingItem(id: 2, name: 'ビザ', category: '必需品'),
    PackingItem(id: 3, name: '航空券', category: '必需品'),
    PackingItem(id: 4, name: '現地通貨', category: '必需品'),
    PackingItem(id: 5, name: 'クレジットカード', category: '必需品'),
    PackingItem(id: 6, name: '海外旅行保険証', category: '必需品'),
    PackingItem(id: 7, name: 'Tシャツ (5枚)', category: '衣類'),
    PackingItem(id: 8, name: '下着 (5枚)', category: '衣類'),
    PackingItem(id: 9, name: '水着', category: '衣類'),
    PackingItem(id: 10, name: 'サンダル', category: '衣類'),
    PackingItem(id: 11, name: '帽子', category: '衣類'),
    PackingItem(id: 12, name: '日焼け止め', category: '日用品'),
    PackingItem(id: 13, name: '虫除けスプレー', category: '日用品'),
    PackingItem(id: 14, name: '薬', category: '日用品'),
    PackingItem(id: 15, name: 'カメラ', category: '電子機器'),
    PackingItem(id: 16, name: 'スマホ充電器', category: '電子機器'),
    PackingItem(id: 17, name: 'モバイルバッテリー', category: '電子機器'),
    PackingItem(id: 18, name: '変換プラグ', category: '電子機器'),
  ];

  List<TripDay> _tripDays = [
    TripDay(
      id: 1,
      date: '2026-03-15',
      title: 'バリ島到着',
      activities: [
        TripActivity(
          id: 1,
          time: '10:00',
          activity: 'デンパサール空港到着',
          location: 'デンパサール空港',
          participants: ['あなた', 'メンバー2', 'メンバー3', 'メンバー4'],
        ),
        TripActivity(
          id: 2,
          time: '12:00',
          activity: 'ホテルチェックイン',
          location: 'ウブド地区',
          participants: ['あなた', 'メンバー2', 'メンバー3', 'メンバー4'],
        ),
        TripActivity(
          id: 3,
          time: '15:00',
          activity: 'ウェルカムランチ',
          location: 'Bebek Bengil',
          participants: ['あなた', 'メンバー2', 'メンバー3', 'メンバー4'],
        ),
        TripActivity(
          id: 7,
          time: '17:00',
          activity: '個人でカフェ散策',
          location: 'ウブド中心街',
          participants: ['あなた'],
        ),
      ],
    ),
    TripDay(
      id: 2,
      date: '2026-03-16',
      title: 'ウブド観光',
      activities: [
        TripActivity(
          id: 4,
          time: '08:00',
          activity: 'テガララン棚田',
          location: 'Tegallalang Rice Terraces',
          participants: ['あなた', 'メンバー2', 'メンバー3', 'メンバー4'],
        ),
        TripActivity(
          id: 5,
          time: '11:00',
          activity: 'モンキーフォレスト',
          location: 'Sacred Monkey Forest',
          participants: ['あなた', 'メンバー3'],
        ),
        TripActivity(
          id: 8,
          time: '11:00',
          activity: 'スパ体験',
          location: 'Karsa Spa',
          participants: ['メンバー2', 'メンバー4'],
        ),
        TripActivity(
          id: 6,
          time: '18:00',
          activity: 'ケチャックダンス',
          location: 'Pura Dalem Taman Kaja',
          participants: ['あなた', 'メンバー2', 'メンバー3', 'メンバー4'],
        ),
        TripActivity(
          id: 9,
          time: '20:30',
          activity: '個人でナイトマーケット',
          location: 'ウブド市場',
          participants: ['あなた'],
        ),
      ],
    ),
  ];

  List<TripDay> get _filteredTripDays {
    List<TripDay> filteredDays = [];
    
    for (TripDay day in _tripDays) {
      List<TripActivity> filteredActivities = [];
      
      for (TripActivity activity in day.activities) {
        bool shouldInclude = false;
        
        switch (_selectedFilter) {
          case 'all':
            shouldInclude = true;
            break;
          case 'me':
            shouldInclude = activity.participants.contains('あなた');
            break;
          case 'group':
            shouldInclude = activity.participants.length > 1;
            break;
        }
        
        if (shouldInclude) {
          filteredActivities.add(activity);
        }
      }
      
      if (filteredActivities.isNotEmpty) {
        filteredDays.add(TripDay(
          id: day.id,
          date: day.date,
          title: day.title,
          activities: filteredActivities,
        ));
      }
    }
    
    return filteredDays;
  }

  Color _getMemberColor(String member) {
    switch (member) {
      case 'あなた':
        return Colors.blue;
      case 'メンバー2':
        return Colors.green;
      case 'メンバー3':
        return Colors.purple;
      case 'メンバー4':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  void _addActivity(int dayId) {
    if (_newTime.isNotEmpty && _newActivity.isNotEmpty) {
      setState(() {
        final dayIndex = _tripDays.indexWhere((day) => day.id == dayId);
        if (dayIndex != -1) {
          _tripDays[dayIndex].activities.add(
            TripActivity(
              id: DateTime.now().millisecondsSinceEpoch,
              time: _newTime,
              activity: _newActivity,
              location: _newLocation,
              participants: ['あなた'], // デフォルトで自分のみ参加
            ),
          );
        }
        _newTime = '';
        _newActivity = '';
        _newLocation = '';
        _editingDayId = null;
      });
    }
  }

  void _toggleActivityComplete(int dayId, int activityId) {
    setState(() {
      final dayIndex = _tripDays.indexWhere((day) => day.id == dayId);
      if (dayIndex != -1) {
        final activityIndex = _tripDays[dayIndex]
            .activities
            .indexWhere((activity) => activity.id == activityId);
        if (activityIndex != -1) {
          _tripDays[dayIndex].activities[activityIndex].completed =
              !_tripDays[dayIndex].activities[activityIndex].completed;
        }
      }
    });
  }

  void _togglePackingItem(int itemId) {
    setState(() {
      final itemIndex = _packingItems.indexWhere((item) => item.id == itemId);
      if (itemIndex != -1) {
        _packingItems[itemIndex].packed = !_packingItems[itemIndex].packed;
      }
    });
  }

  Map<String, List<PackingItem>> get _groupedPackingItems {
    Map<String, List<PackingItem>> grouped = {};
    for (var item in _packingItems) {
      if (!grouped.containsKey(item.category)) {
        grouped[item.category] = [];
      }
      grouped[item.category]!.add(item);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue[50],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '旅行プラン',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.flight, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    const Text(
                      '2026年3月15日〜18日',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(width: 16),
                    const Icon(Icons.attach_money, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    const Text(
                      '予算: ¥200,000/人',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Text(
                  '表示フィルタ:',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedFilter,
                        isExpanded: true,
                        icon: const Icon(Icons.arrow_drop_down),
                        items: const [
                          DropdownMenuItem(
                            value: 'all',
                            child: Row(
                              children: [
                                Icon(Icons.groups, size: 16),
                                SizedBox(width: 8),
                                Text('全員の旅程'),
                              ],
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'me',
                            child: Row(
                              children: [
                                Icon(Icons.person, size: 16),
                                SizedBox(width: 8),
                                Text('自分の参加旅程'),
                              ],
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'group',
                            child: Row(
                              children: [
                                Icon(Icons.group, size: 16),
                                SizedBox(width: 8),
                                Text('グループ行動'),
                              ],
                            ),
                          ),
                        ],
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _selectedFilter = newValue;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  ListView.builder(
                    padding: const EdgeInsets.all(16),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _filteredTripDays.length,
                    itemBuilder: (context, index) {
                final day = _filteredTripDays[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              day.title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              day.date,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ...day.activities.map((activity) => Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 50,
                                    child: Text(
                                      activity.time,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.blue,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          activity.activity,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            decoration: activity.completed
                                                ? TextDecoration.lineThrough
                                                : null,
                                          ),
                                        ),
                                        if (activity.location.isNotEmpty)
                                          Row(
                                            children: [
                                              const Icon(Icons.location_on,
                                                  size: 12, color: Colors.grey),
                                              const SizedBox(width: 4),
                                              Expanded(
                                                child: Text(
                                                  activity.location,
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Icon(Icons.people,
                                                size: 12, color: Colors.grey),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: Wrap(
                                                spacing: 4,
                                                children: activity.participants.map((member) =>
                                                  Container(
                                                    width: 16,
                                                    height: 16,
                                                    decoration: BoxDecoration(
                                                      color: _getMemberColor(member),
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: Center(
                                                      child: Text(
                                                        member.substring(0, 1),
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 8,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ).toList(),
                                              ),
                                            ),
                                            Text(
                                              '${activity.participants.length}名',
                                              style: const TextStyle(
                                                fontSize: 10,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Checkbox(
                                    value: activity.completed,
                                    onChanged: (value) {
                                      _toggleActivityComplete(
                                          day.id, activity.id);
                                    },
                                  ),
                                ],
                              ),
                            )),
                        if (_editingDayId == day.id) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: TextFormField(
                                        decoration: const InputDecoration(
                                          labelText: '時間',
                                          hintText: '10:00',
                                          border: OutlineInputBorder(),
                                          contentPadding: EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 8),
                                        ),
                                        onChanged: (value) => _newTime = value,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      flex: 3,
                                      child: TextFormField(
                                        decoration: const InputDecoration(
                                          labelText: 'アクティビティ',
                                          border: OutlineInputBorder(),
                                          contentPadding: EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 8),
                                        ),
                                        onChanged: (value) =>
                                            _newActivity = value,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  decoration: const InputDecoration(
                                    labelText: '場所（任意）',
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 8),
                                  ),
                                  onChanged: (value) => _newLocation = value,
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    ElevatedButton(
                                      onPressed: () => _addActivity(day.id),
                                      child: const Text('追加'),
                                    ),
                                    const SizedBox(width: 8),
                                    TextButton(
                                      onPressed: () {
                                        setState(() {
                                          _editingDayId = null;
                                          _newTime = '';
                                          _newActivity = '';
                                          _newLocation = '';
                                        });
                                      },
                                      child: const Text('キャンセル'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ] else ...[
                          const SizedBox(height: 8),
                          TextButton.icon(
                            onPressed: () {
                              setState(() {
                                _editingDayId = day.id;
                              });
                            },
                            icon: const Icon(Icons.add, size: 16),
                            label: const Text('アクティビティを追加'),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.blue,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
                    },
                  ),
                          Container(
                    margin: const EdgeInsets.all(16),
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.luggage, color: Colors.blue),
                                const SizedBox(width: 8),
                                const Text(
                                  '持ち物チェック',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.blue[50],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${_packingItems.where((item) => item.packed).length}/${_packingItems.length}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.blue[700],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            ..._groupedPackingItems.entries.map((entry) => [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Text(
                                  entry.key,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                              ...entry.value.map((item) => Container(
                                margin: const EdgeInsets.only(bottom: 4),
                                child: Row(
                                  children: [
                                    Checkbox(
                                      value: item.packed,
                                      onChanged: (value) => _togglePackingItem(item.id),
                                      activeColor: Colors.blue,
                                    ),
                                    Expanded(
                                      child: Text(
                                        item.name,
                                        style: TextStyle(
                                          fontSize: 14,
                                          decoration: item.packed ? TextDecoration.lineThrough : null,
                                          color: item.packed ? Colors.grey : Colors.black87,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                              const SizedBox(height: 8),
                            ]).expand((widget) => widget).toList(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

}

class TravelDocument {
  final int id;
  final String type;
  final String title;
  final String status;
  final String qrCode;
  final Map<String, String> details;
  final bool urgent;

  TravelDocument({
    required this.id,
    required this.type,
    required this.title,
    required this.status,
    required this.qrCode,
    required this.details,
    this.urgent = false,
  });
}

class AddDocumentDialog extends StatefulWidget {
  @override
  _AddDocumentDialogState createState() => _AddDocumentDialogState();
}

class _AddDocumentDialogState extends State<AddDocumentDialog> {
  final _formKey = GlobalKey<FormState>();
  String _selectedType = 'passport';
  String _title = '';
  String _description = '';
  DateTime? _expiryDate;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '書類を追加',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Document Type
                const Text(
                  '書類タイプ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedType,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: DocumentService.documentTypes.entries.map((entry) {
                    return DropdownMenuItem(
                      value: entry.key,
                      child: Row(
                        children: [
                          Icon(entry.value['icon'], color: entry.value['color']),
                          const SizedBox(width: 8),
                          Text(entry.value['name']),
                          if (entry.value['required'])
                            const Text(' *', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedType = value!);
                  },
                ),
                const SizedBox(height: 16),
                
                // Title
                const Text(
                  'タイトル',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: '例: インドネシア観光ビザ',
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'タイトルを入力してください';
                    }
                    return null;
                  },
                  onSaved: (value) => _title = value!,
                ),
                const SizedBox(height: 16),
                
                // Description
                const Text(
                  '説明（任意）',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: '書類の詳細や注意事項',
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  maxLines: 3,
                  onSaved: (value) => _description = value ?? '',
                ),
                const SizedBox(height: 16),
                
                // Expiry Date
                const Text(
                  '有効期限（任意）',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now().add(const Duration(days: 365)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 3650)),
                    );
                    if (date != null) {
                      setState(() => _expiryDate = date);
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _expiryDate != null
                          ? _expiryDate!.toIso8601String().substring(0, 10)
                          : '有効期限を選択',
                      style: TextStyle(
                        color: _expiryDate != null ? Colors.black : Colors.grey,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('キャンセル'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            Navigator.of(context).pop({
                              'type': _selectedType,
                              'title': _title,
                              'description': _description,
                              'expiryDate': _expiryDate,
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('ファイル選択'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key});

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  bool _isOffline = false;
  bool _isLoading = true;
  List<Map<String, dynamic>> _documents = [];
  Map<String, dynamic>? _completenessData;
  String _currentTripId = 'default_trip'; // In real app, get from trip selection
  String _currentUserId = 'default_user'; // In real app, get from authentication

  @override
  void initState() {
    super.initState();
    _loadDocuments();
    _monitorOfflineStatus();
  }

  void _loadDocuments() async {
    setState(() => _isLoading = true);
    
    try {
      // Try to load from Firestore first
      List<Map<String, dynamic>> documents = await DocumentService.getDocuments(_currentTripId);
      
      // If no documents online, try cached data
      if (documents.isEmpty && _isOffline) {
        documents = await DocumentService.getCachedDocuments(_currentTripId);
      }
      
      // Calculate completeness
      final completeness = DocumentService.calculateDocumentCompleteness(documents);
      
      // Cache documents locally
      await DocumentService.cacheDocumentsLocally(_currentTripId, documents);
      
      setState(() {
        _documents = documents;
        _completenessData = completeness;
        _isLoading = false;
      });
      
      // Check for expiring documents and send notifications
      final expiringDocs = DocumentService.checkExpiringDocuments(documents);
      for (var doc in expiringDocs) {
        if (doc['expiryDate'] != null) {
          DateTime expiryDate = DateTime.parse(doc['expiryDate']);
          int daysUntil = expiryDate.difference(DateTime.now()).inDays;
          
          await NotificationService.sendDocumentExpiryNotification(
            documentName: doc['title'],
            daysUntilExpiry: daysUntil,
          );
        }
      }
      
    } catch (e) {
      print('書類読み込みエラー: $e');
      setState(() => _isLoading = false);
    }
  }
  
  void _monitorOfflineStatus() {
    OfflineService().onlineStatusStream.listen((isOnline) {
      setState(() => _isOffline = !isOnline);
      if (isOnline) {
        _loadDocuments(); // Refresh when coming back online
      }
    });
  }

  Future<void> _addDocument() async {
    // 一時的にダミーデータを追加してUIをテスト
    setState(() => _isLoading = true);
    
    // ダミー書類データを追加
    final dummyDoc = {
      'id': 'dummy_${DateTime.now().millisecondsSinceEpoch}',
      'userId': _currentUserId,
      'tripId': _currentTripId,
      'type': 'passport',
      'title': 'テスト書類 - ${DateTime.now().hour}:${DateTime.now().minute}',
      'description': 'UIテスト用のダミー書類です',
      'fileName': 'test_document.pdf',
      'fileExtension': 'pdf',
      'fileUrl': 'https://example.com/test.pdf',
      'storagePath': 'documents/test/path',
      'expiryDate': DateTime.now().add(Duration(days: 30)).toIso8601String(),
      'uploadDate': DateTime.now().toIso8601String(),
      'status': 'active',
      'fileSize': 1024000,
    };
    
    setState(() {
      _documents.add(dummyDoc);
      _completenessData = DocumentService.calculateDocumentCompleteness(_documents);
      _isLoading = false;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('テスト書類「${dummyDoc['title']}」が追加されました')),
    );
  }

  void _showQRCode(Map<String, dynamic> document) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                document['title'],
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: DocumentService.generateQRCode(document, size: 200),
              ),
              const SizedBox(height: 16),
              const Text(
                '緊急時アクセス用QRコード',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('閉じる'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getDocumentStatus(Map<String, dynamic> document) {
    if (document['expiryDate'] == null) return 'valid';
    
    DateTime expiryDate = DateTime.parse(document['expiryDate']);
    DateTime now = DateTime.now();
    
    if (expiryDate.isBefore(now)) {
      return 'expired';
    } else if (expiryDate.difference(now).inDays <= 30) {
      return 'expiring_soon';
    } else {
      return 'valid';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'expired':
        return Colors.red;
      case 'expiring_soon':
        return Colors.orange;
      case 'valid':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'expired':
        return '期限切れ';
      case 'expiring_soon':
        return '期限間近';
      case 'valid':
        return '有効';
      default:
        return '不明';
    }
  }

  Widget _buildEmergencyChip(Map<String, dynamic> doc, String label) {
    final typeInfo = DocumentService.documentTypes[doc['type']];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.red[200]!),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            typeInfo?['icon'] ?? Icons.description,
            size: 14,
            color: Colors.red,
          ),
          const SizedBox(width: 4),
          Text(
            '${typeInfo?['name'] ?? doc['title']} ($label)',
            style: const TextStyle(
              fontSize: 10,
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentCard(Map<String, dynamic> document) {
    final typeInfo = DocumentService.documentTypes[document['type']];
    final status = _getDocumentStatus(document);
    final statusColor = _getStatusColor(status);
    final statusLabel = _getStatusLabel(status);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  typeInfo?['icon'] ?? Icons.description,
                  size: 32,
                  color: typeInfo?['color'] ?? Colors.grey,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        document['title'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              border: Border.all(
                                color: statusColor.withOpacity(0.3),
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              statusLabel,
                              style: TextStyle(
                                fontSize: 10,
                                color: statusColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            DocumentService.getFileTypeIcon(document['fileExtension'] ?? ''),
                            size: 16,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            DocumentService.formatFileSize(document['fileSize'] ?? 0),
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (document['description']?.isNotEmpty == true) ...[
              Text(
                document['description'],
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
            ],
            if (document['expiryDate'] != null) ...[
              Row(
                children: [
                  const Icon(Icons.schedule, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    '有効期限: ${document['expiryDate'].substring(0, 10)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // Open file URL in browser/external app
                      print('Opening: ${document['fileUrl']}');
                    },
                    icon: const Icon(Icons.download, size: 16),
                    label: const Text(
                      'ダウンロード',
                      style: TextStyle(fontSize: 12),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showQRCode(document),
                    icon: const Icon(Icons.qr_code, size: 16),
                    label: const Text(
                      'QR表示',
                      style: TextStyle(fontSize: 12),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[100],
                      foregroundColor: Colors.blue[700],
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.blue[50],
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            '旅行書類',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _isOffline ? Colors.grey[100] : Colors.green[100],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _isOffline ? Icons.wifi_off : Icons.wifi,
                                      size: 16,
                                      color: _isOffline ? Colors.grey : Colors.green,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      _isOffline ? 'オフライン' : 'オンライン',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: _isOffline ? Colors.grey : Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton.icon(
                                onPressed: _addDocument,
                                icon: const Icon(Icons.upload, size: 16),
                                label: const Text('書類追加', style: TextStyle(fontSize: 12)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      if (_completenessData != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blue[200]!),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '書類準備状況',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 8),
                              LinearProgressIndicator(
                                value: _completenessData!['completeness'].toDouble(),
                                backgroundColor: Colors.grey[300],
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  _completenessData!['completeness'] == 1.0 
                                      ? Colors.green 
                                      : Colors.orange,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '必須書類: ${_completenessData!['completedRequired']}/${_completenessData!['totalRequired']} 完了 (${(_completenessData!['completeness'] * 100).toStringAsFixed(0)}%)',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // Emergency Access and Expiring Documents Section
                if (_documents.isNotEmpty) ...[
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      border: Border.all(color: Colors.red[200]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.security, color: Colors.red, size: 20),
                            SizedBox(width: 8),
                            Text(
                              '緊急アクセス & 要注意書類',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: [
                            // Show expiring and expired documents
                            ...DocumentService.checkExpiringDocuments(_documents)
                                .map((doc) => _buildEmergencyChip(doc, '期限間近')),
                            ...DocumentService.checkExpiredDocuments(_documents)
                                .map((doc) => _buildEmergencyChip(doc, '期限切れ')),
                          ],
                        ),
                        if (DocumentService.checkExpiringDocuments(_documents).isEmpty &&
                            DocumentService.checkExpiredDocuments(_documents).isEmpty)
                          const Text(
                            '緊急対応が必要な書類はありません',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
                // Documents List
                Expanded(
                  child: _documents.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.description_outlined,
                                size: 64,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 16),
                              Text(
                                '書類がまだありません',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                '右上の「書類追加」ボタンから\n旅行書類をアップロードしてください',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _documents.length,
                          itemBuilder: (context, index) {
                            final doc = _documents[index];
                            return _buildDocumentCard(doc);
                          },
                        ),
                ),
              ],
            ),
    );
  }
}

class TouristSpot {
  final int id;
  final String name;
  final String type;
  final double rating;
  final String description;
  final String address;
  final String imageUrl;

  TouristSpot({
    required this.id,
    required this.name,
    required this.type,
    required this.rating,
    required this.description,
    required this.address,
    required this.imageUrl,
  });
}

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  String _selectedCategory = 'all';
  GoogleMapController? _mapController;
  LatLng? _currentLocation;
  bool _isLoadingLocation = false;
  
  final List<TouristSpot> _spots = [
    TouristSpot(
      id: 1,
      name: 'ウブド王宮',
      type: 'attraction',
      rating: 4.5,
      description: 'バリ島の伝統的な王宮。美しい建築と歴史を体感',
      address: 'Jl. Raya Ubud, Ubud',
      imageUrl: '',
    ),
    TouristSpot(
      id: 2,
      name: 'テガララン棚田',
      type: 'attraction',
      rating: 4.8,
      description: '美しい緑の棚田。インスタ映えスポットとして人気',
      address: 'Tegallalang, Gianyar Regency',
      imageUrl: '',
    ),
    TouristSpot(
      id: 3,
      name: 'タナロット寺院',
      type: 'temple',
      rating: 4.7,
      description: '海に浮かぶ神秘的な寺院。夕日の絶景スポット',
      address: 'Tabanan Regency, Bali',
      imageUrl: '',
    ),
    TouristSpot(
      id: 4,
      name: 'ウルワツ寺院',
      type: 'temple',
      rating: 4.6,
      description: '断崖絶壁の寺院。ケチャックダンスが有名',
      address: 'Pecatu, South Kuta, Badung Regency',
      imageUrl: '',
    ),
    TouristSpot(
      id: 5,
      name: 'クタビーチ',
      type: 'attraction',
      rating: 4.4,
      description: 'サーフィンと夕日で有名なビーチ',
      address: 'Kuta, Badung Regency, Bali',
      imageUrl: '',
    ),
    TouristSpot(
      id: 6,
      name: 'Sacred Monkey Forest',
      type: 'attraction',
      rating: 4.2,
      description: 'サルと触れ合える神聖な森。歴史ある寺院もある',
      address: 'Jl. Monkey Forest Rd, Ubud',
      imageUrl: '',
    ),
  ];

  List<TouristSpot> get _filteredSpots {
    if (_selectedCategory == 'all') {
      return _spots;
    }
    return _spots.where((spot) => spot.type == _selectedCategory).toList();
  }

  String _getTypeLabel(String type) {
    switch (type) {
      case 'restaurant':
        return 'レストラン';
      case 'attraction':
        return '観光地';
      case 'temple':
        return '寺院';
      case 'hotel':
        return 'ホテル';
      default:
        return 'その他';
    }
  }

  String _getTypeIcon(String type) {
    switch (type) {
      case 'restaurant':
        return '🍽️';
      case 'attraction':
        return '🏞️';
      case 'temple':
        return '🏛️';
      case 'hotel':
        return '🏨';
      default:
        return '📍';
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'restaurant':
        return Colors.orange;
      case 'attraction':
        return Colors.green;
      case 'temple':
        return Colors.purple;
      case 'hotel':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      final position = await MapsService.getCurrentLocation();
      if (position != null) {
        setState(() {
          _currentLocation = LatLng(position.latitude, position.longitude);
        });
        
        // 現在地にカメラを移動
        if (_mapController != null) {
          await _mapController!.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: _currentLocation!,
                zoom: 13.0,
              ),
            ),
          );
        }
      }
    } catch (e) {
      print('位置情報の取得に失敗しました: $e');
      // エラーダイアログを表示
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('位置情報エラー'),
            content: Text('位置情報の取得に失敗しました。設定で位置情報を有効にしてください。'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
        });
      }
    }
  }

  Set<Marker> _createTouristSpotMarkers() {
    return _filteredSpots.map((spot) {
      return Marker(
        markerId: MarkerId(spot.id.toString()),
        position: _getSpotLocation(spot),
        infoWindow: InfoWindow(
          title: spot.name,
          snippet: spot.description,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          _getMarkerColor(spot.type),
        ),
      );
    }).toSet();
  }

  LatLng _getSpotLocation(TouristSpot spot) {
    // バリ島の有名スポットの正確な座標
    switch (spot.id) {
      case 1: // ウブド王宮 (ウブド中心部)
        return const LatLng(-8.5069, 115.2625);
      case 2: // テガララン棚田 (ウブド北部)
        return const LatLng(-8.4355, 115.2784);
      case 3: // タナロット寺院 (西海岸)
        return const LatLng(-8.6211, 115.0864);
      case 4: // ウルワツ寺院 (南部半島)
        return const LatLng(-8.8290, 115.0849);
      case 5: // クタビーチ (デンパサール南部)
        return const LatLng(-8.7188, 115.1691);
      case 6: // Sacred Monkey Forest (ウブド)
        return const LatLng(-8.5185, 115.2591);
      default:
        return const LatLng(-8.3405, 115.0920); // デンパサール中心部
    }
  }

  double _getMarkerColor(String type) {
    switch (type) {
      case 'restaurant':
        return BitmapDescriptor.hueOrange;
      case 'attraction':
        return BitmapDescriptor.hueGreen;
      case 'temple':
        return BitmapDescriptor.hueViolet;
      case 'hotel':
        return BitmapDescriptor.hueBlue;
      default:
        return BitmapDescriptor.hueRed;
    }
  }

  void _showSpotDetails(TouristSpot spot) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(spot.name),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.star, color: Colors.amber, size: 16),
                  SizedBox(width: 4),
                  Text('${spot.rating}', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              SizedBox(height: 8),
              Text('カテゴリ: ${_getTypeLabel(spot.type)}'),
              SizedBox(height: 8),
              Text(spot.description),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.location_on, color: Colors.red, size: 16),
                  SizedBox(width: 4),
                  Expanded(child: Text(spot.address, style: TextStyle(fontSize: 12))),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('閉じる'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _focusOnSpot(spot);
              },
              child: Text('地図で表示'),
            ),
          ],
        );
      },
    );
  }

  void _focusOnSpot(TouristSpot spot) {
    if (_mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: _getSpotLocation(spot),
            zoom: 15.0,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue[50],
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '地図とスポット',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'バリ島の観光スポットとルートを確認',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.all(16),
            height: 300,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: const CameraPosition(
                    target: LatLng(-8.3405, 115.0920), // バリ島の座標
                    zoom: 11.0,
                  ),
                  markers: _createTouristSpotMarkers(),
                  onMapCreated: (GoogleMapController controller) {
                    _mapController = controller;
                    // マップ作成後に現在地があれば移動
                    if (_currentLocation != null) {
                      controller.animateCamera(
                        CameraUpdate.newCameraPosition(
                          CameraPosition(
                            target: _currentLocation!,
                            zoom: 13.0,
                          ),
                        ),
                      );
                    }
                  },
                  mapType: MapType.normal,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false, // カスタムボタンを使用
                  zoomControlsEnabled: true,
                  scrollGesturesEnabled: true,
                  zoomGesturesEnabled: true,
                  rotateGesturesEnabled: true,
                  tiltGesturesEnabled: true,
                ),
                // 現在地ボタン
                Positioned(
                  top: 16,
                  right: 16,
                  child: FloatingActionButton(
                    mini: true,
                    onPressed: _isLoadingLocation ? null : _getCurrentLocation,
                    backgroundColor: Colors.white,
                    child: _isLoadingLocation
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(Icons.my_location, color: Colors.blue),
                  ),
                ),
                // ローディング表示
                if (_isLoadingLocation)
                  Container(
                    color: Colors.black12,
                    child: Center(
                      child: Card(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 8),
                              Text('現在地を取得中...'),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Text(
                  'カテゴリ:',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildCategoryChip('all', 'すべて', Icons.all_inclusive),
                        _buildCategoryChip('restaurant', 'レストラン', Icons.restaurant),
                        _buildCategoryChip('attraction', '観光地', Icons.landscape),
                        _buildCategoryChip('temple', '寺院', Icons.temple_buddhist),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filteredSpots.length,
              itemBuilder: (context, index) {
                final spot = _filteredSpots[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: _getTypeColor(spot.type).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _getTypeColor(spot.type).withOpacity(0.3),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              _getTypeIcon(spot.type),
                              style: const TextStyle(fontSize: 32),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      spot.name,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: _getTypeColor(spot.type).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      _getTypeLabel(spot.type),
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: _getTypeColor(spot.type),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.star, color: Colors.amber, size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    spot.rating.toString(),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                spot.description,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.location_on, 
                                      size: 12, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      spot.address,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () {},
                                      icon: const Icon(Icons.directions, size: 16),
                                      label: const Text(
                                        'ルート',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 6),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () => _showSpotDetails(spot),
                                      icon: const Icon(Icons.info_outline, size: 16),
                                      label: const Text(
                                        '詳細',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue[100],
                                        foregroundColor: Colors.blue[700],
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 6),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String category, String label, IconData icon) {
    final isSelected = _selectedCategory == category;
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isSelected,
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16),
            const SizedBox(width: 4),
            Text(label),
          ],
        ),
        onSelected: (selected) {
          setState(() {
            _selectedCategory = category;
          });
        },
        selectedColor: Colors.blue[100],
        checkmarkColor: Colors.blue,
      ),
    );
  }
}

class MediaItem {
  final int id;
  final String type;
  final String caption;
  final String author;
  final String timestamp;
  final Color authorColor;

  MediaItem({
    required this.id,
    required this.type,
    required this.caption,
    required this.author,
    required this.timestamp,
    required this.authorColor,
  });
}

class MediaScreen extends StatefulWidget {
  const MediaScreen({super.key});

  @override
  State<MediaScreen> createState() => _MediaScreenState();
}

class _MediaScreenState extends State<MediaScreen> {
  String _selectedAlbumType = 'all';
  bool _isLoading = true;
  bool _isOffline = false;
  List<Map<String, dynamic>> _mediaItems = [];
  Map<String, int> _albumStatistics = {};
  String _currentTripId = 'default_trip';
  String _currentUserId = 'default_user';

  @override
  void initState() {
    super.initState();
    _loadMedia();
    _monitorOfflineStatus();
  }

  void _loadMedia() async {
    setState(() => _isLoading = true);
    
    try {
      // メディア一覧を取得
      final mediaList = await MediaService.getTripMedia(
        _currentTripId, 
        albumType: _selectedAlbumType == 'all' ? null : _selectedAlbumType,
      );
      
      // キャッシュから取得（オフライン時）
      if (mediaList.isEmpty && _isOffline) {
        final cachedMedia = await MediaService.getCachedMedia(_currentTripId);
        setState(() {
          _mediaItems = _selectedAlbumType == 'all' 
              ? cachedMedia 
              : cachedMedia.where((m) => m['albumType'] == _selectedAlbumType).toList();
        });
      } else {
        // ローカルキャッシュ
        await MediaService.cacheMediaLocally(_currentTripId, mediaList);
        setState(() => _mediaItems = mediaList);
      }

      // 統計を取得
      final statistics = await MediaService.getAlbumStatistics(_currentTripId);
      setState(() {
        _albumStatistics = statistics;
        _isLoading = false;
      });

    } catch (e) {
      print('メディア読み込みエラー: $e');
      setState(() => _isLoading = false);
    }
  }

  void _monitorOfflineStatus() {
    OfflineService().onlineStatusStream.listen((isOnline) {
      setState(() => _isOffline = !isOnline);
      if (isOnline) {
        _loadMedia();
      }
    });
  }

  Future<void> _addMedia() async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => MediaSourceDialog(),
    );
    
    if (result != null) {
      setState(() => _isLoading = true);
      
      if (result == 'camera' || result == 'gallery') {
        final mediaFiles = await MediaService.pickMedia(source: result);
        
        if (mediaFiles != null && mediaFiles.isNotEmpty) {
          // 各ファイルをアップロード
          for (final file in mediaFiles) {
            final uploadResult = await MediaService.uploadMedia(
              userId: _currentUserId,
              tripId: _currentTripId,
              mediaFile: file,
              albumType: 'trip_moments',
              caption: '新しい思い出 - ${result == 'camera' ? 'カメラ撮影' : 'ギャラリー'}',
              takenAt: DateTime.now(),
            );
            
            if (uploadResult != null) {
              setState(() => _mediaItems.add(uploadResult));
            }
          }
          
          // 統計を再計算
          final statistics = await MediaService.getAlbumStatistics(_currentTripId);
          setState(() => _albumStatistics = statistics);
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${mediaFiles.length}件のメディアをアップロードしました')),
          );
        }
      }
      
      setState(() => _isLoading = false);
    }
  }

  void _showMediaDetail(Map<String, dynamic> media) {
    showDialog(
      context: context,
      builder: (context) => MediaDetailDialog(media: media),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // ヘッダー
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.blue[50],
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            '写真・動画',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _isOffline ? Colors.grey[100] : Colors.green[100],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _isOffline ? Icons.wifi_off : Icons.wifi,
                                      size: 16,
                                      color: _isOffline ? Colors.grey : Colors.green,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      _isOffline ? 'オフライン' : 'オンライン',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: _isOffline ? Colors.grey : Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton.icon(
                                onPressed: _addMedia,
                                icon: const Icon(Icons.camera_alt, size: 16),
                                label: const Text('アップロード', style: TextStyle(fontSize: 12)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.pink,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      if (_albumStatistics.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blue[200]!),
                          ),
                          child: Row(
                            children: [
                              _buildStatChip('合計', _albumStatistics['total'] ?? 0, Icons.photo_library, Colors.blue),
                              const SizedBox(width: 8),
                              _buildStatChip('写真', _albumStatistics['photos'] ?? 0, Icons.photo, Colors.pink),
                              const SizedBox(width: 8),
                              _buildStatChip('動画', _albumStatistics['videos'] ?? 0, Icons.videocam, Colors.purple),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // アルバムフィルター
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'アルバム',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 40,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: MediaService.albumTypes.length + 1,
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              return _buildAlbumChip('all', 'すべて', Icons.all_inclusive, Colors.grey);
                            }
                            final albumEntry = MediaService.albumTypes.entries.elementAt(index - 1);
                            final count = _albumStatistics[albumEntry.key] ?? 0;
                            return _buildAlbumChip(
                              albumEntry.key,
                              albumEntry.value['name'],
                              albumEntry.value['icon'],
                              albumEntry.value['color'],
                              count: count,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                // メディアグリッド
                Expanded(
                  child: _mediaItems.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.photo_library_outlined,
                                size: 64,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 16),
                              Text(
                                '写真・動画がまだありません',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                '右上の「アップロード」ボタンから\n旅行の思い出を追加してください',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: GridView.builder(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 0.8,
                            ),
                            itemCount: _mediaItems.length,
                            itemBuilder: (context, index) {
                              final media = _mediaItems[index];
                              return _buildMediaCard(media);
                            },
                          ),
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildMediaCard(Map<String, dynamic> media) {
    final albumType = MediaService.albumTypes[media['albumType']];
    
    return GestureDetector(
      onTap: () => _showMediaDetail(media),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // メディア画像
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                child: Stack(
                  children: [
                    MediaService.buildThumbnail(
                      imageUrl: media['thumbnailUrl'] ?? media['fileUrl'],
                      size: double.infinity,
                      isVideo: media['isVideo'] ?? false,
                    ),
                    // アルバムタイプバッジ
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: albumType?['color']?.withOpacity(0.8) ?? Colors.grey.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              albumType?['icon'] ?? Icons.photo,
                              size: 12,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              albumType?['name'] ?? 'その他',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // いいねボタン
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () {
                          // いいね機能の実装
                          MediaService.toggleLike(media['id'], true);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.favorite_border,
                                size: 12,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                '${media['likes'] ?? 0}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 8,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // キャプションエリア
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      media['caption'] ?? '無題',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          MediaService.getFileTypeIcon(media['fileExtension'] ?? ''),
                          size: 10,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          MediaService.formatFileSize(media['fileSize'] ?? 0),
                          style: const TextStyle(
                            fontSize: 9,
                            color: Colors.grey,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          DateTime.parse(media['takenAt']).day.toString() + '日',
                          style: const TextStyle(
                            fontSize: 9,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip(String label, int count, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            '$label: $count',
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlbumChip(String albumType, String label, IconData icon, Color color, {int count = 0}) {
    final isSelected = _selectedAlbumType == albumType;
    
    return GestureDetector(
      onTap: () {
        setState(() => _selectedAlbumType = albumType);
        _loadMedia();
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: color,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected ? Colors.white : color,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: isSelected ? Colors.white : color,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (count > 0) ...[
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white.withOpacity(0.3) : color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    fontSize: 9,
                    color: isSelected ? Colors.white : color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// メディアソース選択ダイアログ
class MediaSourceDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'メディアを追加',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop('camera'),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue[200]!),
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.camera_alt, size: 32, color: Colors.blue),
                          SizedBox(height: 8),
                          Text(
                            'カメラで撮影',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop('gallery'),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.purple[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.purple[200]!),
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.photo_library, size: 32, color: Colors.purple),
                          SizedBox(height: 8),
                          Text(
                            'ギャラリーから',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.purple,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('キャンセル'),
            ),
          ],
        ),
      ),
    );
  }
}

// メディア詳細ダイアログ
class MediaDetailDialog extends StatelessWidget {
  final Map<String, dynamic> media;

  const MediaDetailDialog({Key? key, required this.media}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final albumType = MediaService.albumTypes[media['albumType']];
    
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        child: Column(
          children: [
            // ヘッダー
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: albumType?['color']?.withOpacity(0.1) ?? Colors.grey[100],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    albumType?['icon'] ?? Icons.photo,
                    color: albumType?['color'] ?? Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      media['caption'] ?? '無題',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            
            // メディア表示
            Expanded(
              child: Container(
                width: double.infinity,
                child: media['isVideo'] == true
                    ? Stack(
                        alignment: Alignment.center,
                        children: [
                          MediaService.buildThumbnail(
                            imageUrl: media['thumbnailUrl'] ?? media['fileUrl'],
                            size: double.infinity,
                            fit: BoxFit.contain,
                            isVideo: true,
                          ),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: const Icon(
                              Icons.play_arrow,
                              size: 40,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      )
                    : MediaService.buildThumbnail(
                        imageUrl: media['fileUrl'],
                        size: double.infinity,
                        fit: BoxFit.contain,
                      ),
              ),
            ),
            
            // 詳細情報
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        MediaService.getFileTypeIcon(media['fileExtension'] ?? ''),
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        MediaService.formatFileSize(media['fileSize'] ?? 0),
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      const Spacer(),
                      Text(
                        DateTime.parse(media['takenAt']).toString().substring(0, 16),
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                  if (media['location']?.isNotEmpty == true) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 16, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text(
                          media['location'],
                          style: const TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // 編集機能
                            Navigator.of(context).pop();
                          },
                          icon: const Icon(Icons.edit, size: 16),
                          label: const Text('編集'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // 共有機能
                            Navigator.of(context).pop();
                          },
                          icon: const Icon(Icons.share, size: 16),
                          label: const Text('共有'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkMode = false;
  bool _notificationsEnabled = true;
  bool _syncEnabled = true;
  String _selectedLanguage = '日本語';
  String _selectedCurrency = 'JPY';
  String _selectedTimezone = 'Asia/Tokyo';
  bool _isLoggedIn = false;
  String _userEmail = '';

  final List<String> _languages = ['日本語', 'English', '한국어', '中文'];
  final List<String> _currencies = ['JPY', 'USD', 'EUR', 'IDR'];
  final List<String> _timezones = ['Asia/Tokyo', 'Asia/Jakarta', 'UTC', 'America/New_York'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue[50],
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '設定・アカウント',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'アプリの設定とアカウント管理',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // アカウント認証セクション
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.account_circle, color: Colors.blue),
                            const SizedBox(width: 8),
                            const Text(
                              'アカウント',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (!_isLoggedIn) ...[
                          const Text(
                            'ログインして旅行データを同期しましょう',
                            style: TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () => _signInWithGoogle(),
                                  icon: const Icon(Icons.login, size: 16),
                                  label: const Text('Googleでログイン'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red[600],
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () => _signInWithEmail(),
                                  icon: const Icon(Icons.email, size: 16),
                                  label: const Text('メールでログイン'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue[600],
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ] else ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.green[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.green[200]!),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.green[100],
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.person, color: Colors.green),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'ログイン中',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: Colors.green,
                                        ),
                                      ),
                                      Text(
                                        _userEmail,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => _signOut(),
                                  child: const Text(
                                    'ログアウト',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // 表示設定セクション
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.palette, color: Colors.blue),
                            const SizedBox(width: 8),
                            const Text(
                              '表示設定',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ListTile(
                          leading: Icon(_isDarkMode ? Icons.dark_mode : Icons.light_mode),
                          title: const Text('ダークモード'),
                          subtitle: Text(_isDarkMode ? 'ダークテーマを使用中' : 'ライトテーマを使用中'),
                          trailing: Switch(
                            value: _isDarkMode,
                            onChanged: (value) {
                              setState(() {
                                _isDarkMode = value;
                              });
                            },
                          ),
                          contentPadding: EdgeInsets.zero,
                        ),
                        ListTile(
                          leading: const Icon(Icons.language),
                          title: const Text('言語'),
                          subtitle: Text(_selectedLanguage),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () => _showLanguageDialog(),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // 旅行設定セクション
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.travel_explore, color: Colors.blue),
                            const SizedBox(width: 8),
                            const Text(
                              '旅行設定',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ListTile(
                          leading: const Icon(Icons.monetization_on),
                          title: const Text('通貨'),
                          subtitle: Text(_selectedCurrency),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () => _showCurrencyDialog(),
                          contentPadding: EdgeInsets.zero,
                        ),
                        ListTile(
                          leading: const Icon(Icons.schedule),
                          title: const Text('タイムゾーン'),
                          subtitle: Text(_selectedTimezone),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () => _showTimezoneDialog(),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // 通知・同期設定セクション
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.sync, color: Colors.blue),
                            const SizedBox(width: 8),
                            const Text(
                              '通知・同期',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ListTile(
                          leading: const Icon(Icons.notifications),
                          title: const Text('プッシュ通知'),
                          subtitle: const Text('旅行のリマインダーを受け取る'),
                          trailing: Switch(
                            value: _notificationsEnabled,
                            onChanged: (value) {
                              setState(() {
                                _notificationsEnabled = value;
                              });
                            },
                          ),
                          contentPadding: EdgeInsets.zero,
                        ),
                        ListTile(
                          leading: const Icon(Icons.cloud_sync),
                          title: const Text('自動同期'),
                          subtitle: const Text('データを自動でクラウドに保存'),
                          trailing: Switch(
                            value: _syncEnabled,
                            onChanged: (value) {
                              setState(() {
                                _syncEnabled = value;
                              });
                            },
                          ),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // 通知設定セクション
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.notifications, color: Colors.orange),
                            const SizedBox(width: 8),
                            const Text(
                              '通知設定',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ListTile(
                          leading: const Icon(Icons.notification_add),
                          title: const Text('テスト通知'),
                          subtitle: const Text('通知機能をテストします'),
                          trailing: ElevatedButton(
                            onPressed: () async {
                              await NotificationService.sendTestNotification();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('テスト通知を送信しました'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                            child: const Text('送信'),
                          ),
                          contentPadding: EdgeInsets.zero,
                        ),
                        ListTile(
                          leading: const Icon(Icons.schedule),
                          title: const Text('旅行リマインダー'),
                          subtitle: const Text('出発前の準備通知'),
                          trailing: Switch(
                            value: true,
                            onChanged: (value) {
                              // 旅行リマインダーの有効/無効切り替え
                            },
                          ),
                          contentPadding: EdgeInsets.zero,
                        ),
                        ListTile(
                          leading: const Icon(Icons.inventory),
                          title: const Text('持ち物チェック'),
                          subtitle: const Text('パッキングリマインダー'),
                          trailing: Switch(
                            value: true,
                            onChanged: (value) {
                              // 持ち物チェック通知の有効/無効切り替え
                            },
                          ),
                          contentPadding: EdgeInsets.zero,
                        ),
                        ListTile(
                          leading: const Icon(Icons.document_scanner),
                          title: const Text('書類有効期限'),
                          subtitle: const Text('パスポート等の期限通知'),
                          trailing: Switch(
                            value: true,
                            onChanged: (value) {
                              // 書類期限通知の有効/無効切り替え
                            },
                          ),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // オフライン・同期セクション
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.sync, color: Colors.purple),
                            const SizedBox(width: 8),
                            const Text(
                              'オフライン・同期',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        StreamBuilder<bool>(
                          stream: OfflineService().onlineStatusStream,
                          initialData: OfflineService().isOnline,
                          builder: (context, snapshot) {
                            final isOnline = snapshot.data ?? false;
                            return ListTile(
                              leading: Icon(
                                isOnline ? Icons.cloud_done : Icons.cloud_off,
                                color: isOnline ? Colors.green : Colors.red,
                              ),
                              title: Text(isOnline ? 'オンライン' : 'オフライン'),
                              subtitle: Text(
                                isOnline 
                                  ? 'データは自動で同期されます'
                                  : 'オフラインモードで動作中',
                              ),
                              contentPadding: EdgeInsets.zero,
                            );
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.sync_problem),
                          title: const Text('手動同期'),
                          subtitle: const Text('すべてのデータを強制同期'),
                          trailing: ElevatedButton(
                            onPressed: () async {
                              // 手動同期実行
                              final success = await OfflineService().performManualSync('current_user_id');
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(success ? '同期完了' : '同期に失敗しました'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                            child: const Text('同期'),
                          ),
                          contentPadding: EdgeInsets.zero,
                        ),
                        FutureBuilder<Map<String, dynamic>>(
                          future: OfflineService().getSyncStatus(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const SizedBox.shrink();
                            }
                            
                            final status = snapshot.data!;
                            final pendingChanges = status['pendingChanges'] as int;
                            final lastSync = status['lastSync'] as DateTime?;
                            
                            return Column(
                              children: [
                                if (pendingChanges > 0)
                                  ListTile(
                                    leading: const Icon(Icons.pending_actions, color: Colors.orange),
                                    title: Text('同期待ち: $pendingChanges件'),
                                    subtitle: const Text('オンライン復帰時に自動同期されます'),
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                if (lastSync != null)
                                  ListTile(
                                    leading: const Icon(Icons.update),
                                    title: const Text('最終同期'),
                                    subtitle: Text(
                                      '${lastSync.month}/${lastSync.day} ${lastSync.hour}:${lastSync.minute.toString().padLeft(2, '0')}',
                                    ),
                                    contentPadding: EdgeInsets.zero,
                                  ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // アプリ情報セクション
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.info, color: Colors.blue),
                            const SizedBox(width: 8),
                            const Text(
                              'アプリ情報',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ListTile(
                          leading: const Icon(Icons.help),
                          title: const Text('ヘルプ・サポート'),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () {},
                          contentPadding: EdgeInsets.zero,
                        ),
                        ListTile(
                          leading: const Icon(Icons.privacy_tip),
                          title: const Text('プライバシーポリシー'),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () {},
                          contentPadding: EdgeInsets.zero,
                        ),
                        ListTile(
                          leading: const Icon(Icons.description),
                          title: const Text('利用規約'),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () {},
                          contentPadding: EdgeInsets.zero,
                        ),
                        const ListTile(
                          leading: Icon(Icons.info_outline),
                          title: Text('バージョン'),
                          subtitle: Text('TripVault v1.0.0'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _signInWithGoogle() async {
    try {
      final userCredential = await FirebaseService.signInWithGoogle();
      if (userCredential != null) {
        setState(() {
          _isLoggedIn = true;
          _userEmail = userCredential.user?.email ?? '';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Googleアカウントでログインしました'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ログインがキャンセルされました'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('ログインエラー: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _signInWithEmail() {
    // メールログインダイアログを表示
    _showEmailLoginDialog();
  }

  void _showEmailLoginDialog() {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    bool isRegistering = false;
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isRegistering ? '新規登録' : 'メールログイン'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isRegistering) ...[
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: '名前',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'メールアドレス',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  decoration: const InputDecoration(
                    labelText: 'パスワード',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setDialogState(() {
                  isRegistering = !isRegistering;
                });
              },
              child: Text(isRegistering ? 'ログインに切り替え' : '新規登録に切り替え'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('キャンセル'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  final email = emailController.text.trim();
                  final password = passwordController.text.trim();
                  
                  if (email.isEmpty || password.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('メールアドレスとパスワードを入力してください')),
                    );
                    return;
                  }

                  Navigator.pop(context);

                  if (isRegistering) {
                    final name = nameController.text.trim();
                    if (name.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('名前を入力してください')),
                      );
                      return;
                    }
                    
                    final userCredential = await FirebaseService.registerWithEmail(
                      email, password, name);
                    
                    if (userCredential != null) {
                      setState(() {
                        _isLoggedIn = true;
                        _userEmail = email;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('アカウントを作成しました'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } else {
                    final userCredential = await FirebaseService.signInWithEmail(
                      email, password);
                    
                    if (userCredential != null) {
                      setState(() {
                        _isLoggedIn = true;
                        _userEmail = email;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('ログインしました'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('エラー: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: Text(isRegistering ? '登録' : 'ログイン'),
            ),
          ],
        ),
      ),
    );
  }

  void _signOut() async {
    try {
      await FirebaseService.signOut();
      setState(() {
        _isLoggedIn = false;
        _userEmail = '';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ログアウトしました'),
          backgroundColor: Colors.grey,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('ログアウトエラー: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('言語選択'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _languages.map((language) => ListTile(
            title: Text(language),
            leading: Radio<String>(
              value: language,
              groupValue: _selectedLanguage,
              onChanged: (value) {
                setState(() {
                  _selectedLanguage = value!;
                });
                Navigator.pop(context);
              },
            ),
          )).toList(),
        ),
      ),
    );
  }

  void _showCurrencyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('通貨選択'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _currencies.map((currency) => ListTile(
            title: Text(currency),
            leading: Radio<String>(
              value: currency,
              groupValue: _selectedCurrency,
              onChanged: (value) {
                setState(() {
                  _selectedCurrency = value!;
                });
                Navigator.pop(context);
              },
            ),
          )).toList(),
        ),
      ),
    );
  }

  void _showTimezoneDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('タイムゾーン選択'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _timezones.map((timezone) => ListTile(
            title: Text(timezone),
            leading: Radio<String>(
              value: timezone,
              groupValue: _selectedTimezone,
              onChanged: (value) {
                setState(() {
                  _selectedTimezone = value!;
                });
                Navigator.pop(context);
              },
            ),
          )).toList(),
        ),
      ),
    );
  }
}

