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

  group('Auth Feature - Login Scenarios', () {
    const tEmail = 'user@example.com';
    const tPassword = 'password123';
    const tToken = 'fake_token';
    final tUserJson = {
      '_id': '1',
      'name': 'Test User',
      'email': tEmail,
    };

    test('L-01 [Positive] Valid email & password', () async {
      when(() => mockApiService.login(any(), any())).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ''),
          data: {
            'token': tToken,
            'user': tUserJson,
          },
          statusCode: 200,
        ),
      );

      final result = await authProvider.login(tEmail, tPassword);

      expect(result, isTrue);
      expect(authProvider.isAuthenticated, isTrue);
      expect(authProvider.user?.email, tEmail);
      expect(authProvider.errorMessage, isNull);
      verify(() => mockApiService.login(tEmail, tPassword)).called(1);
      verify(() => mockApiService.setToken(tToken)).called(1);
    });

    test('L-02 [Negative] Wrong password (401 Unauthorized)', () async {
      when(() => mockApiService.login(any(), any())).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ''),
          response: Response(
            requestOptions: RequestOptions(path: ''),
            data: {'message': 'Invalid credentials'},
            statusCode: 401,
          ),
        ),
      );

      final result = await authProvider.login(tEmail, 'wrong_pass');

      expect(result, isFalse);
      expect(authProvider.isAuthenticated, isFalse);
      expect(authProvider.errorMessage, 'Invalid credentials');
    });

    test('L-03 [Negative] User not found (404 Not Found)', () async {
      when(() => mockApiService.login(any(), any())).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ''),
          response: Response(
            requestOptions: RequestOptions(path: ''),
            data: {'message': 'User not found'},
            statusCode: 404,
          ),
        ),
      );

      final result = await authProvider.login('nonexistent@test.com', tPassword);

      expect(result, isFalse);
      expect(authProvider.errorMessage, 'User not found');
    });

    test('L-04 [Negative] Server error (500 Internal Server Error)', () async {
      when(() => mockApiService.login(any(), any())).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ''),
          response: Response(
            requestOptions: RequestOptions(path: ''),
            data: {'message': 'Internal server error'},
            statusCode: 500,
          ),
        ),
      );

      final result = await authProvider.login(tEmail, tPassword);

      expect(result, isFalse);
      expect(authProvider.errorMessage, 'Internal server error');
    });
  });
}
