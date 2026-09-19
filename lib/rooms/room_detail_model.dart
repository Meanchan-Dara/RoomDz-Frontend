// To parse this JSON data, do
//
//     final roomDetialModel = roomDetialModelFromJson(jsonString);

import 'dart:convert';
import 'package:roomdz_frontend/model/roomModel.dart';

RoomDetialModel roomDetialModelFromJson(String str) =>
    RoomDetialModel.fromJson(json.decode(str));

String roomDetialModelToJson(RoomDetialModel data) =>
    json.encode(data.toJson());

class RoomDetialModel {
  final Data data;

  RoomDetialModel({required this.data});

  factory RoomDetialModel.fromJson(dynamic json) {
    if (json is Map<String, dynamic> || json is Map) {
      final map = Map<String, dynamic>.from(json);
      if (map.containsKey('data') && map['data'] is Map) {
        return RoomDetialModel(
          data: Data.fromJson(Map<String, dynamic>.from(map['data'])),
        );
      }
      return RoomDetialModel(data: Data.fromJson(map));
    }
    return RoomDetialModel(data: Data.empty());
  }

  Map<String, dynamic> toJson() => {"data": data.toJson()};
}

class Data {
  final int id;
  final int? categoryId;
  final Category? category;
  final Landlord? landlord;
  final LatestBooking? latestBooking;
  final String name;
  final String status;
  final num price;
  final num? depositPrice;
  final String depositCurrency;
  final double rating;
  final int reviewsCount;
  final String address;
  final String about;
  final String description;
  final String? image;
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
    this.categoryId,
    this.category,
    this.landlord,
    this.latestBooking,
    required this.name,
    required this.status,
    required this.price,
    this.depositPrice,
    this.depositCurrency = 'USD',
    required this.rating,
    required this.reviewsCount,
    required this.address,
    required this.about,
    required this.description,
    this.image,
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
    id: json["id"] is num
        ? (json["id"] as num).toInt()
        : (int.tryParse(json["id"]?.toString() ?? '0') ?? 0),
    categoryId: json["category_id"] is num
        ? (json["category_id"] as num).toInt()
        : int.tryParse(json["category_id"]?.toString() ?? ''),
    category: json["category"] != null && json["category"] is Map
        ? Category.fromJson(Map<String, dynamic>.from(json["category"]))
        : null,
    landlord: json["landlord"] != null && json["landlord"] is Map
        ? Landlord.fromJson(Map<String, dynamic>.from(json["landlord"]))
        : null,
    latestBooking:
        json["latest_booking"] != null && json["latest_booking"] is Map
        ? LatestBooking.fromJson(
            Map<String, dynamic>.from(json["latest_booking"]),
          )
        : null,
    name: (json["name"] ?? 'Room').toString(),
    status: (json["status"] ?? 'AVAILABLE NOW').toString(),
    price: json["price"] is num
        ? (json["price"] as num)
        : (num.tryParse(json["price"]?.toString() ?? '0') ?? 0),
    depositPrice: json["deposit_price"] is num
        ? (json["deposit_price"] as num)
        : num.tryParse(json["deposit_price"]?.toString() ?? ''),
    depositCurrency: (json["deposit_currency"] ?? 'USD')
        .toString()
        .toUpperCase(),
    rating: json["rating"] is num
        ? (json["rating"] as num).toDouble()
        : (double.tryParse(json["rating"]?.toString() ?? '0.0') ?? 0.0),
    reviewsCount: json["reviews_count"] is num
        ? (json["reviews_count"] as num).toInt()
        : (int.tryParse(json["reviews_count"]?.toString() ?? '0') ?? 0),
    address: (json["address"] ?? '').toString(),
    about: (json["about"] ?? json["description"] ?? '').toString(),
    description: (json["description"] ?? '').toString(),
    image: json["image"]?.toString(),
    images: json["images"] is List
        ? List<String>.from(
            (json["images"] as List)
                .where((x) => x != null)
                .map((x) => x.toString()),
          )
        : (json["image"] != null ? [json["image"].toString()] : []),
    imagesCount: json["images_count"] is num
        ? (json["images_count"] as num).toInt()
        : (int.tryParse(json["images_count"]?.toString() ?? '0') ?? 0),
    facilities: json["facilities"] is List
        ? List<String>.from(
            (json["facilities"] as List)
                .where((x) => x != null)
                .map((x) => x.toString()),
          )
        : [],
    roomInformation:
        json["room_information"] != null && json["room_information"] is Map
        ? RoomInformation.fromJson(
            Map<String, dynamic>.from(json["room_information"]),
          )
        : RoomInformation.empty(),
    houseRules: json["house_rules"] is List
        ? List<String>.from(
            (json["house_rules"] as List)
                .where((x) => x != null)
                .map((x) => x.toString()),
          )
        : [],
    location: json["location"] != null && json["location"] is Map
        ? Location.fromJson(Map<String, dynamic>.from(json["location"]))
        : Location(
            address: (json["address"] ?? '').toString(),
            latitude: json["latitude"] is num
                ? (json["latitude"] as num).toDouble()
                : (double.tryParse(json["latitude"]?.toString() ?? '0.0') ??
                      0.0),
            longitude: json["longitude"] is num
                ? (json["longitude"] as num).toDouble()
                : (double.tryParse(json["longitude"]?.toString() ?? '0.0') ??
                      0.0),
          ),
    isFavorite: json["is_favorite"] == true,
    createdAt: (json["created_at"] ?? '').toString(),
    updatedAt: (json["updated_at"] ?? '').toString(),
  );

  factory Data.empty() => Data(
    id: 0,
    categoryId: null,
    category: null,
    landlord: null,
    latestBooking: null,
    name: 'Unknown',
    status: 'Unavailable',
    price: 0,
    rating: 0.0,
    reviewsCount: 0,
    address: '',
    about: '',
    description: '',
    image: null,
    images: [],
    imagesCount: 0,
    facilities: [],
    roomInformation: RoomInformation.empty(),
    houseRules: [],
    location: Location(address: '', latitude: 0.0, longitude: 0.0),
    isFavorite: false,
    createdAt: '',
    updatedAt: '',
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    if (categoryId != null) "category_id": categoryId,
    if (category != null) "category": category!.toJson(),
    if (landlord != null) "landlord": landlord!.toJson(),
    if (latestBooking != null) "latest_booking": latestBooking!.toJson(),
    "name": name,
    "status": status,
    "price": price,
    if (depositPrice != null) "deposit_price": depositPrice,
    "deposit_currency": depositCurrency,
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

class Landlord {
  final int id;
  final String name;
  final String? email;
  final String? phone;
  final String? avatar;
  final bool isVerified;
  final String? locationTag;
  final String? telegram;
  final String? bakongAccountId;
  final String? bakongMerchantName;

  Landlord({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.avatar,
    this.isVerified = false,
    this.locationTag,
    this.telegram,
    this.bakongAccountId,
    this.bakongMerchantName,
  });

  factory Landlord.fromJson(Map<String, dynamic> json) => Landlord(
    id: json["id"] is num
        ? (json["id"] as num).toInt()
        : (int.tryParse(json["id"]?.toString() ?? '0') ?? 0),
    name: (json["name"] ?? 'Landlord').toString(),
    email: json["email"]?.toString(),
    phone: json["phone"]?.toString(),
    avatar: json["avatar"]?.toString(),
    isVerified: json["is_verified"] == true,
    locationTag: json["location_tag"]?.toString(),
    telegram: json["telegram"]?.toString(),
    bakongAccountId: json["bakong_account_id"]?.toString(),
    bakongMerchantName: json["bakong_merchant_name"]?.toString(),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "email": email,
    "phone": phone,
    "avatar": avatar,
    "is_verified": isVerified,
    "location_tag": locationTag,
    "telegram": telegram,
    "bakong_account_id": bakongAccountId,
    "bakong_merchant_name": bakongMerchantName,
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
    this.image,
  });

  factory Category.fromJson(Map<String, dynamic> json) => Category(
    id: json["id"] is num
        ? (json["id"] as num).toInt()
        : (int.tryParse(json["id"]?.toString() ?? '0') ?? 0),
    name: (json["name"] ?? '').toString(),
    slug: (json["slug"] ?? '').toString(),
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
    address: (json["address"] ?? '').toString(),
    latitude: json["latitude"] is num
        ? (json["latitude"] as num).toDouble()
        : (double.tryParse(json["latitude"]?.toString() ?? '0.0') ?? 0.0),
    longitude: json["longitude"] is num
        ? (json["longitude"] as num).toDouble()
        : (double.tryParse(json["longitude"]?.toString() ?? '0.0') ?? 0.0),
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
        type: (json["type"] ?? 'Standard').toString(),
        size: (json["size"] ?? '').toString(),
        floor: (json["floor"] ?? '').toString(),
        deposit: (json["deposit"] ?? '').toString(),
      );

  factory RoomInformation.empty() => RoomInformation(
    type: 'Standard',
    size: 'N/A',
    floor: 'N/A',
    deposit: 'N/A',
  );

  Map<String, dynamic> toJson() => {
    "type": type,
    "size": size,
    "floor": floor,
    "deposit": deposit,
  };
}
