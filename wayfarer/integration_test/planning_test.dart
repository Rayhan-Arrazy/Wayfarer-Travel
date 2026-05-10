import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wayfarer/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  group('Planning Integration Tests', () {
    testWidgets('navigate to planning and view trips', (tester) async {
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

      final planNavItem = find.text('Plan');
      await tester.tap(planNavItem);
      await tester.pumpAndSettle();

      expect(find.text('My Trips'), findsOneWidget);
    });
  });
}
