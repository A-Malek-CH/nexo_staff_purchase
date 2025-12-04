import 'package:json_annotation/json_annotation.dart';
import 'user_model.dart';
import 'supplier_model.dart';
import 'product_model.dart';

part 'order_model.g.dart';

@JsonSerializable(explicitToJson: true)
class Order {
  @JsonKey(name: '_id')
  final String id;
  final String orderNumber;
  final String? bon; // Receipt/bill image URL
  @JsonKey(name: 'supplierId')
  final Supplier supplierId;
  @JsonKey(name: 'staffId')
  final User? staffId;
  final String status; // "not assigned", "assigned", "confirmed", "paid", "canceled"
  final double totalAmount;
  final List<ProductOrder> items;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? expectedDate;
  final DateTime? assignedDate;
  final DateTime? pendingReviewDate;
  final DateTime? verifiedDate;
  final DateTime? paidDate;
  final DateTime? canceledDate;
  @JsonKey(defaultValue: [])
  final List<StatusHistoryEntry> statusHistory;

  Order({
    required this.id,
    required this.orderNumber,
    this.bon,
    required this.supplierId,
    this.staffId,
    required this.status,
    required this.totalAmount,
    required this.items,
    this.notes,
    required this.createdAt,
    this.updatedAt,
    this.expectedDate,
    this.assignedDate,
    this.pendingReviewDate,
    this.verifiedDate,
    this.paidDate,
    this.canceledDate,
    required this.statusHistory,
  });

  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);
  Map<String, dynamic> toJson() => _$OrderToJson(this);

  Order copyWith({
    String? id,
    String? orderNumber,
    String? bon,
    Supplier? supplierId,
    User? staffId,
    String? status,
    double? totalAmount,
    List<ProductOrder>? items,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? expectedDate,
    DateTime? assignedDate,
    DateTime? pendingReviewDate,
    DateTime? verifiedDate,
    DateTime? paidDate,
    DateTime? canceledDate,
    List<StatusHistoryEntry>? statusHistory,
  }) {
    return Order(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      bon: bon ?? this.bon,
      supplierId: supplierId ?? this.supplierId,
      staffId: staffId ?? this.staffId,
      status: status ?? this.status,
      totalAmount: totalAmount ?? this.totalAmount,
      items: items ?? this.items,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      expectedDate: expectedDate ?? this.expectedDate,
      assignedDate: assignedDate ?? this.assignedDate,
      pendingReviewDate: pendingReviewDate ?? this.pendingReviewDate,
      verifiedDate: verifiedDate ?? this.verifiedDate,
      paidDate: paidDate ?? this.paidDate,
      canceledDate: canceledDate ?? this.canceledDate,
      statusHistory: statusHistory ?? this.statusHistory,
    );
  }
}

@JsonSerializable(explicitToJson: true)
class ProductOrder {
  @JsonKey(name: '_id')
  final String id;
  @JsonKey(name: 'productId')
  final Product productId;
  final int quantity;
  final DateTime? expirationDate;
  final double unitCost;
  final int remainingQte;
  final bool isExpired;
  final int expiredQuantity;

  ProductOrder({
    required this.id,
    required this.productId,
    required this.quantity,
    this.expirationDate,
    required this.unitCost,
    required this.remainingQte,
    required this.isExpired,
    required this.expiredQuantity,
  });

  factory ProductOrder.fromJson(Map<String, dynamic> json) =>
      _$ProductOrderFromJson(json);
  Map<String, dynamic> toJson() => _$ProductOrderToJson(this);

  ProductOrder copyWith({
    String? id,
    Product? productId,
    int? quantity,
    DateTime? expirationDate,
    double? unitCost,
    int? remainingQte,
    bool? isExpired,
    int? expiredQuantity,
  }) {
    return ProductOrder(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
      expirationDate: expirationDate ?? this.expirationDate,
      unitCost: unitCost ?? this.unitCost,
      remainingQte: remainingQte ?? this.remainingQte,
      isExpired: isExpired ?? this.isExpired,
      expiredQuantity: expiredQuantity ?? this.expiredQuantity,
    );
  }
}

@JsonSerializable()
class StatusHistoryEntry {
  final String? from;
  final String to;
  final DateTime at;
  final String? by;

  StatusHistoryEntry({
    this.from,
    required this.to,
    required this.at,
    this.by,
  });

  factory StatusHistoryEntry.fromJson(Map<String, dynamic> json) =>
      _$StatusHistoryEntryFromJson(json);
  Map<String, dynamic> toJson() => _$StatusHistoryEntryToJson(this);
}
