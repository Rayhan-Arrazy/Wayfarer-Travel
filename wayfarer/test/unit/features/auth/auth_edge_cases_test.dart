import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wayfarer/providers/auth_provider.dart';
import 'package:wayfarer/services/api_service.dart';

class MockApiService extends Mock implements ApiService {}

void main() {
  late AuthProvider authProvider;
  late MockApiService mockApiService;

  setUp(() {
    mockApiService = MockApiService();
    authProvider = AuthProvider(apiService: mockApiService);
    SharedPreferences.setMockInitialValues({});
  });

  group('Auth Feature - Edge Case Scenarios', () {
    test('L-05 [Negative] Empty email/password handling', () async {
      final result = await authProvider.login('', '');
      expect(result, isFalse);
    });

    test('L-06 [Negative] Network timeout on login', () async {
      when(() => mockApiService.login(any(), any())).thenThrow(DioException(
        requestOptions: RequestOptions(path: ''),
        type: DioExceptionType.connectionTimeout,
      ));
      final result = await authProvider.login('t@t.com', 'p');
      expect(result, isFalse);
    });

    test('R-04 [Positive] Register with optional homeCurrency', () async {
      when(() => mockApiService.register(any(), any(), any(), homeCurrency: 'EUR')).thenAnswer(
        (_) async => Response(requestOptions: RequestOptions(path: ''), data: {'token': 't', 'user': {'_id': '1', 'name': 'N', 'email': 'E'}}, statusCode: 201),
      );
      final result = await authProvider.register('N', 'E', 'P', homeCurrency: 'EUR');
      expect(result, isTrue);
    });

    test('U-04 [Positive] continueAsGuest sets guest state', () {
      authProvider.continueAsGuest();
      expect(authProvider.isGuest, isTrue);
      expect(authProvider.isAuthenticated, isTrue);
      expect(authProvider.user?.name, 'Guest User');
    });

    test('U-05 [Positive] logout clears all states', () async {
      authProvider.continueAsGuest();
      await authProvider.logout();
      expect(authProvider.isAuthenticated, isFalse);
      expect(authProvider.user, isNull);
    });

    test('U-06 [Positive] updateProfile success', () async {
      final tUser = {'_id': '1', 'name': 'Updated', 'email': 'e@e.com'};
      when(() => mockApiService.updateProfile(any())).thenAnswer(
        (_) async => Response(requestOptions: RequestOptions(path: ''), data: tUser, statusCode: 200),
      );
      await authProvider.updateProfile({'name': 'Updated'});
      expect(authProvider.user?.name, 'Updated');
    });

    test('U-07 [Negative] updateProfile handles error', () async {
      when(() => mockApiService.updateProfile(any())).thenThrow(DioException(requestOptions: RequestOptions(path: '')));
      await authProvider.updateProfile({'name': 'Updated'});
      expect(authProvider.errorMessage, isNotNull);
    });

    test('U-08 [Positive] isAdmin helper logic', () {
      authProvider.continueAsGuest(); // Guest is not admin
      expect(authProvider.isAdmin, isFalse);
    });

    test('U-09 [Positive] register auto-saves token in prefs', () async {
      when(() => mockApiService.register(any(), any(), any())).thenAnswer(
        (_) async => Response(requestOptions: RequestOptions(path: ''), data: {'token': 'secret', 'user': {'_id': '1'}}, statusCode: 201),
      );
      await authProvider.register('N', 'E', 'P');
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('auth_token'), 'secret');
    });

    test('U-10 [Negative] login handles malformed response', () async {
      when(() => mockApiService.login(any(), any())).thenAnswer(
        (_) async => Response(requestOptions: RequestOptions(path: ''), data: {}, statusCode: 200),
      );
      final result = await authProvider.login('e', 'p');
      expect(result, isFalse);
    });
  });
}
