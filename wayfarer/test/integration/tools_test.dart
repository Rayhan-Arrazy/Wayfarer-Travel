import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:wayfarer/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Tools Integration Tests', () {
    testWidgets('navigate to tools and use currency converter', (tester) async {
      app.main();
      await tester.pumpAndSettle();

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

    testWidgets('verify translation section in tools', (tester) async {
      app.main();
      await tester.pumpAndSettle();

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

      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -500));
      await tester.pumpAndSettle();

      expect(find.text('Text Translation'), findsOneWidget);
      expect(find.text('TRANSLATE'), findsOneWidget);
    });
  });
}
