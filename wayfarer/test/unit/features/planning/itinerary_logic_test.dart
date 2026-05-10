import 'package:flutter_test/flutter_test.dart';
import 'package:wayfarer/models/trip_model.dart';

void main() {
  group('Planning Feature - Itinerary Logic Scenarios', () {
    test('IT-01 [Positive] ItineraryActivity from JSON', () {
      final json = {'title': 'Dinner', 'time': '07:00 PM', 'location': 'Paris', 'checked': true};
      final activity = ItineraryActivity.fromJson(json);
      expect(activity.title, 'Dinner');
      expect(activity.checked, isTrue);
    });

    test('IT-02 [Positive] ItineraryActivity toJson', () {
      final activity = ItineraryActivity(title: 'Sleep', time: '11:00 PM', location: 'Hotel');
      final json = activity.toJson();
      expect(json['title'], 'Sleep');
      expect(json['location'], 'Hotel');
    });

    test('IT-03 [Positive] TripModel calculates itinerary length', () {
      final trip = TripModel(
        id: '1', userId: 'u1', destination: 'P', countryCode: 'FR',
        startDate: DateTime.now(), endDate: DateTime.now(),
        itinerary: [
          ItineraryActivity(title: 'A1', time: '1', location: 'L'),
          ItineraryActivity(title: 'A2', time: '2', location: 'L'),
        ]
      );
      expect(trip.itinerary.length, 2);
    });

    test('IT-04 [Positive] copyWith updates itinerary', () {
      final trip = TripModel(id: '1', userId: 'u1', destination: 'P', countryCode: 'FR', startDate: DateTime.now(), endDate: DateTime.now());
      final updated = trip.copyWith(itinerary: [ItineraryActivity(title: 'A1', time: '1')]);
      expect(updated.itinerary.length, 1);
    });

    test('IT-05 [Negative] ItineraryActivity handles missing fields', () {
      final activity = ItineraryActivity.fromJson({});
      expect(activity.title, '');
      expect(activity.checked, isFalse);
    });

    test('IT-06 [Positive] TripModel status helpers', () {
      final trip = TripModel(id: '1', userId: 'u1', destination: 'P', countryCode: 'FR', startDate: DateTime.now(), endDate: DateTime.now(), status: 'active');
      expect(trip.isActive, isTrue);
      expect(trip.isPlanning, isFalse);
    });

    test('IT-07 [Positive] ItineraryActivity location default', () {
      final activity = ItineraryActivity(title: 'T', time: 'T');
      expect(activity.location, '');
    });

    test('IT-08 [Positive] ItineraryActivity from JSON with date', () {
      final json = {'title': 'T', 'date': '2024-06-01T00:00:00.000Z'};
      final activity = ItineraryActivity.fromJson(json);
      expect(activity.date?.year, 2024);
    });

    test('IT-09 [Positive] ItineraryActivity copyWith', () {
      final activity = ItineraryActivity(title: 'A', time: '1');
      final updated = activity.copyWith(title: 'B');
      expect(updated.title, 'B');
      expect(updated.time, '1');
    });

    test('IT-10 [Positive] ItineraryActivity toJson with date', () {
      final activity = ItineraryActivity(title: 'T', date: DateTime(2024, 6, 1));
      final json = activity.toJson();
      expect(json['date'], contains('2024-06-01'));
    });
  });
}
