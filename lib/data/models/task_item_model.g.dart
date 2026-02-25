// GENERATED CODE - DO NOT MODIFY BY HAND
part of 'task_item_model.dart';

TaskItem _$TaskItemFromJson(Map<String, dynamic> json) => TaskItem(
      id: json['id'] as String,
      taskId: json['taskId'] as String,
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      requestedQuantity: json['requestedQuantity'] as int,
      actualQuantity: json['actualQuantity'] as int?,
      requestedPrice: (json['requestedPrice'] as num?)?.toDouble(),
      actualPrice: (json['actualPrice'] as num?)?.toDouble(),
      status: json['status'] as String,
      isAvailable: (json['isAvailable'] as bool?) ?? false,
      notes: json['notes'] as String?,
      receiptUrl: json['receiptUrl'] as String?,
      photoUrl: json['photoUrl'] as String?,
      purchasedAt: json['purchasedAt'] == null
          ? null
          : DateTime.parse(json['purchasedAt'] as String),
    );

Map<String, dynamic> _$TaskItemToJson(TaskItem instance) => <String, dynamic>{
      'id': instance.id,
      'taskId': instance.taskId,
      'productId': instance.productId,
      'productName': instance.productName,
      'requestedQuantity': instance.requestedQuantity,
      'actualQuantity': instance.actualQuantity,
      'requestedPrice': instance.requestedPrice,
      'actualPrice': instance.actualPrice,
      'status': instance.status,
      'isAvailable': instance.isAvailable,
      'notes': instance.notes,
      'receiptUrl': instance.receiptUrl,
      'photoUrl': instance.photoUrl,
      'purchasedAt': instance.purchasedAt?.toIso8601String(),
    };
