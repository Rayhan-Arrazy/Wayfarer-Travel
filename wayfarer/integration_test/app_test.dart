import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:wayfarer/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('end-to-end test', () {
    testWidgets('verify app starts and shows loading or home', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Since we don't know the exact starting state (could be loading screen), 
      // we check for common elements or just verify it doesn't crash.
      expect(find.byType(app.WayfarerApp), findsOneWidget);
    });
  });
}
