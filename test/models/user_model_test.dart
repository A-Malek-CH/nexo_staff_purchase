import 'package:flutter_test/flutter_test.dart';
import 'package:nexo_staff_purchase/data/models/user_model.dart';

void main() {
  group('User Model Tests - Optional Fields with Defaults', () {
    test('should parse user with minimal data from API (embedded in orders)', () {
      // Minimal user data as embedded in orders
      final json = {
        "_id": "693075f6961813aaadd6e0a7",
        "fullname": "malek",
        "email": "chmalek19@gmail.com"
      };

      final user = User.fromJson(json);

      expect(user.id, "693075f6961813aaadd6e0a7");
      expect(user.fullname, "malek");
      expect(user.email, "chmalek19@gmail.com");
      // Check default values
      expect(user.role, "staff");
      expect(user.isActive, true);
      expect(user.createdAt, isNull);
    });

    test('should parse user with full data from API', () {
      final json = {
        "_id": "693075f6961813aaadd6e0a7",
        "fullname": "malek",
        "email": "chmalek19@gmail.com",
        "phone1": "1234567890",
        "avatar": "https://example.com/avatar.jpg",
        "role": "admin",
        "isActive": false,
        "address": "123 Main St",
        "createdAt": "2025-12-04T00:12:23.678Z",
        "updatedAt": "2025-12-05T00:12:23.678Z"
      };

      final user = User.fromJson(json);

      expect(user.id, "693075f6961813aaadd6e0a7");
      expect(user.fullname, "malek");
      expect(user.email, "chmalek19@gmail.com");
      expect(user.phone1, "1234567890");
      expect(user.avatar, "https://example.com/avatar.jpg");
      expect(user.role, "admin");
      expect(user.isActive, false);
      expect(user.address, "123 Main St");
      expect(user.createdAt, isNotNull);
      expect(user.updatedAt, isNotNull);
    });

    test('should use default values when fields are null', () {
      final json = {
        "_id": "693075f6961813aaadd6e0a7",
        "fullname": "malek",
        "email": "chmalek19@gmail.com",
        "role": null,
        "isActive": null
      };

      final user = User.fromJson(json);

      expect(user.role, "staff"); // Default value
      expect(user.isActive, true); // Default value
    });

    test('should serialize user to JSON with nullable createdAt', () {
      final user = User(
        id: "user1",
        email: "test@example.com",
        fullname: "Test User",
        role: "staff",
        isActive: true,
      );

      final json = user.toJson();

      expect(json['_id'], "user1");
      expect(json['email'], "test@example.com");
      expect(json['fullname'], "Test User");
      expect(json['role'], "staff");
      expect(json['isActive'], true);
      expect(json['createdAt'], isNull); // Should be null when not provided
    });

    test('should serialize user with createdAt to JSON', () {
      final user = User(
        id: "user1",
        email: "test@example.com",
        fullname: "Test User",
        createdAt: DateTime.parse("2025-12-04T00:12:23.678Z"),
      );

      final json = user.toJson();

      expect(json['createdAt'], "2025-12-04T00:12:23.678Z");
    });

    test('should create user with constructor defaults', () {
      final user = User(
        id: "user1",
        email: "test@example.com",
        fullname: "Test User",
      );

      expect(user.role, "staff"); // Constructor default
      expect(user.isActive, true); // Constructor default
      expect(user.createdAt, isNull);
    });

    test('should use copyWith correctly', () {
      final user = User(
        id: "user1",
        email: "test@example.com",
        fullname: "Test User",
      );

      final updatedUser = user.copyWith(
        fullname: "Updated User",
        role: "admin",
      );

      expect(updatedUser.id, "user1"); // Unchanged
      expect(updatedUser.email, "test@example.com"); // Unchanged
      expect(updatedUser.fullname, "Updated User"); // Changed
      expect(updatedUser.role, "admin"); // Changed
      expect(updatedUser.isActive, true); // Unchanged
    });

    test('should use name getter for backward compatibility', () {
      final user = User(
        id: "user1",
        email: "test@example.com",
        fullname: "Test User",
      );

      expect(user.name, "Test User");
      expect(user.name, user.fullname);
    });
  });
}
