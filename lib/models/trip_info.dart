class TripInfo {
  final String id;
  String title;
  String destination;
  DateTime startDate;
  DateTime endDate;
  double budgetPerPerson;
  int participantCount;

  TripInfo({
    required this.id,
    required this.title,
    required this.destination,
    required this.startDate,
    required this.endDate,
    required this.budgetPerPerson,
    required this.participantCount,
  });

  // 旅行日数を計算
  int get durationInDays {
    return endDate.difference(startDate).inDays + 1;
  }

  // 総予算を計算
  double get totalBudget {
    return budgetPerPerson * participantCount;
  }

  // 日付範囲の文字列表現
  String get dateRangeString {
    final startFormatted = '${startDate.year}年${startDate.month}月${startDate.day}日';
    final endFormatted = '${endDate.year}年${endDate.month}月${endDate.day}日';
    return '$startFormatted〜$endFormatted';
  }

  // 予算の文字列表現
  String get budgetString {
    return '¥${budgetPerPerson.toStringAsFixed(0)}/人';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'destination': destination,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'budgetPerPerson': budgetPerPerson,
      'participantCount': participantCount,
    };
  }

  factory TripInfo.fromMap(Map<String, dynamic> map) {
    return TripInfo(
      id: map['id'],
      title: map['title'],
      destination: map['destination'],
      startDate: DateTime.parse(map['startDate']),
      endDate: DateTime.parse(map['endDate']),
      budgetPerPerson: map['budgetPerPerson']?.toDouble() ?? 0.0,
      participantCount: map['participantCount'] ?? 1,
    );
  }

  TripInfo copyWith({
    String? title,
    String? destination,
    DateTime? startDate,
    DateTime? endDate,
    double? budgetPerPerson,
    int? participantCount,
  }) {
    return TripInfo(
      id: id,
      title: title ?? this.title,
      destination: destination ?? this.destination,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      budgetPerPerson: budgetPerPerson ?? this.budgetPerPerson,
      participantCount: participantCount ?? this.participantCount,
    );
  }
}