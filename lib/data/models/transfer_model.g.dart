// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transfer_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TransferStock _$TransferStockFromJson(Map<String, dynamic> json) =>
    TransferStock(
      id: json['_id'] as String,
      name: json['name'] as String,
      location: json['location'] as String?,
    );

Map<String, dynamic> _$TransferStockToJson(TransferStock instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'name': instance.name,
      'location': instance.location,
    };

TransferItem _$TransferItemFromJson(Map<String, dynamic> json) => TransferItem(
      id: json['_id'] as String,
      productName: json['productName'] as String?,
      quantity: (json['quantity'] as num?)?.toInt(),
    );

Map<String, dynamic> _$TransferItemToJson(TransferItem instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'productName': instance.productName,
      'quantity': instance.quantity,
    };

Transfer _$TransferFromJson(Map<String, dynamic> json) => Transfer(
      id: json['_id'] as String,
      items: (json['items'] as List<dynamic>)
          .map((e) => TransferItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      takenFrom:
          TransferStock.fromJson(json['takenFrom'] as Map<String, dynamic>),
      takenTo: TransferStock.fromJson(json['takenTo'] as Map<String, dynamic>),
      quantity: (json['quantity'] as num).toInt(),
      status: json['status'] as String,
      assignedTo: Staff.fromJson(json['assignedTo'] as Map<String, dynamic>),
      startTime: DateTime.parse(json['startTime'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$TransferToJson(Transfer instance) => <String, dynamic>{
      '_id': instance.id,
      'items': instance.items.map((e) => e.toJson()).toList(),
      'takenFrom': instance.takenFrom.toJson(),
      'takenTo': instance.takenTo.toJson(),
      'quantity': instance.quantity,
      'status': instance.status,
      'assignedTo': instance.assignedTo.toJson(),
      'startTime': instance.startTime.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
