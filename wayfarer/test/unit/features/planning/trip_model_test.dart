import 'package:flutter_test/flutter_test.dart';
import 'package:wayfarer/models/trip_model.dart';

void main() {
  group('Planning Feature - TripModel Scenarios', () {
    test('T-01 [Positive] TripModel should be created correctly from JSON', () {
      final json = {
        '_id': 'trip123',
        'userId': 'user1',
        'destination': 'Paris',
        'countryCode': 'FR',
        'startDate': '2024-06-01T00:00:00.000Z',
        'endDate': '2024-06-10T00:00:00.000Z',
        'status': 'planning',
      };

      final trip = TripModel.fromJson(json);

      expect(trip.id, 'trip123');
      expect(trip.destination, 'Paris');
      expect(trip.durationDays, 9);
      expect(trip.isPlanning, isTrue);
    });

    test('T-02 [Positive] checklistProgress should calculate correctly', () {
      final trip = TripModel(
        id: '1',
        userId: 'u1',
        destination: 'London',
        countryCode: 'GB',
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 5)),
        checklist: [
          ChecklistItem(item: 'Passport', checked: true),
          ChecklistItem(item: 'Hotel', checked: false),
        ],
      );

      expect(trip.checklistProgress, 50);
    });

    test('T-03 [Positive] toJson should include core fields', () {
      final trip = TripModel(
        id: '1',
        userId: 'u1',
        destination: 'Tokyo',
        countryCode: 'JP',
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 1, 10),
      );

      final json = trip.toJson();

      expect(json['destination'], 'Tokyo');
      expect(json['countryCode'], 'JP');
      expect(json['startDate'], contains('2024-01-01'));
    });
  });
}
