import 'package:flutter_test/flutter_test.dart';
import 'package:wayfarer/models/user_model.dart';
import 'package:wayfarer/providers/auth_provider.dart';

void main() {
  group('UserModel Tests', () {
    test('UserModel should be created correctly from JSON', () {
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

    test('UserModel isAdmin should return true for admin role', () {
      final user = UserModel(
        id: '1',
        name: 'Admin',
        email: 'admin@wayfarer.com',
        role: 'admin',
      );

      expect(user.isAdmin, true);
    });

    test('UserModel toJson should return correct map', () {
      final user = UserModel(
        id: '1',
        name: 'John',
        email: 'john@example.com',
      );

      final json = user.toJson();

      expect(json['name'], 'John');
      expect(json['email'], 'john@example.com');
    });
  });

  group('AuthProvider Tests', () {
    test('continueAsGuest should set guest user correctly', () {
      final authProvider = AuthProvider();
      
      authProvider.continueAsGuest();
      
      expect(authProvider.isGuest, isTrue);
      expect(authProvider.isAuthenticated, isTrue);
      expect(authProvider.user?.name, 'Guest User');
      expect(authProvider.user?.id, 'guest');
    });
  });
}
