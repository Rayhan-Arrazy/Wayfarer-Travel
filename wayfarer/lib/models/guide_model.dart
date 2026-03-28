class CountryGuideModel {
  final String id;
  final String name;
  final String countryCode;
  final String flagUrl;
  final String coverImage;
  final String description;
  final List<String> tips;
  final String bestTimeToVisit;
  final String language;
  final String currency;
  final List<TopCity> topCities;
  final bool featured;

  CountryGuideModel({
    required this.id,
    required this.name,
    this.countryCode = '',
    this.flagUrl = '',
    this.coverImage = '',
    this.description = '',
    this.tips = const [],
    this.bestTimeToVisit = '',
    this.language = '',
    this.currency = '',
    this.topCities = const [],
    this.featured = false,
  });

  factory CountryGuideModel.fromJson(Map<String, dynamic> json) {
    return CountryGuideModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      countryCode: json['countryCode'] ?? '',
      flagUrl: json['flagUrl'] ?? '',
      coverImage: json['coverImage'] ?? '',
      description: json['description'] ?? '',
      tips: (json['tips'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      bestTimeToVisit: json['bestTimeToVisit'] ?? '',
      language: json['language'] ?? '',
      currency: json['currency'] ?? '',
      topCities: (json['topCities'] as List<dynamic>?)
          ?.map((e) => TopCity.fromJson(e))
          .toList() ?? [],
      featured: json['featured'] ?? false,
    );
  }
}

class TopCity {
  final String name;
  final String description;
  final String image;

  TopCity({this.name = '', this.description = '', this.image = ''});

  factory TopCity.fromJson(Map<String, dynamic> json) {
    return TopCity(
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      image: json['image'] ?? '',
    );
  }
}
