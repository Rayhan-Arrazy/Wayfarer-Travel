class BudgetModel {
  final String id;
  final String userId;
  final String? tripId;
  final String title;
  final double amount;
  final String currency;
  final List<BudgetExpense> expenses;
  final DateTime createdAt;

  BudgetModel({
    required this.id,
    required this.userId,
    this.tripId,
    required this.title,
    this.amount = 0,
    this.currency = 'USD',
    this.expenses = const [],
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory BudgetModel.fromJson(Map<String, dynamic> json) {
    return BudgetModel(
      id: json['_id'] ?? '',
      userId: json['userId'] ?? '',
      tripId: json['tripId'],
      title: json['title'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'USD',
      expenses: (json['expenses'] as List<dynamic>?)
          ?.map((e) => BudgetExpense.fromJson(e))
          .toList() ?? [],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'title': title,
      'amount': amount,
      'currency': currency,
      'expenses': expenses.map((e) => e.toJson()).toList(),
    };
    if (tripId != null) map['tripId'] = tripId;
    return map;
  }

  BudgetModel copyWith({
    String? id,
    String? userId,
    String? tripId,
    String? title,
    double? amount,
    String? currency,
    List<BudgetExpense>? expenses,
    DateTime? createdAt,
  }) {
    return BudgetModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      tripId: tripId ?? this.tripId,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      expenses: expenses ?? this.expenses,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class BudgetExpense {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final String category;

  BudgetExpense({
    this.id = '',
    required this.title,
    required this.amount,
    required this.date,
    this.category = 'General',
  });

  factory BudgetExpense.fromJson(Map<String, dynamic> json) {
    return BudgetExpense(
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
    if (id.isNotEmpty) map['_id'] = id;
    return map;
  }
}
