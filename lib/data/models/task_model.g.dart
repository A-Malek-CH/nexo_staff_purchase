// GENERATED CODE - DO NOT MODIFY BY HAND
part of 'task_model.dart';

Task _$TaskFromJson(Map<String, dynamic> json) => Task(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      status: json['status'] as String,
      priority: json['priority'] as String,
      deadline: DateTime.parse(json['deadline'] as String),
      supplierId: json['supplierId'] as String?,
      supplierName: json['supplierName'] as String?,
      assignedTo: json['assignedTo'] as String?,
      assignedBy: json['assignedBy'] as String?,
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => TaskItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
    );

Map<String, dynamic> _$TaskToJson(Task instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'status': instance.status,
      'priority': instance.priority,
      'deadline': instance.deadline.toIso8601String(),
      'supplierId': instance.supplierId,
      'supplierName': instance.supplierName,
      'assignedTo': instance.assignedTo,
      'assignedBy': instance.assignedBy,
      'items': instance.items.map((e) => e.toJson()).toList(),
      'notes': instance.notes,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'completedAt': instance.completedAt?.toIso8601String(),
    };
