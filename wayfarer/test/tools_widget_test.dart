import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wayfarer/screens/tools/tools_tab_screen.dart';
import 'package:wayfarer/providers/currency_provider.dart';
import 'package:wayfarer/providers/translation_provider.dart';
import 'package:wayfarer/services/tts_service.dart';
import 'package:google_fonts/google_fonts.dart';

class MockCurrencyProvider extends Mock implements CurrencyProvider {}
class MockTranslationProvider extends Mock implements TranslationProvider {}
class MockTtsService extends Mock implements TtsService {}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('ToolsTabScreen basic render test', (WidgetTester tester) async {
    final mockCurrency = MockCurrencyProvider();
    final mockTranslation = MockTranslationProvider();
    final mockTts = MockTtsService();

    when(() => mockCurrency.rates).thenReturn({});
    when(() => mockCurrency.isLoading).thenReturn(false);
    when(() => mockCurrency.fetchRates(any())).thenAnswer((_) async {});
    
    when(() => mockTranslation.translatedText).thenReturn('Hello');
    when(() => mockTranslation.isLoading).thenReturn(false);
    
    when(() => mockTts.init()).thenAnswer((_) async {});

    await tester.pumpWidget(
      MaterialApp(
        home: MultiProvider(
          providers: [
            ChangeNotifierProvider<CurrencyProvider>.value(value: mockCurrency),
            ChangeNotifierProvider<TranslationProvider>.value(value: mockTranslation),
            Provider<TtsService>.value(value: mockTts),
          ],
          child: const Scaffold(body: ToolsTabScreen()),
        ),
      ),
    );

    await tester.pump();
    expect(find.text('Currency Converter'), findsOneWidget);
  });
}
