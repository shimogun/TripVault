import 'package:flutter/material.dart';
import '../models/trip_models.dart';
import '../models/trip_info.dart';
import '../constants/app_constants.dart';
import '../constants/app_theme.dart';
import '../widgets/editable_trip_header.dart';

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
  String _selectedFilter = 'all'; // all, me, group

  late TripInfo _tripInfo;

  @override
  void initState() {
    super.initState();
    _tripInfo = TripInfo(
      id: 'trip_001',
      title: 'バリ島旅行',
      destination: 'バリ島、インドネシア',
      startDate: DateTime(2026, 3, 15),
      endDate: DateTime(2026, 3, 18),
      budgetPerPerson: 200000,
      participantCount: 4,
    );
  }

  void _onTripInfoChanged(TripInfo newTripInfo) {
    setState(() {
      _tripInfo = newTripInfo;
    });
    // TODO: 実際のアプリではここでFirestoreに保存
  }

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
        return AppTheme.primaryColor;
      case 'メンバー2':
        return AppTheme.successColor;
      case 'メンバー3':
        return Colors.purple;
      case 'メンバー4':
        return AppTheme.warningColor;
      default:
        return AppTheme.textSecondary;
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
              participants: ['あなた'],
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
          // Header section
          EditableTripHeader(
            tripInfo: _tripInfo,
            onTripInfoChanged: _onTripInfoChanged,
          ),
          // Filter section
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
                                Text('自分の旅程'),
                              ],
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'group',
                            child: Row(
                              children: [
                                Icon(Icons.group, size: 16),
                                SizedBox(width: 8),
                                Text('グループ旅程'),
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
          // Content tabs and list will be implemented in next step
          Expanded(
            child: DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  const TabBar(
                    tabs: [
                      Tab(
                        icon: Icon(Icons.schedule),
                        text: '行程表',
                      ),
                      Tab(
                        icon: Icon(Icons.luggage),
                        text: '持ち物リスト',
                      ),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildItineraryTab(),
                        _buildPackingTab(),
                      ],
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

  Widget _buildItineraryTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredTripDays.length,
      itemBuilder: (context, index) {
        final day = _filteredTripDays[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today, color: AppTheme.primaryColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(day.title, style: AppTextStyles.h3),
                          Text(day.date, style: AppTextStyles.body2),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        _editingDayId == day.id ? Icons.close : Icons.add,
                        color: AppTheme.primaryColor,
                      ),
                      onPressed: () {
                        setState(() {
                          _editingDayId = _editingDayId == day.id ? null : day.id;
                        });
                      },
                    ),
                  ],
                ),
              ),
              ...day.activities.map((activity) => ListTile(
                leading: Checkbox(
                  value: activity.completed,
                  onChanged: (_) => _toggleActivityComplete(day.id, activity.id),
                ),
                title: Text(activity.activity),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${activity.time} - ${activity.location}'),
                    Wrap(
                      spacing: 4,
                      children: activity.participants.map((participant) => Chip(
                        label: Text(
                          participant,
                          style: const TextStyle(fontSize: 10),
                        ),
                        backgroundColor: _getMemberColor(participant).withValues(alpha: 0.2),
                        side: BorderSide(color: _getMemberColor(participant)),
                      )).toList(),
                    ),
                  ],
                ),
              )),
              if (_editingDayId == day.id) _buildAddActivityForm(day.id),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAddActivityForm(int dayId) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
      ),
      child: Column(
        children: [
          TextField(
            decoration: const InputDecoration(
              labelText: '時間',
              hintText: '例: 10:00',
            ),
            onChanged: (value) => _newTime = value,
          ),
          const SizedBox(height: 8),
          TextField(
            decoration: const InputDecoration(
              labelText: 'アクティビティ',
              hintText: '例: 観光地見学',
            ),
            onChanged: (value) => _newActivity = value,
          ),
          const SizedBox(height: 8),
          TextField(
            decoration: const InputDecoration(
              labelText: '場所',
              hintText: '例: 東京タワー',
            ),
            onChanged: (value) => _newLocation = value,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    _editingDayId = null;
                    _newTime = '';
                    _newActivity = '';
                    _newLocation = '';
                  });
                },
                child: const Text(AppStrings.cancel),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => _addActivity(dayId),
                child: const Text(AppStrings.add),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPackingTab() {
    final groupedItems = _groupedPackingItems;
    final packedCount = _packingItems.where((item) => item.packed).length;
    
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: _packingItems.isNotEmpty ? packedCount / _packingItems.length : 0,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.successColor),
                ),
              ),
              const SizedBox(width: 16),
              Text(
                '$packedCount / ${_packingItems.length}',
                style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: groupedItems.keys.length,
            itemBuilder: (context, index) {
              final category = groupedItems.keys.elementAt(index);
              final items = groupedItems[category]!;
              
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ExpansionTile(
                  title: Text(category, style: AppTextStyles.h3),
                  subtitle: Text('${items.where((item) => item.packed).length} / ${items.length} 完了'),
                  children: items.map((item) => CheckboxListTile(
                    title: Text(item.name),
                    value: item.packed,
                    onChanged: (_) => _togglePackingItem(item.id),
                    controlAffinity: ListTileControlAffinity.leading,
                  )).toList(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}