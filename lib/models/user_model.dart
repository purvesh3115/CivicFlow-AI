enum UserRole {
  citizen,
  officer,
  admin;

  static UserRole fromString(String? role) {
    switch (role?.toLowerCase()) {
      case 'officer':
        return UserRole.officer;
      case 'admin':
        return UserRole.admin;
      case 'citizen':
      default:
        return UserRole.citizen;
    }
  }

  String get displayName {
    switch (this) {
      case UserRole.citizen:
        return 'Citizen';
      case UserRole.officer:
        return 'Field Officer';
      case UserRole.admin:
        return 'City Administrator';
    }
  }

  String toValue() => name;
}

class UserModel {
  final String id;
  final String name;
  final String phone;
  final String email;
  final UserRole role;
  final String? city;
  final String? locationType;
  final String? avatarUrl;
  final String? department;
  final String? badgeNumber;
  final DateTime? createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.role,
    this.city,
    this.locationType,
    this.avatarUrl,
    this.department,
    this.badgeNumber,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: UserRole.fromString(json['role']?.toString()),
      city: json['city']?.toString(),
      locationType: json['location_type']?.toString(),
      avatarUrl: json['avatar_url']?.toString(),
      department: json['department']?.toString(),
      badgeNumber: json['badge_number']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'role': role.toValue(),
      'city': city,
      'location_type': locationType,
      'avatar_url': avatarUrl,
      'department': department,
      'badge_number': badgeNumber,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    UserRole? role,
    String? city,
    String? locationType,
    String? avatarUrl,
    String? department,
    String? badgeNumber,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      role: role ?? this.role,
      city: city ?? this.city,
      locationType: locationType ?? this.locationType,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      department: department ?? this.department,
      badgeNumber: badgeNumber ?? this.badgeNumber,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
