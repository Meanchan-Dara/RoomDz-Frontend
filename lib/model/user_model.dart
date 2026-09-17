class UserModel {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String? avatar;
  final bool isVerified;
  final String? telegram;
  final String? locationTag;
  final String? bakongAccountId;
  final String? bakongMerchantName;
  final RoleModel? role;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.avatar,
    this.isVerified = false,
    this.telegram,
    this.locationTag,
    this.bakongAccountId,
    this.bakongMerchantName,
    this.role,
  });

  bool get isOwner => role?.name.toLowerCase() == 'owner';

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] is int ? json['id'] : (int.tryParse(json['id']?.toString() ?? '0') ?? 0),
      name: (json['name'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      phone: json['phone']?.toString(),
      avatar: json['avatar']?.toString(),
      isVerified: json['is_verified'] == true,
      telegram: json['telegram']?.toString(),
      locationTag: json['location_tag']?.toString(),
      bakongAccountId: json['bakong_account_id']?.toString(),
      bakongMerchantName: json['bakong_merchant_name']?.toString(),
      role: json['role'] != null && json['role'] is Map
          ? RoleModel.fromJson(Map<String, dynamic>.from(json['role']))
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'phone': phone,
    'avatar': avatar,
    'is_verified': isVerified,
    'telegram': telegram,
    'location_tag': locationTag,
    'bakong_account_id': bakongAccountId,
    'bakong_merchant_name': bakongMerchantName,
    'role': role != null ? {'id': role!.id, 'name': role!.name} : null,
  };
}

class RoleModel {
  final int id;
  final String name;
  RoleModel({required this.id, required this.name});

  factory RoleModel.fromJson(Map<String, dynamic> json) =>
      RoleModel(
        id: json['id'] is int ? json['id'] : (int.tryParse(json['id']?.toString() ?? '0') ?? 0),
        name: (json['name'] ?? '').toString(),
      );
}