import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wayfarer/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  group('Tools Integration Tests', () {
    testWidgets('navigate to tools and use currency converter', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Login first if needed
      final emailField = find.widgetWithText(TextFormField, 'Email');
      if (emailField.evaluate().isNotEmpty) {
        final passwordField = find.widgetWithText(TextFormField, 'Password');
        final signInButton = find.text('Sign In');
        await tester.enterText(emailField, 'rayhan@wayfarer.com');
        await tester.enterText(passwordField, 'password123');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();
        await tester.tap(signInButton);
        await tester.pumpAndSettle();
      }

      final drawerIcon = find.byIcon(Icons.menu);
      if (drawerIcon.evaluate().isNotEmpty) {
        await tester.tap(drawerIcon);
        await tester.pumpAndSettle();
      } else {
        await tester.dragFrom(const Offset(0, 300), const Offset(300, 0));
        await tester.pumpAndSettle();
      }

      final toolsNavItem = find.text('Tools');
      await tester.tap(toolsNavItem);
      await tester.pumpAndSettle();

      expect(find.text('Traveler Utility Tools'), findsOneWidget);
      expect(find.text('Currency Converter'), findsOneWidget);

      final amountField = find.byType(TextField).first;
      await tester.enterText(amountField, '100');
      await tester.pumpAndSettle();
    });
  });
}
