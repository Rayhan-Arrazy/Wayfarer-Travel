import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:wayfarer/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('end-to-end test', () {
    testWidgets('verify app starts and shows login screen elements', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Verify Wayfarer brand is present (common in login/loading)
      expect(find.text('Wayfarer'), findsOneWidget);
      
      // If the app starts at login, we should see the Sign In button
      // Note: This depends on the initial route and auth state
    });
  });
}
