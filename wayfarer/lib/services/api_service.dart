import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/constants.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  
  late Dio _dio;
  String? _token;
  
  ApiService._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(milliseconds: AppConstants.apiTimeout),
      receiveTimeout: const Duration(milliseconds: AppConstants.apiTimeout),
      headers: {
        'Content-Type': 'application/json',
      },
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        if (_token != null) {
          options.headers['Authorization'] = 'Bearer $_token';
        }
        return handler.next(options);
      },
      onError: (error, handler) {
        if (error.response?.statusCode == 401) {
          _token = null;
        }
        return handler.next(error);
      },
    ));
  }

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(AppConstants.tokenKey);
  }

  void setToken(String? token) {
    _token = token;
  }

  String? get token => _token;

  // Auth
  Future<Response> register(String name, String email, String password, {String? homeCurrency, String? homeCountry}) async {
    return _dio.post('/auth/register', data: {
      'name': name,
      'email': email,
      'password': password,
      'homeCurrency': homeCurrency,
      'homeCountry': homeCountry,
    });
  }

  Future<Response> login(String email, String password) async {
    return _dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
  }

  Future<Response> getProfile() async {
    return _dio.get('/auth/me');
  }

  Future<Response> updateProfile(Map<String, dynamic> data) async {
    return _dio.put('/auth/profile', data: data);
  }

  Future<Response> changePassword(String currentPassword, String newPassword) async {
    return _dio.put('/auth/password', data: {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
    });
  }

  // Trips
  Future<Response> getTrips({String? status}) async {
    final params = <String, dynamic>{};
    if (status != null) params['status'] = status;
    return _dio.get('/trips', queryParameters: params);
  }

  Future<Response> getTrip(String id) async {
    return _dio.get('/trips/$id');
  }

  Future<Response> createTrip(Map<String, dynamic> data) async {
    return _dio.post('/trips', data: data);
  }

  Future<Response> updateTrip(String id, Map<String, dynamic> data) async {
    return _dio.put('/trips/$id', data: data);
  }

  Future<Response> toggleChecklistItem(String tripId, int itemIndex) async {
    return _dio.put('/trips/$tripId/checklist/$itemIndex');
  }

  Future<Response> deleteTrip(String id) async {
    return _dio.delete('/trips/$id');
  }

  // Journal
  Future<Response> getJournalEntries({String? tripId}) async {
    final params = <String, dynamic>{};
    if (tripId != null) params['tripId'] = tripId;
    return _dio.get('/journal', queryParameters: params);
  }

  Future<Response> createJournalEntry(Map<String, dynamic> data) async {
    return _dio.post('/journal', data: data);
  }

  Future<Response> updateJournalEntry(String id, Map<String, dynamic> data) async {
    return _dio.put('/journal/$id', data: data);
  }

  Future<Response> deleteJournalEntry(String id) async {
    return _dio.delete('/journal/$id');
  }

  Future<Response> getJournalStats() async {
    return _dio.get('/journal/stats');
  }

  // Favorites
  Future<Response> getFavorites({String? type}) async {
    final params = <String, dynamic>{};
    if (type != null) params['type'] = type;
    return _dio.get('/favorites', queryParameters: params);
  }

  Future<Response> addFavorite(Map<String, dynamic> data) async {
    return _dio.post('/favorites', data: data);
  }

  Future<Response> removeFavorite(String id) async {
    return _dio.delete('/favorites/$id');
  }

  // Proxy APIs
  Future<Response> getCountryInfo(String code) async {
    return _dio.get('/proxy/countries/$code');
  }

  Future<Response> searchCountries(String name) async {
    return _dio.get('/proxy/countries/search/$name');
  }

  Future<Response> getAllCountries() async {
    return _dio.get('/proxy/countries');
  }

  Future<Response> getCountryGuides() async {
    return _dio.get('/proxy/guides');
  }

  Future<Response> getWeather(double lat, double lng) => getCurrentWeather(lat, lng);

  Future<Response> getCurrentWeather(double lat, double lng) async {
    return _dio.get('/proxy/weather/current', queryParameters: {'lat': lat, 'lng': lng});
  }

  Future<Response> getAirQuality(double lat, double lng) async {
    return _dio.get('/proxy/weather/air-quality', queryParameters: {'lat': lat, 'lng': lng});
  }

  Future<Response> getAstronomy(double lat, double lng, {String? date}) async {
    final params = <String, dynamic>{'lat': lat, 'lng': lng};
    if (date != null) params['date'] = date;
    return _dio.get('/proxy/weather/astronomy', queryParameters: params);
  }

  Future<Response> getExchangeRates(String from, {String? to}) async {
    final params = <String, dynamic>{'from': from};
    if (to != null) params['to'] = to;
    return _dio.get('/proxy/currency/rates', queryParameters: params);
  }

  Future<Response> convertCurrency(String from, String to, double amount) async {
    return _dio.get('/proxy/currency/convert', queryParameters: {'from': from, 'to': to, 'amount': amount});
  }

  Future<Response> getCostOfLiving(String city) async {
    return _dio.get('/proxy/currency/cost-of-living', queryParameters: {'city': city});
  }

  Future<Response> searchPlaces(String query, {double? lat, double? lng}) async {
    final params = <String, dynamic>{'q': query};
    if (lat != null) params['lat'] = lat;
    if (lng != null) params['lng'] = lng;
    return _dio.get('/proxy/places/search', queryParameters: params);
  }

  Future<Response> reverseGeocode(double lat, double lng) async {
    return _dio.get('/proxy/places/reverse', queryParameters: {'lat': lat, 'lng': lng});
  }

  Future<Response> getNearbyPlaces(double lat, double lng, String type, {int? radius}) async {
    final params = <String, dynamic>{'lat': lat, 'lng': lng, 'type': type};
    if (radius != null) params['radius'] = radius;
    return _dio.get('/proxy/places/nearby', queryParameters: params);
  }

  Future<Response> getRoute(double startLat, double startLng, double endLat, double endLng, {String? profile}) async {
    final params = <String, dynamic>{
      'startLat': startLat,
      'startLng': startLng,
      'endLat': endLat,
      'endLng': endLng,
    };
    if (profile != null) params['profile'] = profile;
    return _dio.get('/proxy/places/route', queryParameters: params);
  }

  Future<Response> getWikipediaSummary(String place) async {
    return _dio.get('/proxy/places/wikipedia/$place');
  }

  Future<Response> searchRestaurants(double lat, double lng, {String? query, int? radius}) async {
    final params = <String, dynamic>{'lat': lat, 'lng': lng};
    if (query != null) params['query'] = query;
    if (radius != null) params['radius'] = radius;
    return _dio.get('/proxy/food/restaurants', queryParameters: params);
  }

  Future<Response> getCuisineByCountry(String country) async {
    return _dio.get('/proxy/food/cuisine/$country');
  }

  Future<Response> getMealDetails(String id) async {
    return _dio.get('/proxy/food/meal/$id');
  }

  Future<Response> getBarcode(String code) async {
    return _dio.get('/proxy/food/barcode/$code');
  }

  Future<Response> getTransportRoutes(double fromLat, double fromLng, double toLat, double toLng) async {
    return _dio.get('/proxy/transport/routes', queryParameters: {
      'fromLat': fromLat,
      'fromLng': fromLng,
      'toLat': toLat,
      'toLng': toLng,
    });
  }

  Future<Response> getTransitStops(double lat, double lng, {int? radius}) async {
    final params = <String, dynamic>{'lat': lat, 'lng': lng};
    if (radius != null) params['radius'] = radius;
    return _dio.get('/proxy/transport/transit', queryParameters: params);
  }

  Future<Response> searchFlights(String origin, String destination, String departureDate, {int adults = 1}) async {
    return _dio.get('/proxy/transport/flights', queryParameters: {
      'origin': origin,
      'destination': destination,
      'departureDate': departureDate,
      'adults': adults,
    });
  }

  Future<Response> getEmergencyNumbers(String countryCode) async {
    return _dio.get('/proxy/emergency/numbers/$countryCode');
  }

  Future<Response> getNearbyHospitals(double lat, double lng, {int? radius}) async {
    final params = <String, dynamic>{'lat': lat, 'lng': lng};
    if (radius != null) params['radius'] = radius;
    return _dio.get('/proxy/emergency/hospitals', queryParameters: params);
  }

  Future<Response> getHealthAlerts() async {
    return _dio.get('/proxy/emergency/health-alerts');
  }

  Future<Response> sendSOS(List<Map<String, dynamic>> contacts, Map<String, dynamic> location, {String? message}) async {
    return _dio.post('/proxy/emergency/sos', data: {
      'contacts': contacts,
      'location': location,
      'message': message,
    });
  }

  // Accommodation
  Future<Response> searchAccommodation(double lat, double lng, {String? type, int? radius}) async {
    final params = <String, dynamic>{'lat': lat, 'lng': lng};
    if (type != null) params['type'] = type;
    if (radius != null) params['radius'] = radius;
    return _dio.get('/proxy/accommodation/search', queryParameters: params);
  }

  Future<Response> getAccommodationDetails(String id) async {
    return _dio.get('/proxy/accommodation/details/$id');
  }

  // Admin
  Future<Response> getAdminDashboard() async {
    return _dio.get('/admin/dashboard');
  }

  Future<Response> getAdminUsers({int page = 1, int limit = 20, String? search, String? role}) async {
    final params = <String, dynamic>{'page': page, 'limit': limit};
    if (search != null) params['search'] = search;
    if (role != null) params['role'] = role;
    return _dio.get('/admin/users', queryParameters: params);
  }

  Future<Response> updateAdminUser(String id, Map<String, dynamic> data) async {
    return _dio.put('/admin/users/$id', data: data);
  }

  Future<Response> deleteAdminUser(String id) async {
    return _dio.delete('/admin/users/$id');
  }

  Future<Response> getAdminTrips({int page = 1, int limit = 20}) async {
    return _dio.get('/admin/trips', queryParameters: {'page': page, 'limit': limit});
  }

  Future<Response> searchCountryGuides(String query) async {
    return _dio.get('/proxy/guides/search', queryParameters: {'q': query});
  }
}
