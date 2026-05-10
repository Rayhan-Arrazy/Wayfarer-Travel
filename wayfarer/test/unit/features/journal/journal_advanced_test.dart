import 'package:flutter_test/flutter_test.dart';
import 'package:wayfarer/models/journal_model.dart';

void main() {
  group('Journal Feature - Advanced Scenarios', () {
    test('J-03 [Positive] JournalLocation from JSON', () {
      final json = {'lat': 48.8584, 'lng': 2.2945, 'name': 'Eiffel Tower', 'country': 'France'};
      final loc = JournalLocation.fromJson(json);
      expect(loc.name, 'Eiffel Tower');
      expect(loc.lat, 48.8584);
    });

    test('J-04 [Positive] JournalWeather from JSON', () {
      final json = {'temp': 22.5, 'description': 'Sunny', 'icon': '01d'};
      final weather = JournalWeather.fromJson(json);
      expect(weather.temp, 22.5);
      expect(weather.description, 'Sunny');
    });

    test('J-05 [Positive] JournalPhoto from JSON', () {
      final json = {'url': 'http://test.com/img.jpg', 'caption': 'Nice view'};
      final photo = JournalPhoto.fromJson(json);
      expect(photo.url, contains('test.com'));
      expect(photo.caption, 'Nice view');
    });

    test('J-06 [Positive] JournalEntryModel with full data from JSON', () {
      final json = {
        '_id': '1', 'userId': 'u', 'tripId': 't', 'title': 'T',
        'location': {'name': 'L'},
        'weather': {'temp': 20},
        'photos': [{'url': 'u1'}]
      };
      final entry = JournalEntryModel.fromJson(json);
      expect(entry.location?.name, 'L');
      expect(entry.weather?.temp, 20);
      expect(entry.photos.length, 1);
    });

    test('J-07 [Positive] JournalEntryModel distanceTraveled logic', () {
      final json = {'_id': '1', 'distanceTraveled': 10.5};
      final entry = JournalEntryModel.fromJson(json);
      expect(entry.distanceTraveled, 10.5);
    });

    test('J-08 [Positive] JournalLocation toJson', () {
      final loc = JournalLocation(name: 'Paris', country: 'FR');
      final json = loc.toJson();
      expect(json['name'], 'Paris');
    });

    test('J-09 [Positive] JournalPhoto toJson', () {
      final photo = JournalPhoto(url: 'u', caption: 'c');
      final json = photo.toJson();
      expect(json['caption'], 'c');
    });

    test('J-10 [Negative] JournalEntryModel handles missing location/weather', () {
      final entry = JournalEntryModel.fromJson({'_id': '1'});
      expect(entry.location, isNull);
      expect(entry.weather, isNull);
    });

    test('J-11 [Positive] JournalEntryModel default values', () {
      final entry = JournalEntryModel(id: '1', userId: 'u', tripId: 't');
      expect(entry.mood, '');
      expect(entry.photos, isEmpty);
    });

    test('J-12 [Positive] JournalEntryModel createdAt parse error handles fallback', () {
      final json = {'_id': '1', 'createdAt': 'invalid-date'};
      final entry = JournalEntryModel.fromJson(json);
      expect(entry.createdAt, isA<DateTime>());
    });
  });
}
