class UserModel {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String? avatar;
  final bool isVerified;
  final RoleModel? role;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.avatar,
    this.isVerified = false,
    this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      avatar: json['avatar'],
      isVerified: json['is_verified'] ?? false,
      role: json['role'] != null ? RoleModel.fromJson(json['role']) : null,
    );
  }
}

class RoleModel {
  final int id;
  final String name;
  RoleModel({required this.id, required this.name});

  factory RoleModel.fromJson(Map<String, dynamic> json) =>
      RoleModel(id: json['id'], name: json['name']);
}