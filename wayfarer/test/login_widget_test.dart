import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:wayfarer/screens/auth/login_screen.dart';
import 'package:wayfarer/providers/auth_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('LoginScreen should have email and password fields', (WidgetTester tester) async {
    // Provide the AuthProvider
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider(
          create: (_) => AuthProvider(),
          child: const LoginScreen(),
        ),
      ),
    );

    // Initial pump to start animations
    await tester.pump();
    // Pump again to finish animations (Fade/Slide)
    await tester.pump(const Duration(seconds: 2));

    // Verify 'Wayfarer' title
    expect(find.text('Wayfarer'), findsOneWidget);

    // Verify form fields
    expect(find.byType(TextFormField), findsNWidgets(2));
    
    // Verify specific labels or icons
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);

    // Verify Sign In button
    expect(find.text('Sign In'), findsOneWidget);
  });

  testWidgets('LoginScreen show validation errors when empty fields', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider(
          create: (_) => AuthProvider(),
          child: const LoginScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Tap the Sign In button
    final signInButton = find.text('Sign In');
    await tester.tap(signInButton);
    await tester.pump();

    // Verify validation error messages
    expect(find.text('Email is required'), findsOneWidget);
    expect(find.text('Password is required'), findsOneWidget);
  });
}
