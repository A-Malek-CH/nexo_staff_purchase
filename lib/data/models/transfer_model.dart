import 'package:json_annotation/json_annotation.dart';
import 'task_model.dart';

part 'transfer_model.g.dart';

@JsonSerializable()
class TransferStock {
  @JsonKey(name: '_id')
  final String id;
  final String name;
  final String? location;

  TransferStock({
    required this.id,
    required this.name,
    this.location,
  });

  factory TransferStock.fromJson(Map<String, dynamic> json) =>
      _$TransferStockFromJson(json);
  Map<String, dynamic> toJson() => _$TransferStockToJson(this);
}

@JsonSerializable()
class TransferItem {
  @JsonKey(name: '_id')
  final String id;
  final String? productName;
  final int? quantity;

  TransferItem({
    required this.id,
    this.productName,
    this.quantity,
  });

  factory TransferItem.fromJson(Map<String, dynamic> json) =>
      _$TransferItemFromJson(json);
  Map<String, dynamic> toJson() => _$TransferItemToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Transfer {
  @JsonKey(name: '_id')
  final String id;
  final List<TransferItem> items;
  final TransferStock takenFrom;
  final TransferStock takenTo;
  final int quantity;
  final String status;
  final Staff assignedTo;
  final DateTime startTime;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Transfer({
    required this.id,
    required this.items,
    required this.takenFrom,
    required this.takenTo,
    required this.quantity,
    required this.status,
    required this.assignedTo,
    required this.startTime,
    required this.createdAt,
    this.updatedAt,
  });

  factory Transfer.fromJson(Map<String, dynamic> json) =>
      _$TransferFromJson(json);
  Map<String, dynamic> toJson() => _$TransferToJson(this);

  Transfer copyWith({
    String? id,
    List<TransferItem>? items,
    TransferStock? takenFrom,
    TransferStock? takenTo,
    int? quantity,
    String? status,
    Staff? assignedTo,
    DateTime? startTime,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Transfer(
      id: id ?? this.id,
      items: items ?? this.items,
      takenFrom: takenFrom ?? this.takenFrom,
      takenTo: takenTo ?? this.takenTo,
      quantity: quantity ?? this.quantity,
      status: status ?? this.status,
      assignedTo: assignedTo ?? this.assignedTo,
      startTime: startTime ?? this.startTime,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
