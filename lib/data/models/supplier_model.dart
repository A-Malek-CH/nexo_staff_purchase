import 'package:json_annotation/json_annotation.dart';

part 'supplier_model.g.dart';

@JsonSerializable()
class Supplier {
  final String id;
  final String name;
  final String? description;
  final String? contactPerson;
  final String? phone;
  final String? email;
  final String? address;
  final String? city;
  final String? country;
  final String? notes;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Supplier({
    required this.id,
    required this.name,
    this.description,
    this.contactPerson,
    this.phone,
    this.email,
    this.address,
    this.city,
    this.country,
    this.notes,
    required this.isActive,
    required this.createdAt,
    this.updatedAt,
  });

  factory Supplier.fromJson(Map<String, dynamic> json) =>
      _$SupplierFromJson(json);
  Map<String, dynamic> toJson() => _$SupplierToJson(this);

  Supplier copyWith({
    String? id,
    String? name,
    String? description,
    String? contactPerson,
    String? phone,
    String? email,
    String? address,
    String? city,
    String? country,
    String? notes,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Supplier(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      contactPerson: contactPerson ?? this.contactPerson,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      city: city ?? this.city,
      country: country ?? this.country,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
