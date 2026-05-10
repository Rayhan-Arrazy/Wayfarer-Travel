import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:wayfarer/providers/trip_provider.dart';
import 'package:wayfarer/services/api_service.dart';
import 'package:wayfarer/models/trip_model.dart';

class MockApiService extends Mock implements ApiService {}

void main() {
  late TripProvider tripProvider;
  late MockApiService mockApiService;

  setUp(() {
    mockApiService = MockApiService();
    tripProvider = TripProvider(apiService: mockApiService);
  });

  group('Planning Feature - TripProvider Scenarios', () {
    test('TP-01 [Positive] fetchTrips updates trips list on success', () async {
      final tTripsJson = [
        {
          '_id': '1',
          'destination': 'Bali',
          'countryCode': 'ID',
          'startDate': '2024-08-01T00:00:00.000Z',
          'endDate': '2024-08-10T00:00:00.000Z',
        }
      ];

      when(() => mockApiService.getTrips()).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ''),
          data: tTripsJson,
          statusCode: 200,
        ),
      );

      await tripProvider.fetchTrips();

      expect(tripProvider.trips.length, 1);
      expect(tripProvider.trips.first.destination, 'Bali');
      expect(tripProvider.isLoading, isFalse);
    });

    test('TP-02 [Negative] fetchTrips handles error gracefully', () async {
      when(() => mockApiService.getTrips()).thenThrow(
        DioException(requestOptions: RequestOptions(path: ''), type: DioExceptionType.connectionError),
      );

      await tripProvider.fetchTrips();

      expect(tripProvider.trips, isEmpty);
      expect(tripProvider.isLoading, isFalse);
    });

    test('TP-03 [Positive] createTrip returns true on success', () async {
      final tTrip = TripModel(
        id: 'new',
        userId: 'u1',
        destination: 'Swiss',
        countryCode: 'CH',
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 7)),
      );

      when(() => mockApiService.createTrip(any())).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 201,
        ),
      );
      
      when(() => mockApiService.getTrips()).thenAnswer(
        (_) async => Response(requestOptions: RequestOptions(path: ''), data: [], statusCode: 200),
      );

      final result = await tripProvider.createTrip(tTrip);

      expect(result, isTrue);
      verify(() => mockApiService.createTrip(any())).called(1);
    });
  });
}
