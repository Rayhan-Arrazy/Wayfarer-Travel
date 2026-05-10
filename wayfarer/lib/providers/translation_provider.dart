import 'package:flutter/material.dart';
import '../services/api_service.dart';

class TranslationProvider with ChangeNotifier {
  final ApiService _apiService;
  String _translatedText = '';
  bool _isLoading = false;
  String _error = '';

  TranslationProvider({ApiService? apiService}) : _apiService = apiService ?? ApiService();

  String get translatedText => _translatedText;
  bool get isLoading => _isLoading;
  String get error => _error;

  Future<void> translate(String text, String from, String to) async {
    if (text.isEmpty) return;
    
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final response = await _apiService.translateText(text, from, to);
      if (response.statusCode == 200) {
        // Mocking the response structure based on common translation APIs (MyMemory)
        _translatedText = response.data['responseData']?['translatedText'] ?? '';
      } else {
        _error = 'Translation failed';
      }
    } catch (e) {
      _error = 'Network error: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clear() {
    _translatedText = '';
    _error = '';
    notifyListeners();
  }
}
