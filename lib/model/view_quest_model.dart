class ViewingRequestModel {
  final int id;
  final RoomSummary? room;
  final RequesterSummary? requester;
  final String? name;
  final String? phone;
  final String? email;
  final String? preferredDate;
  final String? preferredTime;
  final String? notes;
  final String status;
  final String? createdAt;
  final String? updatedAt;

  ViewingRequestModel({
    required this.id,
    this.room,
    this.requester,
    this.name,
    this.phone,
    this.email,
    this.preferredDate,
    this.preferredTime,
    this.notes,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory ViewingRequestModel.fromJson(Map<String, dynamic> json) {
    return ViewingRequestModel(
      id: json['id'] ?? 0,
      room: json['room'] != null ? RoomSummary.fromJson(json['room']) : null,
      requester: json['requester'] != null
          ? RequesterSummary.fromJson(json['requester'])
          : null,
      name: json['name'],
      phone: json['phone'],
      email: json['email'],
      preferredDate: json['preferred_date'],
      preferredTime: json['preferred_time'],
      notes: json['notes'],
      status: json['status'] ?? 'pending',
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}

class RoomSummary {
  final int id;
  final String? name;
  final double price;
  final String? address;
  final String? image;

  RoomSummary({
    required this.id,
    this.name,
    required this.price,
    this.address,
    this.image,
  });

  factory RoomSummary.fromJson(Map<String, dynamic> json) {
    return RoomSummary(
      id: json['id'] ?? 0,
      name: json['name'],
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0,
      address: json['address'],
      image: json['image'],
    );
  }
}

class RequesterSummary {
  final int id;
  final String? name;
  final String? email;
  final String? phone;
  final String? avatar;

  RequesterSummary({
    required this.id,
    this.name,
    this.email,
    this.phone,
    this.avatar,
  });

  factory RequesterSummary.fromJson(Map<String, dynamic> json) {
    return RequesterSummary(
      id: json['id'] ?? 0,
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      avatar: json['avatar'],
    );
  }
}
