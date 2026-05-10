import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:wayfarer/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Journal Integration Tests', () {
    testWidgets('navigate to journal and view entries', (tester) async {
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

      final journalNavItem = find.text('Journal');
      await tester.tap(journalNavItem);
      await tester.pumpAndSettle();

      expect(find.text('My Travel Journal'), findsOneWidget);
    });
  });
}
