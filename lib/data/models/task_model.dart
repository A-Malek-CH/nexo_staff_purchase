import 'package:json_annotation/json_annotation.dart';
import 'task_item_model.dart';

part 'task_model.g.dart';

@JsonSerializable()
class Task {
  final String id;
  final String title;
  final String? description;
  final String status;
  final String priority;
  final DateTime deadline;
  final String? supplierId;
  final String? supplierName;
  final String assignedTo;
  final String assignedBy;
  final List<TaskItem> items;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? completedAt;

  Task({
    required this.id,
    required this.title,
    this.description,
    required this.status,
    required this.priority,
    required this.deadline,
    this.supplierId,
    this.supplierName,
    required this.assignedTo,
    required this.assignedBy,
    required this.items,
    this.notes,
    required this.createdAt,
    this.updatedAt,
    this.completedAt,
  });

  factory Task.fromJson(Map<String, dynamic> json) => _$TaskFromJson(json);
  Map<String, dynamic> toJson() => _$TaskToJson(this);

  Task copyWith({
    String? id,
    String? title,
    String? description,
    String? status,
    String? priority,
    DateTime? deadline,
    String? supplierId,
    String? supplierName,
    String? assignedTo,
    String? assignedBy,
    List<TaskItem>? items,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? completedAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      deadline: deadline ?? this.deadline,
      supplierId: supplierId ?? this.supplierId,
      supplierName: supplierName ?? this.supplierName,
      assignedTo: assignedTo ?? this.assignedTo,
      assignedBy: assignedBy ?? this.assignedBy,
      items: items ?? this.items,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}
