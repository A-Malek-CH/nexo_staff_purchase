import 'package:json_annotation/json_annotation.dart';

part 'supplier_model.g.dart';

@JsonSerializable()
class Supplier {
  @JsonKey(name: '_id')
  final String id;
  final String name;
  final String? description;
  final String? contactPerson;
  final String? phone1;
  final String? phone2;
  final String? phone3;
  final String? email;
  final String? address;
  final String? city;
  final String? country;
  final String? notes;
  final String? image;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Supplier({
    required this.id,
    required this.name,
    this.description,
    this.contactPerson,
    this.phone1,
    this.phone2,
    this.phone3,
    this.email,
    this.address,
    this.city,
    this.country,
    this.notes,
    this.image,
    required this.isActive,
    this.createdAt,
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
    String? phone1,
    String? phone2,
    String? phone3,
    String? email,
    String? address,
    String? city,
    String? country,
    String? notes,
    String? image,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Supplier(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      contactPerson: contactPerson ?? this.contactPerson,
      phone1: phone1 ?? this.phone1,
      phone2: phone2 ?? this.phone2,
      phone3: phone3 ?? this.phone3,
      email: email ?? this.email,
      address: address ?? this.address,
      city: city ?? this.city,
      country: country ?? this.country,
      notes: notes ?? this.notes,
      image: image ?? this.image,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
