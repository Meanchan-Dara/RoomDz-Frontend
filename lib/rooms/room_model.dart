class RoomModel {
  final int id;
  final String name;
  final String? type;
  final double price;
  final int? categoryId;

  RoomModel({
    required this.id,
    required this.name,
    this.type,
    required this.price,
    this.categoryId,
  });

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    return RoomModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      type: json['type'],
      price: double.tryParse(json['price'].toString()) ?? 0,
      categoryId: json['category_id'],
    );
  }
}
