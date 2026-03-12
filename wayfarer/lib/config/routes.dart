import 'package:flutter/material.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/trip_planner/trip_list_screen.dart';
import '../screens/trip_planner/create_trip_screen.dart';
import '../screens/trip_planner/trip_detail_screen.dart';
import '../screens/map/map_screen.dart';
import '../screens/currency/currency_screen.dart';
import '../screens/weather/weather_screen.dart';
import '../screens/food/food_screen.dart';
import '../screens/accommodation/accommodation_screen.dart';
import '../screens/transport/transport_screen.dart';
import '../screens/journal/journal_screen.dart';
import '../screens/journal/create_journal_entry_screen.dart';
import '../screens/emergency/emergency_screen.dart';
import '../screens/admin/admin_dashboard_screen.dart';
import '../screens/profile/profile_screen.dart';

class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String trips = '/trips';
  static const String createTrip = '/trips/create';
  static const String tripDetail = '/trips/detail';
  static const String map = '/map';
  static const String currency = '/currency';
  static const String weather = '/weather';
  static const String food = '/food';
  static const String accommodation = '/accommodation';
  static const String transport = '/transport';
  static const String journal = '/journal';
  static const String createJournal = '/journal/create';
  static const String emergency = '/emergency';
  static const String admin = '/admin';
  static const String profile = '/profile';

  static Map<String, WidgetBuilder> get routes => {
    login: (_) => const LoginScreen(),
    register: (_) => const RegisterScreen(),
    home: (_) => const HomeScreen(),
    trips: (_) => const TripListScreen(),
    createTrip: (_) => const CreateTripScreen(),
    map: (_) => const MapScreen(),
    currency: (_) => const CurrencyScreen(),
    weather: (_) => const WeatherScreen(),
    food: (_) => const FoodScreen(),
    accommodation: (_) => const AccommodationScreen(),
    transport: (_) => const TransportScreen(),
    journal: (_) => const JournalScreen(),
    createJournal: (_) => const CreateJournalEntryScreen(),
    emergency: (_) => const EmergencyScreen(),
    admin: (_) => const AdminDashboardScreen(),
    profile: (_) => const ProfileScreen(),
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
