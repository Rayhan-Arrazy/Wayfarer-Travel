import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../models/trip_model.dart';
import '../config/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TripProvider with ChangeNotifier {
  final Dio _dio = Dio(BaseOptions(baseUrl: AppConstants.baseUrl));
  List<TripModel> _trips = [];
  TripModel? _upcomingTrip;
  bool _isLoading = false;

  List<TripModel> get trips => _trips;
  TripModel? get upcomingTrip => _upcomingTrip;
  bool get isLoading => _isLoading;

  Future<void> fetchTrips() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConstants.tokenKey);
      
      if (token == null) return;

      final response = await _dio.get(
        '/trips',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        _trips = (response.data as List).map((t) => TripModel.fromJson(t)).toList();
        
        // Find the "upcoming" trip (first one for now, or logic based on date)
        if (_trips.isNotEmpty) {
          _upcomingTrip = _trips.first;
        }
      }
    } catch (e) {
      debugPrint('Error fetching trips: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setUpcomingTrip(TripModel trip) {
    _upcomingTrip = trip;
    notifyListeners();
  }
}
