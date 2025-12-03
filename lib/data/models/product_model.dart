import 'package:json_annotation/json_annotation.dart';

part 'product_model.g.dart';

@JsonSerializable()
class Product {
  final String id;
  final String name;
  final String? description;
  final String? sku;
  final String? categoryId;
  final String? categoryName;
  final double? price;
  final int? minQuantity;
  final String? unit;
  final int? currentStock;
  final String? imageUrl;
  final List<String>? images;
  @JsonKey(defaultValue: true)
  final bool isActive;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Product({
    required this.id,
    required this.name,
    this.description,
    this.sku,
    this.categoryId,
    this.categoryName,
    this.price,
    this.minQuantity,
    this.unit,
    this.currentStock,
    this.imageUrl,
    this.images,
    required this.isActive,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) =>
      _$ProductFromJson(json);
  Map<String, dynamic> toJson() => _$ProductToJson(this);

  Product copyWith({
    String? id,
    String? name,
    String? description,
    String? sku,
    String? categoryId,
    String? categoryName,
    double? price,
    int? minQuantity,
    String? unit,
    int? currentStock,
    String? imageUrl,
    List<String>? images,
    bool? isActive,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      sku: sku ?? this.sku,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      price: price ?? this.price,
      minQuantity: minQuantity ?? this.minQuantity,
      unit: unit ?? this.unit,
      currentStock: currentStock ?? this.currentStock,
      imageUrl: imageUrl ?? this.imageUrl,
      images: images ?? this.images,
      isActive: isActive ?? this.isActive,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
