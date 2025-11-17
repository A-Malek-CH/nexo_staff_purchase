import 'package:json_annotation/json_annotation.dart';

part 'task_item_model.g.dart';

@JsonSerializable()
class TaskItem {
  final String id;
  final String taskId;
  final String productId;
  final String productName;
  final int requestedQuantity;
  final int? actualQuantity;
  final double? requestedPrice;
  final double? actualPrice;
  final String status;
  final bool isAvailable;
  final String? notes;
  final String? receiptUrl;
  final String? photoUrl;
  final DateTime? purchasedAt;

  TaskItem({
    required this.id,
    required this.taskId,
    required this.productId,
    required this.productName,
    required this.requestedQuantity,
    this.actualQuantity,
    this.requestedPrice,
    this.actualPrice,
    required this.status,
    required this.isAvailable,
    this.notes,
    this.receiptUrl,
    this.photoUrl,
    this.purchasedAt,
  });

  factory TaskItem.fromJson(Map<String, dynamic> json) =>
      _$TaskItemFromJson(json);
  Map<String, dynamic> toJson() => _$TaskItemToJson(this);

  TaskItem copyWith({
    String? id,
    String? taskId,
    String? productId,
    String? productName,
    int? requestedQuantity,
    int? actualQuantity,
    double? requestedPrice,
    double? actualPrice,
    String? status,
    bool? isAvailable,
    String? notes,
    String? receiptUrl,
    String? photoUrl,
    DateTime? purchasedAt,
  }) {
    return TaskItem(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      requestedQuantity: requestedQuantity ?? this.requestedQuantity,
      actualQuantity: actualQuantity ?? this.actualQuantity,
      requestedPrice: requestedPrice ?? this.requestedPrice,
      actualPrice: actualPrice ?? this.actualPrice,
      status: status ?? this.status,
      isAvailable: isAvailable ?? this.isAvailable,
      notes: notes ?? this.notes,
      receiptUrl: receiptUrl ?? this.receiptUrl,
      photoUrl: photoUrl ?? this.photoUrl,
      purchasedAt: purchasedAt ?? this.purchasedAt,
    );
  }
}
