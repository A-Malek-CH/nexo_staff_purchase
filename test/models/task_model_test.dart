import 'package:flutter_test/flutter_test.dart';
import 'package:nexo_staff_purchase/data/models/task_model.dart';
import 'package:nexo_staff_purchase/data/models/task_item_model.dart';

void main() {
  group('Task Model Tests', () {
    final sampleTaskJson = {
      'id': 'task-001',
      'title': 'Buy office supplies',
      'description': 'Purchase pens, notebooks and paper',
      'status': 'pending',
      'priority': 'medium',
      'deadline': '2025-12-31T09:00:00.000Z',
      'supplier_id': 'sup-001',
      'supplier_name': 'Office World',
      'assigned_to': 'user-001',
      'assigned_by': 'admin-001',
      'items': <dynamic>[],
      'notes': 'Get receipts',
      'created_at': '2025-12-01T08:00:00.000Z',
      'updated_at': null,
      'completed_at': null,
    };

    test('should parse Task from JSON', () {
      final task = Task.fromJson(sampleTaskJson);

      expect(task.id, 'task-001');
      expect(task.title, 'Buy office supplies');
      expect(task.description, 'Purchase pens, notebooks and paper');
      expect(task.status, 'pending');
      expect(task.priority, 'medium');
      expect(task.deadline, DateTime.parse('2025-12-31T09:00:00.000Z'));
      expect(task.supplierId, 'sup-001');
      expect(task.supplierName, 'Office World');
      expect(task.assignedTo, 'user-001');
      expect(task.assignedBy, 'admin-001');
      expect(task.items, isEmpty);
      expect(task.notes, 'Get receipts');
      expect(task.createdAt, DateTime.parse('2025-12-01T08:00:00.000Z'));
      expect(task.updatedAt, isNull);
      expect(task.completedAt, isNull);
    });

    test('should serialize Task to JSON', () {
      final task = Task.fromJson(sampleTaskJson);
      final json = task.toJson();

      expect(json['id'], 'task-001');
      expect(json['title'], 'Buy office supplies');
      expect(json['status'], 'pending');
      expect(json['priority'], 'medium');
      expect(json['supplier_id'], 'sup-001');
      expect(json['assigned_to'], 'user-001');
      expect(json['assigned_by'], 'admin-001');
    });

    test('should support copyWith', () {
      final task = Task.fromJson(sampleTaskJson);
      final updated = task.copyWith(status: 'completed');

      expect(updated.status, 'completed');
      expect(updated.id, task.id);
      expect(updated.title, task.title);
      expect(updated.deadline, task.deadline);
    });

    test('should parse Task with completed status', () {
      final json = Map<String, dynamic>.from(sampleTaskJson);
      json['status'] = 'completed';
      json['completed_at'] = '2025-12-15T10:00:00.000Z';

      final task = Task.fromJson(json);

      expect(task.status, 'completed');
      expect(task.completedAt, DateTime.parse('2025-12-15T10:00:00.000Z'));
    });

    test('should parse Task with items list', () {
      final json = Map<String, dynamic>.from(sampleTaskJson);
      json['items'] = [
        {
          'id': 'item-001',
          'task_id': 'task-001',
          'product_id': 'prod-001',
          'product_name': 'Blue Pen',
          'requested_quantity': 10,
          'actual_quantity': null,
          'requested_price': 2.5,
          'actual_price': null,
          'status': 'pending',
          'is_available': true,
          'notes': null,
          'receipt_url': null,
          'photo_url': null,
          'purchased_at': null,
        }
      ];

      final task = Task.fromJson(json);

      expect(task.items.length, 1);
      expect(task.items.first.id, 'item-001');
      expect(task.items.first.productName, 'Blue Pen');
      expect(task.items.first.requestedQuantity, 10);
    });
  });
}
