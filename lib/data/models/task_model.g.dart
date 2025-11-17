// GENERATED CODE - DO NOT MODIFY BY HAND
part of 'task_model.dart';

Task _$TaskFromJson(Map<String, dynamic> json) => Task(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      status: json['status'] as String,
      priority: json['priority'] as String,
      deadline: DateTime.parse(json['deadline'] as String),
      supplierId: json['supplier_id'] as String?,
      supplierName: json['supplier_name'] as String?,
      assignedTo: json['assigned_to'] as String,
      assignedBy: json['assigned_by'] as String,
      items: (json['items'] as List<dynamic>).map((e) => TaskItem.fromJson(e as Map<String, dynamic>)).toList(),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null ? null : DateTime.parse(json['updated_at'] as String),
      completedAt: json['completed_at'] == null ? null : DateTime.parse(json['completed_at'] as String),
    );

Map<String, dynamic> _$TaskToJson(Task instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'status': instance.status,
      'priority': instance.priority,
      'deadline': instance.deadline.toIso8601String(),
      'supplier_id': instance.supplierId,
      'supplier_name': instance.supplierName,
      'assigned_to': instance.assignedTo,
      'assigned_by': instance.assignedBy,
      'items': instance.items.map((e) => e.toJson()).toList(),
      'notes': instance.notes,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
      'completed_at': instance.completedAt?.toIso8601String(),
    };
