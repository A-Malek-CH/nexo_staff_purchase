// GENERATED CODE - DO NOT MODIFY BY HAND
part of 'supplier_model.dart';

Supplier _$SupplierFromJson(Map<String, dynamic> json) => Supplier(
      id: json['_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      contactPerson: json['contactPerson'] as String?,
      phone1: json['phone1'] as String?,
      phone2: json['phone2'] as String?,
      phone3: json['phone3'] as String?,
      email: json['email'] as String?,
      address: json['address'] as String?,
      city: json['city'] as String?,
      country: json['country'] as String?,
      notes: json['notes'] as String?,
      image: json['image'] as String?,
      isActive: (json['isActive'] as bool?) ?? true,
      createdAt: json['createdAt'] == null ? null : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null ? null : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$SupplierToJson(Supplier instance) => <String, dynamic>{
      '_id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'contactPerson': instance.contactPerson,
      'phone1': instance.phone1,
      'phone2': instance.phone2,
      'phone3': instance.phone3,
      'email': instance.email,
      'address': instance.address,
      'city': instance.city,
      'country': instance.country,
      'notes': instance.notes,
      'image': instance.image,
      'isActive': instance.isActive,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
