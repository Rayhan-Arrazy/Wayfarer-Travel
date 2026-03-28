import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../config/constants.dart';
import '../models/guide_model.dart';

class GuideProvider with ChangeNotifier {
  final Dio _dio = Dio(BaseOptions(baseUrl: AppConstants.baseUrl));
  List<CountryGuideModel> _guides = [];
  bool _isLoading = false;

  List<CountryGuideModel> get guides => _guides;
  bool get isLoading => _isLoading;

  Future<void> fetchGuides() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Corrected endpoint from previous thought or assuming /guides
      final response = await _dio.get('/guides');
      if (response.statusCode == 200) {
        _guides = (response.data as List).map((g) => CountryGuideModel.fromJson(g)).toList();
      }
    } catch (e) {
      debugPrint('Error fetching guides: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
