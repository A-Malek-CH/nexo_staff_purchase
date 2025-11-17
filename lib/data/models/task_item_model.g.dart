// GENERATED CODE - DO NOT MODIFY BY HAND
part of 'task_item_model.dart';

TaskItem _$TaskItemFromJson(Map<String, dynamic> json) => TaskItem(
      id: json['id'] as String,
      taskId: json['task_id'] as String,
      productId: json['product_id'] as String,
      productName: json['product_name'] as String,
      requestedQuantity: json['requested_quantity'] as int,
      actualQuantity: json['actual_quantity'] as int?,
      requestedPrice: (json['requested_price'] as num?)?.toDouble(),
      actualPrice: (json['actual_price'] as num?)?.toDouble(),
      status: json['status'] as String,
      isAvailable: json['is_available'] as bool,
      notes: json['notes'] as String?,
      receiptUrl: json['receipt_url'] as String?,
      photoUrl: json['photo_url'] as String?,
      purchasedAt: json['purchased_at'] == null ? null : DateTime.parse(json['purchased_at'] as String),
    );

Map<String, dynamic> _$TaskItemToJson(TaskItem instance) => <String, dynamic>{
      'id': instance.id,
      'task_id': instance.taskId,
      'product_id': instance.productId,
      'product_name': instance.productName,
      'requested_quantity': instance.requestedQuantity,
      'actual_quantity': instance.actualQuantity,
      'requested_price': instance.requestedPrice,
      'actual_price': instance.actualPrice,
      'status': instance.status,
      'is_available': instance.isAvailable,
      'notes': instance.notes,
      'receipt_url': instance.receiptUrl,
      'photo_url': instance.photoUrl,
      'purchased_at': instance.purchasedAt?.toIso8601String(),
    };
