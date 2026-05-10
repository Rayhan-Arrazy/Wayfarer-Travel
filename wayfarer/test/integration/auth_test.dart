import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:wayfarer/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Auth Integration Tests', () {
    testWidgets('login flow test', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      if (find.text('Email').evaluate().isEmpty) {
        await tester.dragFrom(const Offset(0, 300), const Offset(300, 0));
        await tester.pumpAndSettle();

        final logoutButton = find.text('Logout');
        if (logoutButton.evaluate().isNotEmpty) {
          await tester.tap(logoutButton);
          await tester.pumpAndSettle();
        }
      }

      final emailField = find.widgetWithText(TextFormField, 'Email');
      final passwordField = find.widgetWithText(TextFormField, 'Password');
      final signInButton = find.text('Sign In');

      await tester.enterText(emailField, 'rayhan@wayfarer.com');
      await tester.enterText(passwordField, 'password123');

      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      await tester.tap(signInButton);
      await tester.pumpAndSettle();
    });
  });
}
