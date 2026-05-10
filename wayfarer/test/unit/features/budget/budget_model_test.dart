import 'package:flutter_test/flutter_test.dart';
import 'package:wayfarer/models/budget_model.dart';

void main() {
  group('Budget Feature - BudgetModel Scenarios', () {
    test('BM-01 [Positive] BudgetModel from JSON', () {
      final json = {
        '_id': 'b1',
        'userId': 'u1',
        'title': 'Tokyo Trip',
        'amount': 2000.0,
        'currency': 'USD',
      };
      final budget = BudgetModel.fromJson(json);
      expect(budget.id, 'b1');
      expect(budget.title, 'Tokyo Trip');
      expect(budget.amount, 2000.0);
    });

    test('BM-02 [Positive] BudgetModel with Expenses from JSON', () {
      final json = {
        '_id': 'b1',
        'expenses': [
          {'_id': 'e1', 'title': 'Food', 'amount': 50.0, 'category': 'Dining'}
        ]
      };
      final budget = BudgetModel.fromJson(json);
      expect(budget.expenses.length, 1);
      expect(budget.expenses.first.title, 'Food');
    });

    test('BM-03 [Positive] toJson returns correct map', () {
      final budget = BudgetModel(id: '1', userId: 'u1', title: 'Test', amount: 100);
      final json = budget.toJson();
      expect(json['title'], 'Test');
      expect(json['amount'], 100.0);
    });

    test('BM-04 [Positive] copyWith updates fields correctly', () {
      final budget = BudgetModel(id: '1', userId: 'u1', title: 'Old');
      final updated = budget.copyWith(title: 'New');
      expect(updated.title, 'New');
      expect(updated.id, '1');
    });

    test('BM-05 [Positive] BudgetExpense from JSON', () {
      final json = {'_id': 'e1', 'title': 'Bus', 'amount': 5.5};
      final exp = BudgetExpense.fromJson(json);
      expect(exp.title, 'Bus');
      expect(exp.amount, 5.5);
    });

    test('BM-06 [Negative] BudgetModel from empty JSON handles defaults', () {
      final budget = BudgetModel.fromJson({});
      expect(budget.id, '');
      expect(budget.amount, 0.0);
      expect(budget.currency, 'USD');
    });

    test('BM-07 [Positive] BudgetExpense toJson', () {
      final exp = BudgetExpense(title: 'Taxi', amount: 15, date: DateTime(2024, 1, 1));
      final json = exp.toJson();
      expect(json['title'], 'Taxi');
      expect(json['amount'], 15.0);
    });

    test('BM-08 [Positive] BudgetModel with tripId', () {
      final budget = BudgetModel(id: '1', userId: 'u1', title: 'Trip', tripId: 't123');
      expect(budget.tripId, 't123');
    });

    test('BM-09 [Positive] BudgetModel createdAt handling', () {
      final date = DateTime(2024, 5, 1);
      final budget = BudgetModel(id: '1', userId: 'u1', title: 'T', createdAt: date);
      expect(budget.createdAt, date);
    });

    test('BM-10 [Positive] BudgetExpense category default', () {
      final exp = BudgetExpense(title: 'T', amount: 10, date: DateTime.now());
      expect(exp.category, 'General');
    });
  });
}
