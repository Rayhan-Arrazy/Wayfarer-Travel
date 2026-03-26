import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../models/trip_model.dart';
import '../config/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TripProvider with ChangeNotifier {
  final Dio _dio = Dio(BaseOptions(baseUrl: AppConstants.baseUrl));
  List<TripModel> _trips = [];
  TripModel? _upcomingTrip;
  TripModel? _selectedTrip;
  bool _isLoading = false;

  List<TripModel> get trips => _trips;
  TripModel? get upcomingTrip => _upcomingTrip;
  TripModel? get selectedTrip => _selectedTrip ?? _upcomingTrip;
  bool get isLoading => _isLoading;

  List<TripModel> get activeTrips => _trips.where((t) => t.isActive).toList();
  List<TripModel> get planningTrips => _trips.where((t) => t.isPlanning).toList();
  List<TripModel> get completedTrips => _trips.where((t) => t.isCompleted).toList();

  Future<void> fetchTrips() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConstants.tokenKey);
      
      if (token == null) {
        _isLoading = false;
        notifyListeners();
        return;
      }

      final response = await _dio.get(
        '/trips',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        _trips = (response.data as List).map((t) => TripModel.fromJson(t)).toList();
        
        // Determine the "upcoming" trip intelligently:
        // 1. Prefer active trips (currently ongoing)
        // 2. Then planning trips closest to departure
        // 3. Fall back to the most recent trip
        _upcomingTrip = _findUpcomingTrip();
      }
    } catch (e) {
      debugPrint('Error fetching trips: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  TripModel? _findUpcomingTrip() {
    if (_trips.isEmpty) return null;

    // First: active trips
    final active = _trips.where((t) => t.isActive).toList();
    if (active.isNotEmpty) {
      active.sort((a, b) => a.startDate.compareTo(b.startDate));
      return active.first;
    }

    // Second: planning trips sorted by nearest start date
    final planning = _trips.where((t) => t.isPlanning).toList();
    if (planning.isNotEmpty) {
      planning.sort((a, b) => a.startDate.compareTo(b.startDate));
      return planning.first;
    }

    // Third: most recently completed
    final completed = _trips.where((t) => t.isCompleted).toList();
    if (completed.isNotEmpty) {
      completed.sort((a, b) => b.endDate.compareTo(a.endDate));
      return completed.first;
    }

    return _trips.first;
  }

  void setUpcomingTrip(TripModel trip) {
    _upcomingTrip = trip;
    notifyListeners();
  }

  void setSelectedTrip(TripModel? trip) {
    _selectedTrip = trip;
    notifyListeners();
  }
}
