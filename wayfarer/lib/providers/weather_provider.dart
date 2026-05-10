import 'package:flutter/material.dart';
import '../services/api_service.dart';

class WeatherProvider with ChangeNotifier {
  final ApiService _apiService;
  Map<String, dynamic>? _currentWeather;
  bool _isLoading = false;
  String _error = '';

  WeatherProvider({ApiService? apiService}) : _apiService = apiService ?? ApiService();

  Map<String, dynamic>? get currentWeather => _currentWeather;
  bool get isLoading => _isLoading;
  String get error => _error;

  Future<void> fetchWeather(double lat, double lng) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final response = await _apiService.getWeather(lat, lng);
      if (response.statusCode == 200) {
        _currentWeather = Map<String, dynamic>.from(response.data);
      } else {
        _error = 'Failed to fetch weather';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Helper for UI status mapping
  String getWeatherStatus(Map<String, dynamic>? data) {
    if (data == null) return 'Unknown';
    return data['status'] ?? 'Clear';
  }
}
