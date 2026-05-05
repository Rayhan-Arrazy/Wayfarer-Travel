import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:wayfarer/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('end-to-end test', () {
    testWidgets('login flow test', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Check if we are already logged in (Home screen instead of Login screen)
      if (find.text('Email').evaluate().isEmpty) {
        // 0. Perform Logout first
        // Try to open the drawer by swiping from the left
        await tester.dragFrom(const Offset(0, 300), const Offset(300, 0));
        await tester.pumpAndSettle();

        final logoutButton = find.text('Logout');
        if (logoutButton.evaluate().isNotEmpty) {
          await tester.tap(logoutButton);
          await tester.pumpAndSettle();
        }
      }

      // Now we should be on the Login screen
      // 1. Find the email and password fields
      final emailField = find.widgetWithText(TextFormField, 'Email');
      final passwordField = find.widgetWithText(TextFormField, 'Password');
      final signInButton = find.text('Sign In');

      // 2. Enter credentials
      await tester.enterText(emailField, 'rayhan@wayfarer.com');
      await tester.enterText(passwordField, 'password123');

      // Close keyboard if necessary
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      // 3. Tap the Sign In button
      await tester.tap(signInButton);

      // 4. Wait for the login process and navigation
      // We use pump() multiple times or pumpAndSettle() with a timeout
      await tester.pumpAndSettle();

      // 5. Verify navigation or state change
      // For example, looking for a unique element on the Home/Dashboard screen
      s// expect(find.text('Explore the World'), findsOneWidget);
    });
  });
}
