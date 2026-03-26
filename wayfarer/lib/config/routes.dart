import 'package:flutter/material.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/trip_planner/trip_list_screen.dart';
import '../screens/trip_planner/create_trip_screen.dart';
import '../screens/trip_planner/trip_detail_screen.dart';
import '../screens/map/map_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/favorites/favorites_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/guide/guide_list_screen.dart';
import '../screens/weather/weather_screen.dart';
import '../screens/currency/currency_screen.dart';
import '../screens/journal/journal_screen.dart';
import '../screens/emergency/emergency_screen.dart';
import '../screens/transport/transport_screen.dart';
import '../screens/food/food_screen.dart';
import '../screens/accommodation/accommodation_screen.dart';

class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String trips = '/trips';
  static const String createTrip = '/trips/create';
  static const String tripDetail = '/trips/detail';
  static const String map = '/map';
  static const String profile = '/profile';
  static const String favorites = '/favorites';
  static const String settings = '/settings';
  static const String guides = '/guides';
  static const String weather = '/weather';
  static const String currency = '/currency';
  static const String journal = '/journal';
  static const String emergency = '/emergency';
  static const String transport = '/transport';
  static const String food = '/food';
  static const String accommodation = '/accommodation';

  static Map<String, WidgetBuilder> get routes => {
    login: (_) => const LoginScreen(),
    register: (_) => const RegisterScreen(),
    home: (_) => const HomeScreen(),
    trips: (_) => const TripListScreen(),
    createTrip: (_) => const CreateTripScreen(),
    map: (_) => const MapScreen(),
    profile: (_) => const ProfileScreen(),
    favorites: (_) => const FavoritesScreen(),
    settings: (_) => const SettingsScreen(),
    guides: (_) => const GuideListScreen(),
    weather: (_) => const WeatherScreen(),
    currency: (_) => const CurrencyScreen(),
    journal: (_) => const JournalScreen(),
    emergency: (_) => const EmergencyScreen(),
    transport: (_) => const TransportScreen(),
    food: (_) => const FoodScreen(),
    accommodation: (_) => const AccommodationScreen(),
  };

  /// Use onGenerateRoute for screens that need arguments
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case tripDetail:
        final tripId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => TripDetailScreen(tripId: tripId),
        );
      default:
        return null;
    }
  }
}
