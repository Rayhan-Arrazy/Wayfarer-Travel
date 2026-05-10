import 'package:flutter_test/flutter_test.dart';
import 'package:wayfarer/models/journal_model.dart';

void main() {
  group('Journal Feature - JournalEntryModel Scenarios', () {
    test('J-01 [Positive] JournalEntryModel should be created correctly from JSON', () {
      final json = {
        '_id': 'entry123',
        'userId': 'user1',
        'tripId': 'trip456',
        'title': 'Paris Diary',
        'note': 'Best coffee ever.',
        'mood': 'Happy',
        'createdAt': '2024-05-10T10:00:00Z',
      };

      final entry = JournalEntryModel.fromJson(json);

      expect(entry.id, 'entry123');
      expect(entry.title, 'Paris Diary');
      expect(entry.mood, 'Happy');
    });

    test('J-02 [Positive] toJson should include core fields', () {
      final entry = JournalEntryModel(
        id: '1',
        userId: 'u1',
        tripId: 't1',
        title: 'Morning Walk',
        note: 'Fresh air.',
        mood: 'Calm',
      );

      final json = entry.toJson();

      expect(json['title'], 'Morning Walk');
      expect(json['mood'], 'Calm');
      expect(json['tripId'], 't1');
    });
  });
}
