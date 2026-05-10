import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../config/constants.dart';
import 'dart:convert';

class AuthProvider extends ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isAuthenticated = false;
  bool _isGuest = false;
  
  final ApiService _apiService;

  AuthProvider({ApiService? apiService}) : _apiService = apiService ?? ApiService();

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _isAuthenticated;
  bool get isGuest => _isGuest;
  bool get isAdmin => _user?.isAdmin ?? false;

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();
    try {
      await _apiService.init();
      if (_apiService.token != null) {
        await loadUser();
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register(String name, String email, String password, {String? homeCurrency}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.register(name, email, password, homeCurrency: homeCurrency);
      final data = response.data;

      _user = UserModel.fromJson(data['user']);
      _isAuthenticated = true;

      // Save token
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.tokenKey, data['token']);
      await prefs.setString(AppConstants.userKey, jsonEncode(data['user']));
      _apiService.setToken(data['token']);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = _extractError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.login(email, password);
      final data = response.data;

      _user = UserModel.fromJson(data['user']);
      _isAuthenticated = true;

      // Save token
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.tokenKey, data['token']);
      await prefs.setString(AppConstants.userKey, jsonEncode(data['user']));
      _apiService.setToken(data['token']);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = _extractError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> loadUser() async {
    try {
      final response = await _apiService.getProfile();
      _user = UserModel.fromJson(response.data);
      _isAuthenticated = true;
    } catch (e) {
      // Try loading from cache
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString(AppConstants.userKey);
      if (userData != null) {
        _user = UserModel.fromJson(jsonDecode(userData));
        _isAuthenticated = true;
      } else {
        _isAuthenticated = false;
      }
    }
    notifyListeners();
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _apiService.updateProfile(data);
      _user = UserModel.fromJson(response.data);
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.userKey, jsonEncode(response.data));
    } catch (e) {
      _errorMessage = _extractError(e);
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> logout() async {
    _user = null;
    _isAuthenticated = false;
    _isGuest = false;
    _apiService.setToken(null);
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.tokenKey);
    await prefs.remove(AppConstants.userKey);
    
    notifyListeners();
  }

  void continueAsGuest() {
    _isGuest = true;
    _isAuthenticated = true; // Treat guest as authenticated for navigation purposes
    _user = UserModel(
      id: 'guest',
      name: 'Guest User',
      email: 'guest@wayfarer.local',
    );
    notifyListeners();
  }

  String _extractError(dynamic e) {
    if (e is Exception) {
      try {
        final dioError = e as dynamic;
        return dioError.response?.data?['message'] ?? 'An error occurred';
      } catch (_) {}
    }
    return 'An error occurred. Please try again.';
  }
}
