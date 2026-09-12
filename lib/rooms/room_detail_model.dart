// To parse this JSON data, do
//
//     final roomDetialModel = roomDetialModelFromJson(jsonString);

import 'dart:convert';

RoomDetialModel roomDetialModelFromJson(String str) =>
    RoomDetialModel.fromJson(json.decode(str));

String roomDetialModelToJson(RoomDetialModel data) =>
    json.encode(data.toJson());

class RoomDetialModel {
  final Data data;

  RoomDetialModel({required this.data});

  factory RoomDetialModel.fromJson(Map<String, dynamic> json) =>
      RoomDetialModel(data: Data.fromJson(json["data"]));

  Map<String, dynamic> toJson() => {"data": data.toJson()};
}

class Data {
  final int id;
  final int categoryId;
  final Category category;
  final String name;
  final String status;
  final int price;
  final double rating;
  final int reviewsCount;
  final String address;
  final String about;
  final String description;
  final String image;
  final List<String> images;
  final int imagesCount;
  final List<String> facilities;
  final RoomInformation roomInformation;
  final List<String> houseRules;
  final Location location;
  final bool isFavorite;
  final String createdAt;
  final String updatedAt;

  Data({
    required this.id,
    required this.categoryId,
    required this.category,
    required this.name,
    required this.status,
    required this.price,
    required this.rating,
    required this.reviewsCount,
    required this.address,
    required this.about,
    required this.description,
    required this.image,
    required this.images,
    required this.imagesCount,
    required this.facilities,
    required this.roomInformation,
    required this.houseRules,
    required this.location,
    required this.isFavorite,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    id: json["id"],
    categoryId: json["category_id"],
    category: Category.fromJson(json["category"]),
    name: json["name"],
    status: json["status"],
    price: json["price"],
    rating: json["rating"]?.toDouble(),
    reviewsCount: json["reviews_count"],
    address: json["address"],
    about: json["about"],
    description: json["description"],
    image: json["image"],
    images: List<String>.from(json["images"].map((x) => x)),
    imagesCount: json["images_count"],
    facilities: List<String>.from(json["facilities"].map((x) => x)),
    roomInformation: RoomInformation.fromJson(json["room_information"]),
    houseRules: List<String>.from(json["house_rules"].map((x) => x)),
    location: Location.fromJson(json["location"]),
    isFavorite: json["is_favorite"],
    createdAt: json["created_at"],
    updatedAt: json["updated_at"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "category_id": categoryId,
    "category": category.toJson(),
    "name": name,
    "status": status,
    "price": price,
    "rating": rating,
    "reviews_count": reviewsCount,
    "address": address,
    "about": about,
    "description": description,
    "image": image,
    "images": List<dynamic>.from(images.map((x) => x)),
    "images_count": imagesCount,
    "facilities": List<dynamic>.from(facilities.map((x) => x)),
    "room_information": roomInformation.toJson(),
    "house_rules": List<dynamic>.from(houseRules.map((x) => x)),
    "location": location.toJson(),
    "is_favorite": isFavorite,
    "created_at": createdAt,
    "updated_at": updatedAt,
  };
}

class Category {
  final int id;
  final String name;
  final String slug;
  final dynamic image;

  Category({
    required this.id,
    required this.name,
    required this.slug,
    required this.image,
  });

  factory Category.fromJson(Map<String, dynamic> json) => Category(
    id: json["id"],
    name: json["name"],
    slug: json["slug"],
    image: json["image"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "slug": slug,
    "image": image,
  };
}

class Location {
  final String address;
  final double latitude;
  final double longitude;

  Location({
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  factory Location.fromJson(Map<String, dynamic> json) => Location(
    address: json["address"],
    latitude: json["latitude"]?.toDouble(),
    longitude: json["longitude"]?.toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "address": address,
    "latitude": latitude,
    "longitude": longitude,
  };
}

class RoomInformation {
  final String type;
  final String size;
  final String floor;
  final String deposit;

  RoomInformation({
    required this.type,
    required this.size,
    required this.floor,
    required this.deposit,
  });

  factory RoomInformation.fromJson(Map<String, dynamic> json) =>
      RoomInformation(
        type: json["type"],
        size: json["size"],
        floor: json["floor"],
        deposit: json["deposit"],
      );

  Map<String, dynamic> toJson() => {
    "type": type,
    "size": size,
    "floor": floor,
    "deposit": deposit,
  };
}
