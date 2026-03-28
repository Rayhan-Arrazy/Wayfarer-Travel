import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../models/journal_model.dart';
import '../config/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class JournalProvider with ChangeNotifier {
  final Dio _dio = Dio(BaseOptions(baseUrl: AppConstants.baseUrl));
  List<JournalEntryModel> _entries = [];
  bool _isLoading = false;

  List<JournalEntryModel> get entries => _entries;
  bool get isLoading => _isLoading;

  Future<void> fetchEntries({String? tripId}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConstants.tokenKey);
      
      if (token == null) return;

      final queryParams = <String, dynamic>{};
      if (tripId != null) queryParams['tripId'] = tripId;

      final response = await _dio.get(
        '/journal',
        queryParameters: queryParams,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        _entries = (response.data as List).map((e) => JournalEntryModel.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint('Error fetching journal entries: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createEntry(JournalEntryModel entry) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConstants.tokenKey);
      if (token == null) return false;

      final response = await _dio.post(
        '/journal',
        data: entry.toJson(),
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 201) {
        await fetchEntries();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error creating journal entry: $e');
      return false;
    }
  }

  Future<bool> updateEntry(String id, JournalEntryModel entry) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConstants.tokenKey);
      if (token == null) return false;

      final response = await _dio.put(
        '/journal/$id',
        data: entry.toJson(),
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        await fetchEntries();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error updating journal entry: $e');
      return false;
    }
  }

  Future<bool> deleteEntry(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConstants.tokenKey);
      if (token == null) return false;

      final response = await _dio.delete(
        '/journal/$id',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        await fetchEntries();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error deleting journal entry: $e');
      return false;
    }
  }
}
