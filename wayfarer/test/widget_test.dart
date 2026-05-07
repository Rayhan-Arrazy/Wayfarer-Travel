import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wayfarer/widgets/loading_widget.dart';

void main() {
  testWidgets('LoadingWidget displays Wayfarer text and circular progress indicator', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoadingWidget()));

    expect(find.text('Wayfarer'), findsOneWidget);
    expect(find.text('PREPARING YOUR JOURNEY'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
