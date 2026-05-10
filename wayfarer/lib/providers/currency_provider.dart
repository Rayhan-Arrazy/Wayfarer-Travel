import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class CurrencyProvider with ChangeNotifier {
  final Dio _dio;
  final String _baseUrl = 'https://open.er-api.com/v6/latest';

  CurrencyProvider({Dio? dio}) : _dio = dio ?? Dio();
  
  Map<String, dynamic> _rates = {};
  bool _isLoading = false;
  String _error = '';

  Map<String, dynamic> get rates => _rates;
  bool get isLoading => _isLoading;
  String get error => _error;

  Future<void> fetchRates([String base = 'USD']) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final response = await _dio.get('$_baseUrl/$base');
      if (response.statusCode == 200) {
        _rates = response.data['rates'] ?? {};
      } else {
        _error = 'Failed to fetch rates';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  double convert(double amount, String from, String to) {
    if (_rates.isEmpty) return 0.0;
    
    // Convert to USD first (if base is USD)
    // Formula: (amount / from_rate) * to_rate
    final fromRate = _rates[from] ?? 1.0;
    final toRate = _rates[to] ?? 1.0;
    
    return (amount / fromRate) * toRate;
  }
}
