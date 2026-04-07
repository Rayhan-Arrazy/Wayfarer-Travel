import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/trip_planner/trip_list_screen.dart';
import '../screens/trip_planner/create_trip_screen.dart';
import '../screens/trip_planner/trip_detail_screen.dart';
import '../screens/map/map_screen.dart';
import '../screens/guide/guide_list_screen.dart';
import '../screens/weather/weather_screen.dart';
import '../screens/currency/currency_screen.dart';
import '../screens/journal/journal_screen.dart';
import '../screens/journal/add_journal_screen.dart';
import '../screens/journal/edit_journal_screen.dart';
import '../screens/trip_planner/itinerary_screen.dart';
import '../screens/trip_planner/activity_form_screen.dart';
import '../screens/trip_planner/edit_trip_screen.dart';
import '../screens/tools/budgeter_screen.dart';
import '../screens/tools/expense_form_screen.dart';
import '../screens/tools/tools_tab_screen.dart';
import '../screens/guide/continent_detail_screen.dart';
import '../providers/auth_provider.dart';
import '../widgets/loading_widget.dart';
import '../models/trip_model.dart';
import '../models/journal_model.dart';

class AppRoutes {
  static const String root = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String trips = '/trips';
  static const String createTrip = '/trips/create';
  static const String tripDetail = '/trips/detail';
  static const String map = '/map';
  static const String guides = '/guides';
  static const String weather = '/weather';
  static const String currency = '/currency';
  static const String journal = '/journal';
  static const String journalAdd = '/journal/add';
  static const String journalEdit = '/journal/edit';
  static const String continentDetail = '/continent-detail';
  static const String itinerary = '/itinerary';
  static const String activityForm = '/activity-form';
  static const String budgeter = '/budgeter';
  static const String expenseForm = '/expense-form';
  static const String tools = '/tools';
  static const String editTrip = '/trips/edit';

  static Map<String, WidgetBuilder> get routes => {
    root: (_) => const LoadingRedirect(),
    login: (_) => const LoginScreen(),
    register: (_) => const RegisterScreen(),
    home: (_) => const HomeScreen(),
    trips: (_) => const TripListScreen(),
    createTrip: (_) => const CreateTripScreen(),
    map: (_) => const MapScreen(),
    guides: (_) => const GuideListScreen(),
    weather: (_) => const WeatherScreen(),
    currency: (_) => const CurrencyScreen(),
    journal: (_) => const JournalScreen(),
    journalAdd: (_) => const AddJournalScreen(),
    itinerary: (_) => const ItineraryScreen(),
    budgeter: (_) => const BudgeterScreen(),
    tools: (_) => const ToolsTabScreen(),
  };

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case tripDetail:
        final tripId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => TripDetailScreen(tripId: tripId),
        );
      case expenseForm:
        final data = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => ExpenseFormScreen(initialData: data),
        );
      case activityForm:
        final data = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => ActivityFormScreen(initialData: data),
        );
      case editTrip:
        final trip = settings.arguments as TripModel;
        return MaterialPageRoute(
          builder: (_) => EditTripScreen(trip: trip),
        );
      case journalEdit:
        final entry = settings.arguments as JournalEntryModel;
        return MaterialPageRoute(
          builder: (_) => EditJournalScreen(entry: entry),
        );
      case continentDetail:
        final continent = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => ContinentDetailScreen(continent: continent),
        );
      default:
        return null;
    }
  }
}

class LoadingRedirect extends StatelessWidget {
  const LoadingRedirect({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    
    if (auth.isLoading) {
      return const LoadingWidget();
    }

    if (auth.isAuthenticated) {
      return const HomeScreen();
    }

    // Auto-login as guest for development convenience
    WidgetsBinding.instance.addPostFrameCallback((_) {
      auth.continueAsGuest();
    });

    return const LoadingWidget();
  }
}
