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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'title': title,
      'activities': activities.map((a) => a.toMap()).toList(),
    };
  }

  factory TripDay.fromMap(Map<String, dynamic> map) {
    return TripDay(
      id: map['id'],
      date: map['date'],
      title: map['title'],
      activities: List<TripActivity>.from(
        map['activities']?.map((a) => TripActivity.fromMap(a)) ?? [],
      ),
    );
  }
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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'time': time,
      'activity': activity,
      'location': location,
      'participants': participants,
      'completed': completed,
    };
  }

  factory TripActivity.fromMap(Map<String, dynamic> map) {
    return TripActivity(
      id: map['id'],
      time: map['time'],
      activity: map['activity'],
      location: map['location'],
      participants: List<String>.from(map['participants'] ?? []),
      completed: map['completed'] ?? false,
    );
  }
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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'packed': packed,
    };
  }

  factory PackingItem.fromMap(Map<String, dynamic> map) {
    return PackingItem(
      id: map['id'],
      name: map['name'],
      category: map['category'],
      packed: map['packed'] ?? false,
    );
  }
}