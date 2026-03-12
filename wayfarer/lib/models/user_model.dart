class UserModel {
  final String id;
  final String name;
  final String email;
  final String role;
  final String avatar;
  final String homeCurrency;
  final String homeCountry;
  final List<EmergencyContact> emergencyContacts;
  final List<String> visitedCountries;
  final int totalTrips;
  final bool isActive;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.role = 'user',
    this.avatar = '',
    this.homeCurrency = 'USD',
    this.homeCountry = '',
    this.emergencyContacts = const [],
    this.visitedCountries = const [],
    this.totalTrips = 0,
    this.isActive = true,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  bool get isAdmin => role == 'admin';

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'user',
      avatar: json['avatar'] ?? '',
      homeCurrency: json['homeCurrency'] ?? 'USD',
      homeCountry: json['homeCountry'] ?? '',
      emergencyContacts: (json['emergencyContacts'] as List<dynamic>?)
          ?.map((e) => EmergencyContact.fromJson(e))
          .toList() ?? [],
      visitedCountries: (json['visitedCountries'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ?? [],
      totalTrips: json['totalTrips'] ?? 0,
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'homeCurrency': homeCurrency,
    'homeCountry': homeCountry,
    'emergencyContacts': emergencyContacts.map((e) => e.toJson()).toList(),
    'avatar': avatar,
  };
}

class EmergencyContact {
  final String name;
  final String phone;
  final String relationship;

  EmergencyContact({
    required this.name,
    required this.phone,
    this.relationship = '',
  });

  factory EmergencyContact.fromJson(Map<String, dynamic> json) {
    return EmergencyContact(
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      relationship: json['relationship'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'phone': phone,
    'relationship': relationship,
  };
}
