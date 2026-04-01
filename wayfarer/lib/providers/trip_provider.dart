import 'package:flutter/material.dart';
import '../models/trip_model.dart';
import '../services/api_service.dart';

class TripProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
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
      final response = await _apiService.getTrips();

      if (response.statusCode == 200) {
        _trips = (response.data as List).map((t) => TripModel.fromJson(t)).toList();
        
        // Ensure at least one trip for demonstration if empty
        if (_trips.isEmpty) {
          _trips.add(TripModel(
            id: '507f1f77bcf86cd799439011',
            userId: '507f191e810c19729de860ea',
            destination: 'Scandinavia Trip',
            countryCode: 'SE',
            countryName: 'Sweden',
            startDate: DateTime.now(),
            endDate: DateTime.now().add(const Duration(days: 14)),
            partySize: 2,
            notes: 'Test trip',
            status: 'active',
          ));
        }

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
    final active = _trips.where((t) => t.isActive).toList();
    if (active.isNotEmpty) {
      active.sort((a, b) => a.startDate.compareTo(b.startDate));
      return active.first;
    }
    final planning = _trips.where((t) => t.isPlanning).toList();
    if (planning.isNotEmpty) {
      planning.sort((a, b) => a.startDate.compareTo(b.startDate));
      return planning.first;
    }
    final completed = _trips.where((t) => t.isCompleted).toList();
    if (completed.isNotEmpty) {
      completed.sort((a, b) => b.endDate.compareTo(a.endDate));
      return completed.first;
    }
    return _trips.first;
  }

  Future<bool> createTrip(TripModel trip) async {
    try {
      final response = await _apiService.createTrip(trip.toJson());

      if (response.statusCode == 201) {
        await fetchTrips();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error creating trip: $e');
      return false;
    }
  }

  Future<bool> updateTrip(String id, TripModel trip) async {
    try {
      final response = await _apiService.updateTrip(id, trip.toJson());

      if (response.statusCode == 200) {
        await fetchTrips();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error updating trip: $e');
      return false;
    }
  }

  Future<bool> deleteTrip(String id) async {
    try {
      final response = await _apiService.deleteTrip(id);

      if (response.statusCode == 200) {
        await fetchTrips();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error deleting trip: $e');
      return false;
    }
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
