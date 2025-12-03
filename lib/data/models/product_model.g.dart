// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Category _$CategoryFromJson(Map<String, dynamic> json) => Category(
      id: json['_id'] as String,
      name: json['name'] as String?,
      description: json['description'] as String?,
      image: json['image'] as String?,
    );

Map<String, dynamic> _$CategoryToJson(Category instance) => <String, dynamic>{
      '_id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'image': instance.image,
    };

Product _$ProductFromJson(Map<String, dynamic> json) => Product(
      id: json['_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      barcode: json['barcode'] as String?,
      categoryId: json['categoryId'] == null
          ? null
          : Category.fromJson(json['categoryId'] as Map<String, dynamic>),
      price: (json['price'] as num?)?.toDouble(),
      minQty: (json['minQty'] as int?),
      recommendedQty: (json['recommendedQty'] as int?),
      unit: json['unit'] as String?,
      currentStock: (json['currentStock'] as int?),
      imageUrl: json['image_url'] as String?,
      isActive: (json['is_active'] as bool?) ?? true,
      notes: json['notes'] as String?,
      createdAt: json['created_at'] == null ? null : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null ? null : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$ProductToJson(Product instance) => <String, dynamic>{
      '_id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'barcode': instance.barcode,
      'categoryId': instance.categoryId?.toJson(),
      'price': instance.price,
      'minQty': instance.minQty,
      'recommendedQty': instance.recommendedQty,
      'unit': instance.unit,
      'currentStock': instance.currentStock,
      'image_url': instance.imageUrl,
      'is_active': instance.isActive,
      'notes': instance.notes,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };
