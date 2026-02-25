import 'package:flutter_test/flutter_test.dart';
import 'package:nexo_staff_purchase/data/models/task_model.dart';

void main() {
  group('Task Model Tests', () {
    final sampleStaffJson = {
      '_id': 'staff-001',
      'fullname': 'John Doe',
      'email': 'john@example.com',
    };

    final sampleTaskJson = {
      '_id': 'task-001',
      'taskNumber': 42,
      'staffId': sampleStaffJson,
      'description': 'Purchase pens, notebooks and paper',
      'status': 'pending',
      'deadline': '2025-12-31T09:00:00.000Z',
      'createdAt': '2025-12-01T08:00:00.000Z',
      'updatedAt': '2025-12-02T08:00:00.000Z',
    };

    test('should parse Task from JSON', () {
      final task = Task.fromJson(sampleTaskJson);

      expect(task.id, 'task-001');
      expect(task.taskNumber, 42);
      expect(task.staffId.id, 'staff-001');
      expect(task.staffId.fullname, 'John Doe');
      expect(task.staffId.email, 'john@example.com');
      expect(task.description, 'Purchase pens, notebooks and paper');
      expect(task.status, 'pending');
      expect(task.deadline, DateTime.parse('2025-12-31T09:00:00.000Z'));
      expect(task.createdAt, DateTime.parse('2025-12-01T08:00:00.000Z'));
      expect(task.updatedAt, DateTime.parse('2025-12-02T08:00:00.000Z'));
    });

    test('should serialize Task to JSON', () {
      final task = Task.fromJson(sampleTaskJson);
      final json = task.toJson();

      expect(json['_id'], 'task-001');
      expect(json['taskNumber'], 42);
      expect(json['status'], 'pending');
      expect((json['staffId'] as Map)['_id'], 'staff-001');
    });

    test('should support copyWith', () {
      final task = Task.fromJson(sampleTaskJson);
      final updated = task.copyWith(status: 'completed');

      expect(updated.status, 'completed');
      expect(updated.id, task.id);
      expect(updated.taskNumber, task.taskNumber);
      expect(updated.deadline, task.deadline);
    });

    test('should parse Task with null deadline', () {
      final json = Map<String, dynamic>.from(sampleTaskJson);
      json['deadline'] = null;

      final task = Task.fromJson(json);

      expect(task.status, 'pending');
      expect(task.deadline, isNull);
    });

    test('should parse Task without deadline key', () {
      final json = Map<String, dynamic>.from(sampleTaskJson)
        ..remove('deadline');

      final task = Task.fromJson(json);

      expect(task.deadline, isNull);
    });
  });
}
