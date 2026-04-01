import 'package:flutter/material.dart';
import '../models/journal_model.dart';
import '../services/api_service.dart';

class JournalProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<JournalEntryModel> _entries = [];
  bool _isLoading = false;

  List<JournalEntryModel> get entries => _entries;
  bool get isLoading => _isLoading;

  Future<void> fetchEntries({String? tripId}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.getJournalEntries(tripId: tripId);

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
      final response = await _apiService.createJournalEntry(entry.toJson());

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
      final response = await _apiService.updateJournalEntry(id, entry.toJson());

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
      final response = await _apiService.deleteJournalEntry(id);

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
