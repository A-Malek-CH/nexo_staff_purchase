import 'package:flutter_test/flutter_test.dart';
import 'package:nexo_staff_purchase/data/models/order_model.dart';
import 'package:nexo_staff_purchase/data/models/user_model.dart';
import 'package:nexo_staff_purchase/data/models/supplier_model.dart';
import 'package:nexo_staff_purchase/data/models/product_model.dart';

void main() {
  group('Order Model Tests - CamelCase JSON Keys', () {
    test('should parse order with camelCase keys from API', () {
      // API response with camelCase keys
      final json = {
        "_id": "675fa6f03c7aeb3eb7f63ca9",
        "orderNumber": "ORD-20251204-1466",
        "supplierId": {
          "_id": "692590af6d9cec11d1eeb86f",
          "name": "Test Supplier",
          "phone": "1234567890"
        },
        "staffId": {
          "_id": "693075f6961813aaadd6e0a7",
          "fullname": "malek",
          "email": "chmalek19@gmail.com"
        },
        "status": "assigned",
        "totalAmount": 1500.50,
        "items": [
          {
            "_id": "item1",
            "productId": {
              "_id": "prod1",
              "name": "Test Product",
              "currentStock": 100
            },
            "quantity": 10,
            "unitCost": 150.05,
            "remainingQte": 5,
            "isExpired": false,
            "expiredQuantity": 0,
            "expirationDate": "2025-12-31T00:00:00.000Z"
          }
        ],
        "createdAt": "2025-12-04T00:12:23.678Z",
        "statusHistory": []
      };

      final order = Order.fromJson(json);

      expect(order.id, "675fa6f03c7aeb3eb7f63ca9");
      expect(order.orderNumber, "ORD-20251204-1466");
      expect(order.supplierId.id, "692590af6d9cec11d1eeb86f");
      expect(order.staffId, isNotNull);
      expect(order.staffId!.id, "693075f6961813aaadd6e0a7");
      expect(order.staffId!.fullname, "malek");
      expect(order.status, "assigned");
      expect(order.totalAmount, 1500.50);
      expect(order.items.length, 1);
      expect(order.createdAt.toIso8601String(), "2025-12-04T00:12:23.678Z");
    });

    test('should parse ProductOrder with camelCase keys from API', () {
      final json = {
        "_id": "item1",
        "productId": {
          "_id": "prod1",
          "name": "Test Product",
          "currentStock": 100
        },
        "quantity": 10,
        "unitCost": 150.05,
        "remainingQte": 5,
        "isExpired": true,
        "expiredQuantity": 2,
        "expirationDate": "2025-12-04T00:12:09.014Z"
      };

      final productOrder = ProductOrder.fromJson(json);

      expect(productOrder.id, "item1");
      expect(productOrder.productId.id, "prod1");
      expect(productOrder.quantity, 10);
      expect(productOrder.unitCost, 150.05);
      expect(productOrder.remainingQte, 5);
      expect(productOrder.isExpired, true);
      expect(productOrder.expiredQuantity, 2);
      expect(productOrder.expirationDate, isNotNull);
    });

    test('should serialize Order to JSON with camelCase keys', () {
      final supplier = Supplier(
        id: "sup1",
        name: "Test Supplier",
        phone: "1234567890",
      );

      final user = User(
        id: "user1",
        email: "test@example.com",
        fullname: "Test User",
      );

      final product = Product(
        id: "prod1",
        name: "Test Product",
        currentStock: 100,
      );

      final productOrder = ProductOrder(
        id: "item1",
        productId: product,
        quantity: 10,
        unitCost: 150.0,
        remainingQte: 5,
        isExpired: false,
        expiredQuantity: 0,
      );

      final order = Order(
        id: "order1",
        orderNumber: "ORD-001",
        supplierId: supplier,
        staffId: user,
        status: "assigned",
        totalAmount: 1500.0,
        items: [productOrder],
        createdAt: DateTime.parse("2025-12-04T00:12:23.678Z"),
        statusHistory: [],
      );

      final json = order.toJson();

      // Verify camelCase keys are used
      expect(json['orderNumber'], "ORD-001");
      expect(json['supplierId'], isNotNull);
      expect(json['staffId'], isNotNull);
      expect(json['totalAmount'], 1500.0);
      expect(json['createdAt'], "2025-12-04T00:12:23.678Z");
      expect(json['statusHistory'], isNotNull);
    });

    test('should serialize ProductOrder to JSON with camelCase keys', () {
      final product = Product(
        id: "prod1",
        name: "Test Product",
        currentStock: 100,
      );

      final productOrder = ProductOrder(
        id: "item1",
        productId: product,
        quantity: 10,
        unitCost: 150.05,
        remainingQte: 5,
        isExpired: true,
        expiredQuantity: 2,
        expirationDate: DateTime.parse("2025-12-04T00:12:09.014Z"),
      );

      final json = productOrder.toJson();

      // Verify camelCase keys are used
      expect(json['productId'], isNotNull);
      expect(json['unitCost'], 150.05);
      expect(json['remainingQte'], 5);
      expect(json['isExpired'], true);
      expect(json['expiredQuantity'], 2);
      expect(json['expirationDate'], "2025-12-04T00:12:09.014Z");
    });
  });
}
