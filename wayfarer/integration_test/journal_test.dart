import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wayfarer/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  group('Journal Integration Tests', () {
    testWidgets('navigate to journal and view entries', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Ensure we are logged out first to force "MUST LOGIN"
      final drawerIconCheck = find.byIcon(Icons.menu);
      if (drawerIconCheck.evaluate().isNotEmpty) {
        await tester.tap(drawerIconCheck);
        await tester.pumpAndSettle();
        final logoutButton = find.text('Logout');
        if (logoutButton.evaluate().isNotEmpty) {
          await tester.tap(logoutButton);
          await tester.pumpAndSettle();
        }
      }

      // MUST LOGIN logic
      final emailField = find.widgetWithText(TextFormField, 'Email');
      final passwordField = find.widgetWithText(TextFormField, 'Password');
      final signInButton = find.text('Sign In');

      expect(emailField, findsOneWidget, reason: 'Login is REQUIRED for Journal');
      
      await tester.enterText(emailField, 'rayhan@wayfarer.com');
      await tester.enterText(passwordField, 'password123');
      await tester.tap(signInButton);
      await tester.pumpAndSettle();

      // Proceed to Journal
      final drawerIcon = find.byIcon(Icons.menu);
      if (drawerIcon.evaluate().isNotEmpty) {
        await tester.tap(drawerIcon);
        await tester.pumpAndSettle();
      } else {
        await tester.dragFrom(const Offset(0, 300), const Offset(300, 0));
        await tester.pumpAndSettle();
      }

      final journalNavItem = find.text('Journal');
      await tester.tap(journalNavItem);
      await tester.pumpAndSettle();

      // Real UI Label Check
      expect(find.text('Your Journey.'), findsOneWidget);

      // Tap on a journal card to open details
      final journalCard = find.byIcon(Icons.location_on).first;
      if (journalCard.evaluate().isNotEmpty) {
        await tester.tap(journalCard);
        await tester.pumpAndSettle();
      }
    });
  });
}
