// GENERATED CODE - DO NOT MODIFY BY HAND
part of 'supplier_model.dart';

Supplier _$SupplierFromJson(Map<String, dynamic> json) => Supplier(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      contactPerson: json['contact_person'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      address: json['address'] as String?,
      city: json['city'] as String?,
      country: json['country'] as String?,
      notes: json['notes'] as String?,
      isActive: json['is_active'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null ? null : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$SupplierToJson(Supplier instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'contact_person': instance.contactPerson,
      'phone': instance.phone,
      'email': instance.email,
      'address': instance.address,
      'city': instance.city,
      'country': instance.country,
      'notes': instance.notes,
      'is_active': instance.isActive,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };
