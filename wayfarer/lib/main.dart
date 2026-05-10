import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'config/theme.dart';
import 'config/routes.dart';
import 'providers/auth_provider.dart';
import 'providers/trip_provider.dart';
import 'providers/journal_provider.dart';
import 'providers/budget_provider.dart';
import 'providers/guide_provider.dart';
import 'providers/currency_provider.dart';
import 'providers/navigation_provider.dart';
import 'providers/translation_provider.dart';
import 'services/tts_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // CRITICAL: Prevent google_fonts from downloading fonts at runtime.
  // In release mode, runtime font fetching can crash the app before
  // any UI renders. This forces it to use bundled/system fonts instead.
  GoogleFonts.config.allowRuntimeFetching = false;

  // Global error handler — catches any unhandled Flutter framework errors
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('FlutterError: ${details.exceptionAsString()}');
  };

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: AppTheme.lightBg,
  ));

  // Wrap in runZonedGuarded to catch async errors that would otherwise crash
  runZonedGuarded(() {
    runApp(const WayfarerApp());
  }, (error, stackTrace) {
    debugPrint('Uncaught error: $error');
    debugPrint('Stack trace: $stackTrace');
  });
}

class WayfarerApp extends StatelessWidget {
  const WayfarerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..init()),
        ChangeNotifierProvider(create: (_) => TripProvider()),
        ChangeNotifierProvider(create: (_) => JournalProvider()),
        ChangeNotifierProvider(create: (_) => GuideProvider()),
        ChangeNotifierProvider(create: (_) => CurrencyProvider()),
        ChangeNotifierProvider(create: (_) => BudgetProvider()),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProvider(create: (_) => TranslationProvider()),
        Provider(create: (_) => TtsService()..init()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          return MaterialApp(
            title: 'Wayfarer',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            routes: AppRoutes.routes,
            onGenerateRoute: AppRoutes.onGenerateRoute,
            initialRoute: AppRoutes.root,
          );
        },
      ),
    );
  }
}
