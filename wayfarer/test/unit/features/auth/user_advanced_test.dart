import 'package:flutter_test/flutter_test.dart';
import 'package:wayfarer/models/user_model.dart';

void main() {
  group('Auth Feature - User & Contacts Scenarios', () {
    test('U-11 [Positive] EmergencyContact from JSON', () {
      final json = {'name': 'Mom', 'phone': '911', 'relationship': 'Mother'};
      final contact = EmergencyContact.fromJson(json);
      expect(contact.name, 'Mom');
      expect(contact.relationship, 'Mother');
    });

    test('U-12 [Positive] EmergencyContact toJson', () {
      final contact = EmergencyContact(name: 'Dad', phone: '112');
      final json = contact.toJson();
      expect(json['phone'], '112');
    });

    test('U-13 [Positive] UserModel with contacts from JSON', () {
      final json = {
        '_id': '1', 'name': 'N', 'email': 'E',
        'emergencyContacts': [{'name': 'C1', 'phone': 'P1'}]
      };
      final user = UserModel.fromJson(json);
      expect(user.emergencyContacts.length, 1);
      expect(user.emergencyContacts.first.name, 'C1');
    });

    test('U-14 [Positive] UserModel with visitedCountries from JSON', () {
      final json = {'_id': '1', 'visitedCountries': ['FR', 'JP']};
      final user = UserModel.fromJson(json);
      expect(user.visitedCountries.contains('FR'), isTrue);
    });

    test('U-15 [Positive] UserModel default totalTrips', () {
      final user = UserModel(id: '1', name: 'N', email: 'E');
      expect(user.totalTrips, 0);
    });

    test('U-16 [Positive] UserModel createdAt parse', () {
      final dateStr = '2024-01-01T12:00:00Z';
      final user = UserModel.fromJson({'_id': '1', 'createdAt': dateStr});
      expect(user.createdAt.year, 2024);
    });

    test('U-17 [Positive] EmergencyContact handles null relationship', () {
      final contact = EmergencyContact.fromJson({'name': 'N', 'phone': 'P'});
      expect(contact.relationship, '');
    });

    test('U-18 [Positive] UserModel isActive default', () {
      final user = UserModel.fromJson({'_id': '1'});
      expect(user.isActive, isTrue);
    });

    test('U-19 [Positive] UserModel avatar default', () {
      final user = UserModel(id: '1', name: 'N', email: 'E');
      expect(user.avatar, isEmpty);
    });

    test('U-20 [Positive] UserModel copyWith placeholder (if needed)', () {
      // UserModel doesn't have copyWith yet, but we test the fields
      final user = UserModel(id: '1', name: 'N', email: 'E', role: 'admin');
      expect(user.role, 'admin');
    });
  });
}
