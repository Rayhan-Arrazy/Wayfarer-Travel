import 'package:flutter/material.dart';
import '../models/budget_model.dart';
import '../services/api_service.dart';

class BudgetProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<BudgetModel> _budgets = [];
  bool _isLoading = false;

  List<BudgetModel> get budgets => _budgets;
  bool get isLoading => _isLoading;

  Future<void> fetchBudgets() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.getBudgets();
      if (response.statusCode == 200) {
        _budgets = (response.data as List).map((b) => BudgetModel.fromJson(b)).toList();
      }
    } catch (e) {
      debugPrint('Error fetching budgets: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createBudget(BudgetModel budget) async {
    try {
      final response = await _apiService.createBudget(budget.toJson());
      if (response.statusCode == 201) {
        await fetchBudgets();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error creating budget: $e');
      return false;
    }
  }

  Future<bool> updateBudget(String id, BudgetModel budget) async {
    try {
      final response = await _apiService.updateBudget(id, budget.toJson());
      if (response.statusCode == 200) {
        await fetchBudgets();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error updating budget: $e');
      return false;
    }
  }

  Future<bool> deleteBudget(String id) async {
    try {
      final response = await _apiService.deleteBudget(id);
      if (response.statusCode == 200) {
        await fetchBudgets();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error deleting budget: $e');
      return false;
    }
  }

  // Helper: Find budget for specific trip or create a new one if none exists
  BudgetModel? getBudgetForTrip(String tripId) {
    try {
      return _budgets.firstWhere((b) => b.tripId == tripId);
    } catch (_) {
      return null;
    }
  }
}
