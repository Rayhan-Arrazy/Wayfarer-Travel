class JournalEntryModel {
  final String id;
  final String userId;
  final String tripId;
  final String tripDestination;
  final String title;
  final String note;
  final JournalLocation? location;
  final JournalWeather? weather;
  final List<JournalPhoto> photos;
  final String mood;
  final double distanceTraveled;
  final DateTime createdAt;

  JournalEntryModel({
    required this.id,
    required this.userId,
    required this.tripId,
    this.tripDestination = '',
    this.title = '',
    this.note = '',
    this.location,
    this.weather,
    this.photos = const [],
    this.mood = '',
    this.distanceTraveled = 0,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory JournalEntryModel.fromJson(Map<String, dynamic> json) {
    return JournalEntryModel(
      id: json['_id'] ?? '',
      userId: json['userId'] ?? '',
      tripId: json['tripId'] is Map ? json['tripId']['_id'] ?? '' : json['tripId'] ?? '',
      tripDestination: json['tripId'] is Map ? json['tripId']['destination'] ?? '' : '',
      title: json['title'] ?? '',
      note: json['note'] ?? '',
      location: json['location'] != null ? JournalLocation.fromJson(json['location']) : null,
      weather: json['weather'] != null ? JournalWeather.fromJson(json['weather']) : null,
      photos: (json['photos'] as List<dynamic>?)
          ?.map((e) => JournalPhoto.fromJson(e))
          .toList() ?? [],
      mood: json['mood'] ?? '',
      distanceTraveled: (json['distanceTraveled'] ?? 0).toDouble(),
      createdAt: json['createdAt'] != null ? (DateTime.tryParse(json['createdAt']) ?? DateTime.now()) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'tripId': tripId,
    'title': title,
    'note': note,
    'location': location?.toJson(),
    'weather': weather?.toJson(),
    'photos': photos.map((p) => p.toJson()).toList(),
    'mood': mood,
  };
}

class JournalLocation {
  final double lat;
  final double lng;
  final String name;
  final String country;

  JournalLocation({this.lat = 0, this.lng = 0, this.name = '', this.country = ''});

  factory JournalLocation.fromJson(Map<String, dynamic> json) {
    return JournalLocation(
      lat: (json['lat'] ?? 0).toDouble(),
      lng: (json['lng'] ?? 0).toDouble(),
      name: json['name'] ?? '',
      country: json['country'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'lat': lat, 'lng': lng, 'name': name, 'country': country};
}

class JournalWeather {
  final double temp;
  final String description;
  final String icon;

  JournalWeather({this.temp = 0, this.description = '', this.icon = ''});

  factory JournalWeather.fromJson(Map<String, dynamic> json) {
    return JournalWeather(
      temp: (json['temp'] ?? 0).toDouble(),
      description: json['description'] ?? '',
      icon: json['icon'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'temp': temp, 'description': description, 'icon': icon};
}

class JournalPhoto {
  final String url;
  final String caption;

  JournalPhoto({required this.url, this.caption = ''});

  factory JournalPhoto.fromJson(Map<String, dynamic> json) {
    return JournalPhoto(
      url: json['url'] ?? '',
      caption: json['caption'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'url': url, 'caption': caption};
}
