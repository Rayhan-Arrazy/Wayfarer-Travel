import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wayfarer/widgets/loading_widget.dart';

void main() {
  testWidgets('LoadingWidget displays Wayfarer text and circular progress indicator', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MaterialApp(home: LoadingWidget()));

    // Verify that the text 'Wayfarer' is present.
    expect(find.text('Wayfarer'), findsOneWidget);

    // Verify that the text 'PREPARING YOUR JOURNEY' is present.
    expect(find.text('PREPARING YOUR JOURNEY'), findsOneWidget);

    // Verify that a CircularProgressIndicator is present.
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
