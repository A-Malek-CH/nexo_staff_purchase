// GENERATED CODE - DO NOT MODIFY BY HAND
part of 'product_model.dart';

Product _$ProductFromJson(Map<String, dynamic> json) => Product(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      sku: json['sku'] as String,
      categoryId: json['category_id'] as String?,
      categoryName: json['category_name'] as String?,
      price: (json['price'] as num?)?.toDouble(),
      minQuantity: json['min_quantity'] as int?,
      unit: json['unit'] as String?,
      imageUrl: json['image_url'] as String?,
      images: (json['images'] as List<dynamic>?)?.map((e) => e as String).toList(),
      isActive: json['is_active'] as bool,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null ? null : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$ProductToJson(Product instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'sku': instance.sku,
      'category_id': instance.categoryId,
      'category_name': instance.categoryName,
      'price': instance.price,
      'min_quantity': instance.minQuantity,
      'unit': instance.unit,
      'image_url': instance.imageUrl,
      'images': instance.images,
      'is_active': instance.isActive,
      'notes': instance.notes,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };
