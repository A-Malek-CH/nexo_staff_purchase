import 'package:flutter_test/flutter_test.dart';
import 'package:nexo_staff_purchase/data/models/product_model.dart';

void main() {
  group('Product Model Tests', () {
    test('should parse product with full category from JSON (products endpoint)', () {
      // API response from products endpoint
      final json = {
        "_id": "692590d96d9cec11d1eeb875",
        "name": "ifri 50 cl",
        "unit": "pack",
        "categoryId": {
          "_id": "692590af6d9cec11d1eeb86f",
          "name": "Boissons",
          "description": "",
          "image": ""
        },
        "currentStock": 0,
        "minQty": 10,
        "recommendedQty": 30
      };

      final product = Product.fromJson(json);

      expect(product.id, "692590d96d9cec11d1eeb875");
      expect(product.name, "ifri 50 cl");
      expect(product.unit, "pack");
      expect(product.currentStock, 0);
      expect(product.minQty, 10);
      expect(product.recommendedQty, 30);
      expect(product.categoryId, isNotNull);
      expect(product.categoryId!.id, "692590af6d9cec11d1eeb86f");
      expect(product.categoryId!.name, "Boissons");
      expect(product.categoryName, "Boissons"); // Test the getter
    });

    test('should parse product without category from JSON (orders endpoint)', () {
      // Minimal product data in orders
      final json = {
        "_id": "692590d96d9cec11d1eeb875",
        "name": "ifri 50 cl",
        "currentStock": 0
      };

      final product = Product.fromJson(json);

      expect(product.id, "692590d96d9cec11d1eeb875");
      expect(product.name, "ifri 50 cl");
      expect(product.currentStock, 0);
      expect(product.categoryId, isNull);
      expect(product.unit, isNull);
      expect(product.minQty, isNull);
      expect(product.recommendedQty, isNull);
    });

    test('should parse Category from JSON', () {
      final json = {
        "_id": "692590af6d9cec11d1eeb86f",
        "name": "Boissons",
        "description": "Test description",
        "image": "https://example.com/image.jpg"
      };

      final category = Category.fromJson(json);

      expect(category.id, "692590af6d9cec11d1eeb86f");
      expect(category.name, "Boissons");
      expect(category.description, "Test description");
      expect(category.image, "https://example.com/image.jpg");
    });

    test('should serialize Product to JSON', () {
      final category = Category(
        id: "692590af6d9cec11d1eeb86f",
        name: "Boissons",
      );

      final product = Product(
        id: "692590d96d9cec11d1eeb875",
        name: "ifri 50 cl",
        unit: "pack",
        categoryId: category,
        currentStock: 0,
        minQty: 10,
        recommendedQty: 30,
      );

      final json = product.toJson();

      expect(json['_id'], "692590d96d9cec11d1eeb875");
      expect(json['name'], "ifri 50 cl");
      expect(json['unit'], "pack");
      expect(json['current_stock'], 0);
      expect(json['min_qty'], 10);
      expect(json['recommended_qty'], 30);
      expect(json['categoryId'], isNotNull);
      expect(json['categoryId']['_id'], "692590af6d9cec11d1eeb86f");
      expect(json['categoryId']['name'], "Boissons");
    });

    test('should handle all optional fields as null', () {
      final json = {
        "_id": "692590d96d9cec11d1eeb875",
        "name": "Test Product",
      };

      final product = Product.fromJson(json);

      expect(product.id, "692590d96d9cec11d1eeb875");
      expect(product.name, "Test Product");
      expect(product.description, isNull);
      expect(product.barcode, isNull);
      expect(product.categoryId, isNull);
      expect(product.price, isNull);
      expect(product.minQty, isNull);
      expect(product.recommendedQty, isNull);
      expect(product.unit, isNull);
      expect(product.currentStock, isNull);
      expect(product.imageUrl, isNull);
      expect(product.isActive, true); // Default value
      expect(product.notes, isNull);
      expect(product.createdAt, isNull);
      expect(product.updatedAt, isNull);
    });

    test('should use copyWith correctly', () {
      final category = Category(
        id: "cat1",
        name: "Category 1",
      );

      final product = Product(
        id: "prod1",
        name: "Product 1",
        currentStock: 10,
      );

      final updatedProduct = product.copyWith(
        name: "Product 2",
        categoryId: category,
        currentStock: 20,
      );

      expect(updatedProduct.id, "prod1"); // Unchanged
      expect(updatedProduct.name, "Product 2"); // Changed
      expect(updatedProduct.categoryId, category); // Changed
      expect(updatedProduct.currentStock, 20); // Changed
    });
  });
}
