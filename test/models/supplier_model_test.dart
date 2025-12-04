import 'package:flutter_test/flutter_test.dart';
import 'package:nexo_staff_purchase/data/models/supplier_model.dart';

void main() {
  group('Supplier Model Tests', () {
    test('should parse supplier with all fields from JSON', () {
      final json = {
        "_id": "691f455582f11ac52c29206d",
        "name": "Cheese leader",
        "contactPerson": "Atman tahar",
        "phone1": "05667788",
        "address": "Nouvelle ville",
        "image": "https://example.com/image.jpg",
        "isActive": true
      };

      final supplier = Supplier.fromJson(json);

      expect(supplier.id, "691f455582f11ac52c29206d");
      expect(supplier.name, "Cheese leader");
      expect(supplier.contactPerson, "Atman tahar");
      expect(supplier.phone1, "05667788");
      expect(supplier.address, "Nouvelle ville");
      expect(supplier.image, "https://example.com/image.jpg");
      expect(supplier.isActive, true);
    });

    test('should parse supplier WITHOUT isActive field from JSON (orders endpoint)', () {
      // This is the critical test - API response from orders endpoint
      // doesn't include isActive field
      final json = {
        "_id": "691f455582f11ac52c29206d",
        "name": "Cheese leader",
        "contactPerson": "Atman tahar",
        "phone1": "05667788",
        "address": "Nouvelle ville",
        "image": "https://example.com/image.jpg"
        // NOTE: isActive is NOT in the response
      };

      final supplier = Supplier.fromJson(json);

      expect(supplier.id, "691f455582f11ac52c29206d");
      expect(supplier.name, "Cheese leader");
      expect(supplier.contactPerson, "Atman tahar");
      expect(supplier.phone1, "05667788");
      expect(supplier.address, "Nouvelle ville");
      expect(supplier.image, "https://example.com/image.jpg");
      expect(supplier.isActive, true); // Should default to true
    });

    test('should create supplier with explicit isActive value', () {
      final supplier = Supplier(
        id: "test123",
        name: "Test Supplier",
        isActive: false,
      );

      expect(supplier.id, "test123");
      expect(supplier.name, "Test Supplier");
      expect(supplier.isActive, false);
    });

    test('should create supplier without specifying isActive (defaults to true)', () {
      final supplier = Supplier(
        id: "test456",
        name: "Another Supplier",
      );

      expect(supplier.id, "test456");
      expect(supplier.name, "Another Supplier");
      expect(supplier.isActive, true); // Should default to true
    });

    test('should serialize Supplier to JSON', () {
      final supplier = Supplier(
        id: "691f455582f11ac52c29206d",
        name: "Cheese leader",
        contactPerson: "Atman tahar",
        phone1: "05667788",
        address: "Nouvelle ville",
        image: "https://example.com/image.jpg",
      );

      final json = supplier.toJson();

      expect(json['_id'], "691f455582f11ac52c29206d");
      expect(json['name'], "Cheese leader");
      expect(json['contactPerson'], "Atman tahar");
      expect(json['phone1'], "05667788");
      expect(json['address'], "Nouvelle ville");
      expect(json['image'], "https://example.com/image.jpg");
      expect(json['isActive'], true);
    });

    test('should handle all optional fields as null', () {
      final json = {
        "_id": "test789",
        "name": "Minimal Supplier",
      };

      final supplier = Supplier.fromJson(json);

      expect(supplier.id, "test789");
      expect(supplier.name, "Minimal Supplier");
      expect(supplier.description, isNull);
      expect(supplier.contactPerson, isNull);
      expect(supplier.phone1, isNull);
      expect(supplier.phone2, isNull);
      expect(supplier.phone3, isNull);
      expect(supplier.email, isNull);
      expect(supplier.address, isNull);
      expect(supplier.city, isNull);
      expect(supplier.country, isNull);
      expect(supplier.notes, isNull);
      expect(supplier.image, isNull);
      expect(supplier.isActive, true); // Default value
      expect(supplier.createdAt, isNull);
      expect(supplier.updatedAt, isNull);
    });

    test('should use copyWith correctly', () {
      final supplier = Supplier(
        id: "sup1",
        name: "Supplier 1",
        isActive: false,
      );

      final updatedSupplier = supplier.copyWith(
        name: "Updated Supplier",
        isActive: true,
      );

      expect(updatedSupplier.id, "sup1"); // Unchanged
      expect(updatedSupplier.name, "Updated Supplier"); // Changed
      expect(updatedSupplier.isActive, true); // Changed
    });
  });
}
