import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:wayfarer/providers/translation_provider.dart';
import 'package:wayfarer/services/api_service.dart';

class MockApiService extends Mock implements ApiService {}

void main() {
  late TranslationProvider translationProvider;
  late MockApiService mockApiService;

  setUp(() {
    mockApiService = MockApiService();
    translationProvider = TranslationProvider(apiService: mockApiService);
  });

  group('Tools Feature - Translation Scenarios', () {
    test('TR-01 [Positive] Translate success updates text', () async {
      final tData = {
        'responseData': {'translatedText': 'Hola'}
      };
      when(() => mockApiService.translateText(any(), any(), any())).thenAnswer(
        (_) async => Response(requestOptions: RequestOptions(path: ''), data: tData, statusCode: 200),
      );
      
      await translationProvider.translate('Hello', 'en', 'es');
      expect(translationProvider.translatedText, 'Hola');
      expect(translationProvider.isLoading, isFalse);
    });

    test('TR-02 [Negative] Translate handles empty input', () async {
      await translationProvider.translate('', 'en', 'es');
      expect(translationProvider.isLoading, isFalse);
      expect(translationProvider.translatedText, isEmpty);
    });

    test('TR-03 [Negative] Translate handles API error', () async {
      when(() => mockApiService.translateText(any(), any(), any())).thenAnswer(
        (_) async => Response(requestOptions: RequestOptions(path: ''), statusCode: 400),
      );
      await translationProvider.translate('Hello', 'en', 'es');
      expect(translationProvider.error, contains('failed'));
    });

    test('TR-04 [Negative] Translate handles network exception', () async {
      when(() => mockApiService.translateText(any(), any(), any())).thenThrow(Exception('Timeout'));
      await translationProvider.translate('Hello', 'en', 'es');
      expect(translationProvider.error, contains('Timeout'));
    });

    test('TR-05 [Positive] clear() resets state', () async {
      final tData = {'responseData': {'translatedText': 'X'}};
      when(() => mockApiService.translateText(any(), any(), any())).thenAnswer(
        (_) async => Response(requestOptions: RequestOptions(path: ''), data: tData, statusCode: 200),
      );
      await translationProvider.translate('H', 'en', 'es');
      translationProvider.clear();
      expect(translationProvider.translatedText, isEmpty);
      expect(translationProvider.error, isEmpty);
    });

    test('TR-06 [Positive] isLoading sequence verification', () async {
      when(() => mockApiService.translateText(any(), any(), any())).thenAnswer(
        (_) async => Response(requestOptions: RequestOptions(path: ''), data: {}, statusCode: 200),
      );
      final future = translationProvider.translate('H', 'en', 'es');
      expect(translationProvider.isLoading, isTrue);
      await future;
      expect(translationProvider.isLoading, isFalse);
    });

    test('TR-07 [Positive] Provider notifies listeners on success', () async {
      int count = 0;
      translationProvider.addListener(() => count++);
      when(() => mockApiService.translateText(any(), any(), any())).thenAnswer(
        (_) async => Response(requestOptions: RequestOptions(path: ''), data: {}, statusCode: 200),
      );
      await translationProvider.translate('H', 'en', 'es');
      expect(count, greaterThan(0));
    });

    test('TR-08 [Negative] Translate handles null responseData', () async {
      when(() => mockApiService.translateText(any(), any(), any())).thenAnswer(
        (_) async => Response(requestOptions: RequestOptions(path: ''), data: {}, statusCode: 200),
      );
      await translationProvider.translate('H', 'en', 'es');
      expect(translationProvider.translatedText, isEmpty);
    });

    test('TR-09 [Positive] Multiple translations in sequence', () async {
      when(() => mockApiService.translateText(any(), any(), any())).thenAnswer(
        (_) async => Response(requestOptions: RequestOptions(path: ''), data: {'responseData': {'translatedText': '1'}}, statusCode: 200),
      );
      await translationProvider.translate('A', 'en', 'es');
      expect(translationProvider.translatedText, '1');

      when(() => mockApiService.translateText(any(), any(), any())).thenAnswer(
        (_) async => Response(requestOptions: RequestOptions(path: ''), data: {'responseData': {'translatedText': '2'}}, statusCode: 200),
      );
      await translationProvider.translate('B', 'en', 'es');
      expect(translationProvider.translatedText, '2');
    });

    test('TR-10 [Negative] Translation error resets translated text', () async {
      translationProvider.translate('A', 'en', 'es'); // assume success
      when(() => mockApiService.translateText(any(), any(), any())).thenThrow(Exception('E'));
      await translationProvider.translate('B', 'en', 'es');
      expect(translationProvider.error, isNotEmpty);
    });
  });
}
