import 'package:json_annotation/json_annotation.dart';

part 'product_model.g.dart';

@JsonSerializable()
class Category {
  @JsonKey(name: '_id')
  final String id;
  final String? name;
  final String? description;
  final String? image;

  Category({
    required this.id,
    this.name,
    this.description,
    this.image,
  });

  factory Category.fromJson(Map<String, dynamic> json) => _$CategoryFromJson(json);
  Map<String, dynamic> toJson() => _$CategoryToJson(this);
}

@JsonSerializable()
class Product {
  @JsonKey(name: '_id')
  final String id;
  final String name;
  final String? description;
  final String? barcode;
  @JsonKey(name: 'categoryId')
  final Category? categoryId;
  final double? price;
  @JsonKey(name: 'minQty')
  final int? minQty;
  @JsonKey(name: 'recommendedQty')
  final int? recommendedQty;
  final String? unit;
  @JsonKey(name: 'currentStock')
  final int? currentStock;
  final String? imageUrl;
  @JsonKey(defaultValue: true)
  final bool isActive;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Product({
    required this.id,
    required this.name,
    this.description,
    this.barcode,
    this.categoryId,
    this.price,
    this.minQty,
    this.recommendedQty,
    this.unit,
    this.currentStock,
    this.imageUrl,
    this.isActive = true,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) =>
      _$ProductFromJson(json);
  Map<String, dynamic> toJson() => _$ProductToJson(this);

  // Helper to get category name
  String? get categoryName => categoryId?.name;

  Product copyWith({
    String? id,
    String? name,
    String? description,
    String? barcode,
    Category? categoryId,
    double? price,
    int? minQty,
    int? recommendedQty,
    String? unit,
    int? currentStock,
    String? imageUrl,
    bool? isActive,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      barcode: barcode ?? this.barcode,
      categoryId: categoryId ?? this.categoryId,
      price: price ?? this.price,
      minQty: minQty ?? this.minQty,
      recommendedQty: recommendedQty ?? this.recommendedQty,
      unit: unit ?? this.unit,
      currentStock: currentStock ?? this.currentStock,
      imageUrl: imageUrl ?? this.imageUrl,
      isActive: isActive ?? this.isActive,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
