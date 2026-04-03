class TripModel {
  final String id;
  final String userId;
  final String destination;
  final String countryCode;
  final String countryName;
  final DateTime startDate;
  final DateTime endDate;
  final int partySize;
  final String coverImage;
  final List<ChecklistItem> checklist;
  final List<ItineraryActivity> itinerary;
  final String notes;
  final String status;
  final DestinationInfo? destinationInfo;
  final DateTime createdAt;

  TripModel({
    required this.id,
    required this.userId,
    required this.destination,
    required this.countryCode,
    this.countryName = '',
    required this.startDate,
    required this.endDate,
    this.partySize = 1,
    this.coverImage = '',
    this.checklist = const [],
    this.itinerary = const [],
    this.notes = '',
    this.status = 'planning',
    this.destinationInfo,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  int get durationDays => endDate.difference(startDate).inDays;
  bool get isActive => status == 'active';
  bool get isPlanning => status == 'planning';
  bool get isCompleted => status == 'completed';
  int get checklistProgress {
    if (checklist.isEmpty) return 0;
    final checked = checklist.where((c) => c.checked).length;
    return ((checked / checklist.length) * 100).round();
  }

  factory TripModel.fromJson(Map<String, dynamic> json) {
    return TripModel(
      id: json['_id'] ?? '',
      userId: json['userId'] ?? '',
      destination: json['destination'] ?? '',
      countryCode: json['countryCode'] ?? '',
      countryName: json['countryName'] ?? '',
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      partySize: json['partySize'] ?? 1,
      coverImage: json['coverImage'] ?? '',
      checklist: (json['checklist'] as List<dynamic>?)
          ?.map((e) => ChecklistItem.fromJson(e))
          .toList() ?? [],
      itinerary: (json['itinerary'] as List<dynamic>?)
          ?.map((e) => ItineraryActivity.fromJson(e))
          .toList() ?? [],
      notes: json['notes'] ?? '',
      status: json['status'] ?? 'planning',
      destinationInfo: json['destinationInfo'] != null
          ? DestinationInfo.fromJson(json['destinationInfo'])
          : null,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'destination': destination,
    'countryCode': countryCode,
    'startDate': startDate.toIso8601String(),
    'endDate': endDate.toIso8601String(),
    'partySize': partySize,
    'notes': notes,
    'itinerary': itinerary.map((e) => e.toJson()).toList(),
  };

  TripModel copyWith({
    String? id,
    String? userId,
    String? destination,
    String? countryCode,
    String? countryName,
    DateTime? startDate,
    DateTime? endDate,
    int? partySize,
    String? coverImage,
    List<ChecklistItem>? checklist,
    List<ItineraryActivity>? itinerary,
    String? notes,
    String? status,
    DestinationInfo? destinationInfo,
    DateTime? createdAt,
  }) {
    return TripModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      destination: destination ?? this.destination,
      countryCode: countryCode ?? this.countryCode,
      countryName: countryName ?? this.countryName,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      partySize: partySize ?? this.partySize,
      coverImage: coverImage ?? this.coverImage,
      checklist: checklist ?? this.checklist,
      itinerary: itinerary ?? this.itinerary,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      destinationInfo: destinationInfo ?? this.destinationInfo,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class ItineraryActivity {
  final String title;
  final String time;
  final DateTime? date;
  final String location;
  final bool checked;

  ItineraryActivity({
    required this.title,
    this.time = '',
    this.date,
    this.location = '',
    this.checked = false,
  });

  factory ItineraryActivity.fromJson(Map<String, dynamic> json) {
    return ItineraryActivity(
      title: json['title'] ?? '',
      time: json['time'] ?? '',
      date: json['date'] != null ? DateTime.parse(json['date']) : null,
      location: json['location'] ?? '',
      checked: json['checked'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'time': time,
    'date': date?.toIso8601String(),
    'location': location,
    'checked': checked,
  };

  ItineraryActivity copyWith({
    String? title,
    String? time,
    DateTime? date,
    String? location,
    bool? checked,
  }) {
    return ItineraryActivity(
      title: title ?? this.title,
      time: time ?? this.time,
      date: date ?? this.date,
      location: location ?? this.location,
      checked: checked ?? this.checked,
    );
  }
}

class ChecklistItem {
  final String item;
  final String category;
  final bool checked;
  final bool autoGenerated;

  ChecklistItem({
    required this.item,
    this.category = 'other',
    this.checked = false,
    this.autoGenerated = false,
  });

  factory ChecklistItem.fromJson(Map<String, dynamic> json) {
    return ChecklistItem(
      item: json['item'] ?? '',
      category: json['category'] ?? 'other',
      checked: json['checked'] ?? false,
      autoGenerated: json['autoGenerated'] ?? false,
    );
  }

  ChecklistItem copyWith({
    String? item,
    String? category,
    bool? checked,
    bool? autoGenerated,
  }) {
    return ChecklistItem(
      item: item ?? this.item,
      category: category ?? this.category,
      checked: checked ?? this.checked,
      autoGenerated: autoGenerated ?? this.autoGenerated,
    );
  }
}

class TripBudget {
  final double amount;
  final String currency;

  TripBudget({this.amount = 0, this.currency = 'USD'});

  factory TripBudget.fromJson(Map<String, dynamic> json) {
    return TripBudget(
      amount: (json['amount'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'USD',
    );
  }

  Map<String, dynamic> toJson() => {'amount': amount, 'currency': currency};
}

class DestinationInfo {
  final String currency;
  final String language;
  final String timezone;
  final String capital;
  final int population;
  final String flagUrl;

  DestinationInfo({
    this.currency = '',
    this.language = '',
    this.timezone = '',
    this.capital = '',
    this.population = 0,
    this.flagUrl = '',
  });

  factory DestinationInfo.fromJson(Map<String, dynamic> json) {
    return DestinationInfo(
      currency: json['currency'] ?? '',
      language: json['language'] ?? '',
      timezone: json['timezone'] ?? '',
      capital: json['capital'] ?? '',
      population: json['population'] ?? 0,
      flagUrl: json['flagUrl'] ?? '',
    );
  }
}

class TripExpense {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final String category;

  TripExpense({
    this.id = '',
    required this.title,
    required this.amount,
    required this.date,
    this.category = 'General',
  });

  factory TripExpense.fromJson(Map<String, dynamic> json) {
    return TripExpense(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
      category: json['category'] ?? 'General',
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'category': category,
    };
    if (id.isNotEmpty) {
      map['_id'] = id;
    }
    return map;
  }
}
