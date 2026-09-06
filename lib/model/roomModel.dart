class RoomModel {
  final int id;
  final String title;
  final double price;
  final String address;
  final double latitude;
  final double longitude;
  final String image;

  RoomModel({
    required this.id,
    required this.title,
    required this.price,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.image,
  });
}

final List<RoomModel> rooms = [
    RoomModel(
      id: 1,
      title: "Room Near NUM",
      price: 150,
      address: "Phnom Penh",
      latitude: 11.5564,
      longitude: 104.9282,
      image: "https://images.unsplash.com/photo-1522708323590-d24dbb6b0267",
    ),

    RoomModel(
      id: 2,
      title: "Modern Room",
      price: 180,
      address: "Toul Kork",
      latitude: 11.5846,
      longitude: 104.8998,
      image: "https://images.unsplash.com/photo-1560185008-b033106af5c3",
    ),

    RoomModel(
      id: 3,
      title: "Small Cozy Room",
      price: 120,
      address: "Sen Sok",
      latitude: 11.6055,
      longitude: 104.8759,
      image: "https://images.unsplash.com/photo-1505693416388-ac5ce068fe85",
    ),
  ];
