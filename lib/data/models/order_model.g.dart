// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Order _$OrderFromJson(Map<String, dynamic> json) => Order(
      id: json['_id'] as String,
      orderNumber: json['orderNumber'] as String,
      bon: json['bon'] as String?,
      supplierId: Supplier.fromJson(json['supplierId'] as Map<String, dynamic>),
      staffId: json['staffId'] == null
          ? null
          : User.fromJson(json['staffId'] as Map<String, dynamic>),
      status: json['status'] as String,
      totalAmount: (json['totalAmount'] as num).toDouble(),
      items: (json['items'] as List<dynamic>)
          .map((e) => ProductOrder.fromJson(e as Map<String, dynamic>))
          .toList(),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      expectedDate: json['expectedDate'] == null
          ? null
          : DateTime.parse(json['expectedDate'] as String),
      assignedDate: json['assignedDate'] == null
          ? null
          : DateTime.parse(json['assignedDate'] as String),
      pendingReviewDate: json['pendingReviewDate'] == null
          ? null
          : DateTime.parse(json['pendingReviewDate'] as String),
      verifiedDate: json['verifiedDate'] == null
          ? null
          : DateTime.parse(json['verifiedDate'] as String),
      paidDate: json['paidDate'] == null
          ? null
          : DateTime.parse(json['paidDate'] as String),
      canceledDate: json['canceledDate'] == null
          ? null
          : DateTime.parse(json['canceledDate'] as String),
      statusHistory: (json['statusHistory'] as List<dynamic>?)
              ?.map((e) => StatusHistoryEntry.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );

Map<String, dynamic> _$OrderToJson(Order instance) => <String, dynamic>{
      '_id': instance.id,
      'orderNumber': instance.orderNumber,
      'bon': instance.bon,
      'supplierId': instance.supplierId.toJson(),
      'staffId': instance.staffId?.toJson(),
      'status': instance.status,
      'totalAmount': instance.totalAmount,
      'items': instance.items.map((e) => e.toJson()).toList(),
      'notes': instance.notes,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'expectedDate': instance.expectedDate?.toIso8601String(),
      'assignedDate': instance.assignedDate?.toIso8601String(),
      'pendingReviewDate': instance.pendingReviewDate?.toIso8601String(),
      'verifiedDate': instance.verifiedDate?.toIso8601String(),
      'paidDate': instance.paidDate?.toIso8601String(),
      'canceledDate': instance.canceledDate?.toIso8601String(),
      'statusHistory': instance.statusHistory.map((e) => e.toJson()).toList(),
    };

ProductOrder _$ProductOrderFromJson(Map<String, dynamic> json) => ProductOrder(
      id: json['_id'] as String,
      productId: Product.fromJson(json['productId'] as Map<String, dynamic>),
      quantity: json['quantity'] as int,
      expirationDate: json['expirationDate'] == null
          ? null
          : DateTime.parse(json['expirationDate'] as String),
      unitCost: (json['unitCost'] as num).toDouble(),
      remainingQte: json['remainingQte'] as int,
      isExpired: json['isExpired'] as bool,
      expiredQuantity: json['expiredQuantity'] as int,
    );

Map<String, dynamic> _$ProductOrderToJson(ProductOrder instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'productId': instance.productId.toJson(),
      'quantity': instance.quantity,
      'expirationDate': instance.expirationDate?.toIso8601String(),
      'unitCost': instance.unitCost,
      'remainingQte': instance.remainingQte,
      'isExpired': instance.isExpired,
      'expiredQuantity': instance.expiredQuantity,
    };

StatusHistoryEntry _$StatusHistoryEntryFromJson(Map<String, dynamic> json) =>
    StatusHistoryEntry(
      from: json['from'] as String?,
      to: json['to'] as String,
      at: DateTime.parse(json['at'] as String),
      by: json['by'] as String?,
    );

Map<String, dynamic> _$StatusHistoryEntryToJson(StatusHistoryEntry instance) =>
    <String, dynamic>{
      'from': instance.from,
      'to': instance.to,
      'at': instance.at.toIso8601String(),
      'by': instance.by,
    };
