class StaffMember {
  final String id;
  final String fullname;
  final String email;
  final String? phone;
  final String? phone2;
  final String? phone3;
  final String? address;
  final String? avatar;
  final String role;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  StaffMember({
    required this.id,
    required this.fullname,
    required this.email,
    this.phone,
    this.phone2,
    this.phone3,
    this.address,
    this.avatar,
    this.role = 'staff',
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  String get name => fullname;

  factory StaffMember.fromJson(Map<String, dynamic> json) {
    return StaffMember(
      id: (json['_id'] ?? json['id'] ?? '') as String,
      fullname: (json['fullname'] ?? '') as String,
      email: (json['email'] ?? '') as String,
      phone: json['phone1'] as String?,
      phone2: json['phone2'] as String?,
      phone3: json['phone3'] as String?,
      address: json['address'] as String?,
      avatar: json['avatar'] as String?,
      role: (json['role'] ?? 'staff') as String,
      isActive: (json['isActive'] ?? true) as bool,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'fullname': fullname,
      'email': email,
      'phone1': phone,
      'phone2': phone2,
      'phone3': phone3,
      'address': address,
      'avatar': avatar,
      'role': role,
      'isActive': isActive,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  StaffMember copyWith({
    String? id,
    String? fullname,
    String? email,
    String? phone,
    String? phone2,
    String? phone3,
    String? address,
    String? avatar,
    String? role,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StaffMember(
      id: id ?? this.id,
      fullname: fullname ?? this.fullname,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      phone2: phone2 ?? this.phone2,
      phone3: phone3 ?? this.phone3,
      address: address ?? this.address,
      avatar: avatar ?? this.avatar,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
