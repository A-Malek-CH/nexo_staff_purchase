// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Order _$OrderFromJson(Map<String, dynamic> json) => Order(
      id: json['_id'] as String,
      orderNumber: json['order_number'] as String,
      bon: json['bon'] as String?,
      supplierId: Supplier.fromJson(json['supplier_id'] as Map<String, dynamic>),
      staffId: json['staff_id'] == null
          ? null
          : User.fromJson(json['staff_id'] as Map<String, dynamic>),
      status: json['status'] as String,
      totalAmount: (json['total_amount'] as num).toDouble(),
      items: (json['items'] as List<dynamic>)
          .map((e) => ProductOrder.fromJson(e as Map<String, dynamic>))
          .toList(),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
      expectedDate: json['expected_date'] == null
          ? null
          : DateTime.parse(json['expected_date'] as String),
      assignedDate: json['assigned_date'] == null
          ? null
          : DateTime.parse(json['assigned_date'] as String),
      pendingReviewDate: json['pending_review_date'] == null
          ? null
          : DateTime.parse(json['pending_review_date'] as String),
      verifiedDate: json['verified_date'] == null
          ? null
          : DateTime.parse(json['verified_date'] as String),
      paidDate: json['paid_date'] == null
          ? null
          : DateTime.parse(json['paid_date'] as String),
      canceledDate: json['canceled_date'] == null
          ? null
          : DateTime.parse(json['canceled_date'] as String),
      statusHistory: (json['status_history'] as List<dynamic>)
          .map((e) => StatusHistoryEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$OrderToJson(Order instance) => <String, dynamic>{
      '_id': instance.id,
      'order_number': instance.orderNumber,
      'bon': instance.bon,
      'supplier_id': instance.supplierId.toJson(),
      'staff_id': instance.staffId?.toJson(),
      'status': instance.status,
      'total_amount': instance.totalAmount,
      'items': instance.items.map((e) => e.toJson()).toList(),
      'notes': instance.notes,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
      'expected_date': instance.expectedDate?.toIso8601String(),
      'assigned_date': instance.assignedDate?.toIso8601String(),
      'pending_review_date': instance.pendingReviewDate?.toIso8601String(),
      'verified_date': instance.verifiedDate?.toIso8601String(),
      'paid_date': instance.paidDate?.toIso8601String(),
      'canceled_date': instance.canceledDate?.toIso8601String(),
      'status_history': instance.statusHistory.map((e) => e.toJson()).toList(),
    };

ProductOrder _$ProductOrderFromJson(Map<String, dynamic> json) => ProductOrder(
      id: json['_id'] as String,
      productId: Product.fromJson(json['product_id'] as Map<String, dynamic>),
      quantity: json['quantity'] as int,
      expirationDate: json['expiration_date'] == null
          ? null
          : DateTime.parse(json['expiration_date'] as String),
      unitCost: (json['unit_cost'] as num).toDouble(),
      remainingQte: json['remaining_qte'] as int,
      isExpired: json['is_expired'] as bool,
      expiredQuantity: json['expired_quantity'] as int,
    );

Map<String, dynamic> _$ProductOrderToJson(ProductOrder instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'product_id': instance.productId.toJson(),
      'quantity': instance.quantity,
      'expiration_date': instance.expirationDate?.toIso8601String(),
      'unit_cost': instance.unitCost,
      'remaining_qte': instance.remainingQte,
      'is_expired': instance.isExpired,
      'expired_quantity': instance.expiredQuantity,
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
