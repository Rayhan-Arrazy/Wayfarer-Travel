import 'package:flutter_test/flutter_test.dart';
import 'package:wayfarer/models/user_model.dart';

void main() {
  group('Auth Feature - UserModel Scenarios', () {
    test('U-01 [Positive] UserModel should be created correctly from JSON', () {
      final json = {
        '_id': '123',
        'name': 'John Doe',
        'email': 'john@example.com',
        'role': 'user',
        'homeCurrency': 'USD',
        'isActive': true,
      };

      final user = UserModel.fromJson(json);

      expect(user.id, '123');
      expect(user.name, 'John Doe');
      expect(user.email, 'john@example.com');
      expect(user.isAdmin, false);
    });

    test('U-02 [Positive] isAdmin should return true for admin role', () {
      final user = UserModel(
        id: '1',
        name: 'Admin',
        email: 'admin@wayfarer.com',
        role: 'admin',
      );

      expect(user.isAdmin, true);
    });

    test('U-03 [Positive] toJson should return correct map for profile updates', () {
      final user = UserModel(
        id: '1',
        name: 'John',
        email: 'john@example.com',
        homeCurrency: 'EUR',
      );

      final json = user.toJson();

      expect(json['name'], 'John');
      expect(json['email'], 'john@example.com');
      expect(json['homeCurrency'], 'EUR');
    });
  });
}
