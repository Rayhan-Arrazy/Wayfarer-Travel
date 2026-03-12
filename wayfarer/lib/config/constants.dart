class AppConstants {
  // API Base URL - change this to your server IP/domain
  static const String baseUrl = 'http://10.0.2.2:5000/api'; // Android emulator
  // static const String baseUrl = 'http://localhost:5000/api'; // iOS simulator / Web
  
  // App Info
  static const String appName = 'Wayfarer';
  static const String appTagline = 'Your Journey, Your Story';
  static const String appVersion = '1.0.0';

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String themeKey = 'theme_mode';
  static const String currencyKey = 'home_currency';

  // Default values
  static const String defaultCurrency = 'USD';
  static const int apiTimeout = 15000; // milliseconds

  // Map defaults
  static const double defaultLat = 0.0;
  static const double defaultLng = 0.0;
  static const double defaultZoom = 13.0;
}
