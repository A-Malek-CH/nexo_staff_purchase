import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class User {
  @JsonKey(name: '_id')
  final String id;
  final String email;
  final String fullname;
  final String? phone1;
  final String? phone2;
  final String? phone3;
  final String? avatar;
  @JsonKey(defaultValue: 'staff')
  final String role;
  @JsonKey(defaultValue: true)
  final bool isActive;
  final String? address;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  User({
    required this.id,
    required this.email,
    required this.fullname,
    this.phone1,
    this.phone2,
    this.phone3,
    this.avatar,
    this.role = 'staff',
    this.isActive = true,
    this.address,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);

  // Helper getter to maintain backward compatibility
  String get name => fullname;

  User copyWith({
    String? id,
    String? email,
    String? fullname,
    String? phone1,
    String? phone2,
    String? phone3,
    String? avatar,
    String? role,
    bool? isActive,
    String? address,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      fullname: fullname ?? this.fullname,
      phone1: phone1 ?? this.phone1,
      phone2: phone2 ?? this.phone2,
      phone3: phone3 ?? this.phone3,
      avatar: avatar ?? this.avatar,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
