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

  group('Auth Feature - Register Scenarios', () {
    const tName = 'New User';
    const tEmail = 'new@example.com';
    const tPassword = 'password123';
    const tToken = 'new_token';
    final tUserJson = {
      '_id': '2',
      'name': tName,
      'email': tEmail,
    };

    test('R-01 [Positive] Valid registration data', () async {
      when(() => mockApiService.register(any(), any(), any(), homeCurrency: any(named: 'homeCurrency'))).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ''),
          data: {
            'token': tToken,
            'user': tUserJson,
          },
          statusCode: 201,
        ),
      );

      final result = await authProvider.register(tName, tEmail, tPassword);

      expect(result, isTrue);
      expect(authProvider.isAuthenticated, isTrue);
      expect(authProvider.user?.name, tName);
      expect(authProvider.errorMessage, isNull);
      verify(() => mockApiService.register(tName, tEmail, tPassword)).called(1);
    });

    test('R-02 [Negative] Email already exists (400 Bad Request)', () async {
      when(() => mockApiService.register(any(), any(), any(), homeCurrency: any(named: 'homeCurrency'))).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ''),
          response: Response(
            requestOptions: RequestOptions(path: ''),
            data: {'message': 'Email already in use'},
            statusCode: 400,
          ),
        ),
      );

      final result = await authProvider.register(tName, tEmail, tPassword);

      expect(result, isFalse);
      expect(authProvider.isAuthenticated, isFalse);
      expect(authProvider.errorMessage, 'Email already in use');
    });

    test('R-03 [Negative] Server error during signup', () async {
      when(() => mockApiService.register(any(), any(), any(), homeCurrency: any(named: 'homeCurrency'))).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ''),
          response: Response(
            requestOptions: RequestOptions(path: ''),
            data: {'message': 'Registration failed'},
            statusCode: 500,
          ),
        ),
      );

      final result = await authProvider.register(tName, tEmail, tPassword);

      expect(result, isFalse);
      expect(authProvider.errorMessage, 'Registration failed');
    });
  });
}
