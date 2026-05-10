import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:wayfarer/providers/journal_provider.dart';
import 'package:wayfarer/services/api_service.dart';
import 'package:wayfarer/models/journal_model.dart';

class MockApiService extends Mock implements ApiService {}

void main() {
  late JournalProvider journalProvider;
  late MockApiService mockApiService;

  setUp(() {
    mockApiService = MockApiService();
    journalProvider = JournalProvider(apiService: mockApiService);
  });

  group('Journal Feature - JournalProvider Scenarios', () {
    test('JP-01 [Positive] fetchEntries updates entries list on success', () async {
      final tEntriesJson = [
        {
          '_id': '1',
          'userId': 'u1',
          'tripId': 't1',
          'title': 'Bali Sunsets',
        }
      ];

      when(() => mockApiService.getJournalEntries(tripId: any(named: 'tripId'))).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ''),
          data: tEntriesJson,
          statusCode: 200,
        ),
      );

      await journalProvider.fetchEntries();

      expect(journalProvider.entries.length, 1);
      expect(journalProvider.entries.first.title, 'Bali Sunsets');
      expect(journalProvider.isLoading, isFalse);
    });

    test('JP-02 [Negative] fetchEntries handles error gracefully', () async {
      when(() => mockApiService.getJournalEntries(tripId: any(named: 'tripId'))).thenThrow(
        DioException(requestOptions: RequestOptions(path: ''), type: DioExceptionType.connectionError),
      );

      await journalProvider.fetchEntries();

      expect(journalProvider.entries, isEmpty);
      expect(journalProvider.isLoading, isFalse);
    });

    test('JP-03 [Positive] createEntry returns true on success', () async {
      final tEntry = JournalEntryModel(
        id: 'new',
        userId: 'u1',
        tripId: 't1',
        title: 'New Memory',
      );

      when(() => mockApiService.createJournalEntry(any())).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 201,
        ),
      );
      
      when(() => mockApiService.getJournalEntries(tripId: any(named: 'tripId'))).thenAnswer(
        (_) async => Response(requestOptions: RequestOptions(path: ''), data: [], statusCode: 200),
      );

      final result = await journalProvider.createEntry(tEntry);

      expect(result, isTrue);
      verify(() => mockApiService.createJournalEntry(any())).called(1);
    });
  });
}
