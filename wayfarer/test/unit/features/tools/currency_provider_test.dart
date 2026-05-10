import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:wayfarer/providers/currency_provider.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late CurrencyProvider currencyProvider;
  late MockDio mockDio;

  setUp(() {
    mockDio = MockDio();
    currencyProvider = CurrencyProvider(dio: mockDio);
  });

  group('Tools Feature - CurrencyProvider Scenarios', () {
    test('C-01 [Positive] fetchRates updates rates on success', () async {
      final tRatesJson = {
        'rates': {
          'EUR': 0.92,
          'JPY': 150.0,
        }
      };

      when(() => mockDio.get(any())).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ''),
          data: tRatesJson,
          statusCode: 200,
        ),
      );

      await currencyProvider.fetchRates('USD');

      expect(currencyProvider.rates['EUR'], 0.92);
      expect(currencyProvider.rates['JPY'], 150.0);
      expect(currencyProvider.isLoading, isFalse);
    });

    test('C-02 [Positive] convert calculates correctly', () async {
      currencyProvider.rates.addAll({
        'USD': 1.0,
        'EUR': 0.9,
        'JPY': 150.0,
      });

      final result = currencyProvider.convert(100, 'USD', 'EUR');
      expect(result, 90.0);

      final result2 = currencyProvider.convert(1, 'EUR', 'JPY');
      expect(result2, closeTo(166.67, 0.01));
    });

    test('C-03 [Negative] fetchRates handles network error', () async {
      when(() => mockDio.get(any())).thenThrow(
        DioException(requestOptions: RequestOptions(path: ''), type: DioExceptionType.connectionError),
      );

      await currencyProvider.fetchRates();

      expect(currencyProvider.error, contains('connection error'));
      expect(currencyProvider.isLoading, isFalse);
    });
  });
}
