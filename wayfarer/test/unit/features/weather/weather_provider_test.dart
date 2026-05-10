import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:wayfarer/providers/weather_provider.dart';
import 'package:wayfarer/services/api_service.dart';

class MockApiService extends Mock implements ApiService {}

void main() {
  late WeatherProvider weatherProvider;
  late MockApiService mockApiService;

  setUp(() {
    mockApiService = MockApiService();
    weatherProvider = WeatherProvider(apiService: mockApiService);
  });

  group('Weather Feature - WeatherProvider Scenarios', () {
    test('W-01 [Positive] fetchWeather success updates data', () async {
      final tData = <String, dynamic>{'temperature': 25, 'status': 'Sunny'};
      when(() => mockApiService.getWeather(any(), any())).thenAnswer(
        (_) async => Response(requestOptions: RequestOptions(path: ''), data: tData, statusCode: 200),
      );
      await weatherProvider.fetchWeather(0, 0);
      expect(weatherProvider.currentWeather?['temperature'], 25);
      expect(weatherProvider.isLoading, isFalse);
    });

    test('W-02 [Negative] fetchWeather error status code', () async {
      when(() => mockApiService.getWeather(any(), any())).thenAnswer(
        (_) async => Response(requestOptions: RequestOptions(path: ''), statusCode: 500),
      );
      await weatherProvider.fetchWeather(0, 0);
      expect(weatherProvider.error, contains('Failed'));
      expect(weatherProvider.isLoading, isFalse);
    });

    test('W-03 [Negative] fetchWeather exception handling', () async {
      when(() => mockApiService.getWeather(any(), any())).thenThrow(Exception('Net Error'));
      await weatherProvider.fetchWeather(0, 0);
      expect(weatherProvider.error, contains('Net Error'));
    });

    test('W-04 [Positive] getWeatherStatus returns status', () {
      final status = weatherProvider.getWeatherStatus({'status': 'Rain'});
      expect(status, 'Rain');
    });

    test('W-05 [Positive] getWeatherStatus returns default on null', () {
      final status = weatherProvider.getWeatherStatus(null);
      expect(status, 'Unknown');
    });

    test('W-06 [Positive] isLoading state sequence', () async {
      when(() => mockApiService.getWeather(any(), any())).thenAnswer(
        (_) async => Response(requestOptions: RequestOptions(path: ''), data: {}, statusCode: 200),
      );
      final future = weatherProvider.fetchWeather(0, 0);
      expect(weatherProvider.isLoading, isTrue);
      await future;
      expect(weatherProvider.isLoading, isFalse);
    });

    test('W-07 [Positive] reset error on new fetch', () async {
      when(() => mockApiService.getWeather(any(), any())).thenThrow(Exception('Err'));
      await weatherProvider.fetchWeather(0, 0);
      expect(weatherProvider.error, isNotEmpty);
      
      when(() => mockApiService.getWeather(any(), any())).thenAnswer(
        (_) async => Response(requestOptions: RequestOptions(path: ''), data: {}, statusCode: 200),
      );
      await weatherProvider.fetchWeather(0, 0);
      expect(weatherProvider.error, isEmpty);
    });

    test('W-08 [Positive] getWeatherStatus handles missing status key', () {
      final status = weatherProvider.getWeatherStatus({'temp': 20});
      expect(status, 'Clear');
    });

    test('W-09 [Negative] fetchWeather with extreme coordinates', () async {
      when(() => mockApiService.getWeather(any(), any())).thenAnswer(
        (_) async => Response(requestOptions: RequestOptions(path: ''), data: {}, statusCode: 200),
      );
      await weatherProvider.fetchWeather(90.0, 180.0);
      expect(weatherProvider.isLoading, isFalse);
    });

    test('W-10 [Positive] Provider notifies listeners', () async {
      int count = 0;
      weatherProvider.addListener(() => count++);
      when(() => mockApiService.getWeather(any(), any())).thenAnswer(
        (_) async => Response(requestOptions: RequestOptions(path: ''), data: {}, statusCode: 200),
      );
      await weatherProvider.fetchWeather(0, 0);
      expect(count, greaterThan(0));
    });
  });
}
