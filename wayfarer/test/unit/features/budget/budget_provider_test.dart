import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:wayfarer/providers/budget_provider.dart';
import 'package:wayfarer/services/api_service.dart';
import 'package:wayfarer/models/budget_model.dart';

class MockApiService extends Mock implements ApiService {}

void main() {
  late BudgetProvider budgetProvider;
  late MockApiService mockApiService;

  setUp(() {
    mockApiService = MockApiService();
    budgetProvider = BudgetProvider(apiService: mockApiService);
    registerFallbackValue(BudgetModel(id: '1', userId: 'u1', title: 'T'));
  });

  group('Budget Feature - BudgetProvider Scenarios', () {
    test('BP-01 [Positive] fetchBudgets success', () async {
      when(() => mockApiService.getBudgets()).thenAnswer((_) async => Response(
        requestOptions: RequestOptions(path: ''),
        data: [{'_id': 'b1', 'title': 'T1'}],
        statusCode: 200,
      ));
      await budgetProvider.fetchBudgets();
      expect(budgetProvider.budgets.length, 1);
      expect(budgetProvider.isLoading, isFalse);
    });

    test('BP-02 [Negative] fetchBudgets error', () async {
      when(() => mockApiService.getBudgets()).thenThrow(DioException(requestOptions: RequestOptions(path: '')));
      await budgetProvider.fetchBudgets();
      expect(budgetProvider.budgets, isEmpty);
      expect(budgetProvider.isLoading, isFalse);
    });

    test('BP-03 [Positive] createBudget success', () async {
      final b = BudgetModel(id: '1', userId: 'u1', title: 'T');
      when(() => mockApiService.createBudget(any())).thenAnswer((_) async => Response(requestOptions: RequestOptions(path: ''), statusCode: 201));
      when(() => mockApiService.getBudgets()).thenAnswer((_) async => Response(requestOptions: RequestOptions(path: ''), data: [], statusCode: 200));
      final result = await budgetProvider.createBudget(b);
      expect(result, isTrue);
    });

    test('BP-04 [Negative] createBudget fail', () async {
      final b = BudgetModel(id: '1', userId: 'u1', title: 'T');
      when(() => mockApiService.createBudget(any())).thenThrow(DioException(requestOptions: RequestOptions(path: '')));
      final result = await budgetProvider.createBudget(b);
      expect(result, isFalse);
    });

    test('BP-05 [Positive] updateBudget success', () async {
      final b = BudgetModel(id: '1', userId: 'u1', title: 'T');
      when(() => mockApiService.updateBudget(any(), any())).thenAnswer((_) async => Response(requestOptions: RequestOptions(path: ''), statusCode: 200));
      when(() => mockApiService.getBudgets()).thenAnswer((_) async => Response(requestOptions: RequestOptions(path: ''), data: [], statusCode: 200));
      final result = await budgetProvider.updateBudget('1', b);
      expect(result, isTrue);
    });

    test('BP-06 [Positive] deleteBudget success', () async {
      when(() => mockApiService.deleteBudget(any())).thenAnswer((_) async => Response(requestOptions: RequestOptions(path: ''), statusCode: 200));
      when(() => mockApiService.getBudgets()).thenAnswer((_) async => Response(requestOptions: RequestOptions(path: ''), data: [], statusCode: 200));
      final result = await budgetProvider.deleteBudget('1');
      expect(result, isTrue);
    });

    test('BP-07 [Positive] getBudgetForTrip returns match', () {
      final b = BudgetModel(id: '1', userId: 'u1', title: 'T', tripId: 't1');
      budgetProvider.budgets.add(b);
      final result = budgetProvider.getBudgetForTrip('t1');
      expect(result?.id, '1');
    });

    test('BP-08 [Negative] getBudgetForTrip returns null when no match', () {
      final result = budgetProvider.getBudgetForTrip('nonexistent');
      expect(result, isNull);
    });

    test('BP-09 [Positive] isLoading state management', () async {
      when(() => mockApiService.getBudgets()).thenAnswer((_) async {
        return Response(requestOptions: RequestOptions(path: ''), data: [], statusCode: 200);
      });
      final future = budgetProvider.fetchBudgets();
      expect(budgetProvider.isLoading, isTrue);
      await future;
      expect(budgetProvider.isLoading, isFalse);
    });

    test('BP-10 [Negative] fetchBudgets non-200 status code', () async {
      when(() => mockApiService.getBudgets()).thenAnswer((_) async => Response(requestOptions: RequestOptions(path: ''), statusCode: 404));
      await budgetProvider.fetchBudgets();
      expect(budgetProvider.budgets, isEmpty);
    });
  });
}
