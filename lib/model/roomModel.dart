// To parse this JSON data, do
//
//     final roomModel = roomModelFromJson(jsonString);

import 'dart:convert';

RoomModel roomModelFromJson(String str) => RoomModel.fromJson(json.decode(str));

String roomModelToJson(RoomModel data) => json.encode(data.toJson());

class RoomModel {
  final List<Datum> data;
  final Links? links;
  final Meta? meta;

  RoomModel({required this.data, this.links, this.meta});

  factory RoomModel.fromJson(dynamic json) {
    if (json is List) {
      return RoomModel(
        data: List<Datum>.from(
          json.map((x) => Datum.fromJson(Map<String, dynamic>.from(x))),
        ),
      );
    }
    if (json is Map<String, dynamic> || json is Map) {
      final rawData = json["data"];
      List<Datum> items = [];
      if (rawData is List) {
        items = List<Datum>.from(
          rawData.map((x) => Datum.fromJson(Map<String, dynamic>.from(x))),
        );
      }
      return RoomModel(
        data: items,
        links: json["links"] != null
            ? Links.fromJson(Map<String, dynamic>.from(json["links"]))
            : null,
        meta: json["meta"] != null
            ? Meta.fromJson(Map<String, dynamic>.from(json["meta"]))
            : null,
      );
    }
    return RoomModel(data: []);
  }

  Map<String, dynamic> toJson() => {
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
    if (links != null) "links": links!.toJson(),
    if (meta != null) "meta": meta!.toJson(),
  };
}

class Datum {
  final int id;
  final int categoryId;
  final Category category;
  final String name;
  final String type;
  final int price;
  final String status;
  final double rating;
  final int reviewsCount;
  final String address;
  final String? image;
  final double latitude;
  final double longitude;
  final String createdAt;
  final String updatedAt;

  Datum({
    required this.id,
    required this.categoryId,
    required this.category,
    required this.name,
    required this.type,
    required this.price,
    required this.status,
    required this.rating,
    required this.reviewsCount,
    required this.address,
    this.image,
    required this.latitude,
    required this.longitude,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    id: json["id"] is int
        ? json["id"]
        : (int.tryParse(json["id"]?.toString() ?? '0') ?? 0),
    categoryId: json["category_id"] is int
        ? json["category_id"]
        : (int.tryParse(json["category_id"]?.toString() ?? '0') ?? 0),
    category: json["category"] != null && json["category"] is Map
        ? Category.fromJson(Map<String, dynamic>.from(json["category"]))
        : Category(id: 0, name: 'General', slug: 'general', image: null),
    name: (json["name"] ?? 'Room').toString(),
    type: (json["type"] ?? 'Standard').toString(),
    price: (json["price"] is num)
        ? (json["price"] as num).toInt()
        : (int.tryParse(json["price"]?.toString() ?? '0') ?? 0),
    status: (json["status"] ?? 'Available').toString(),
    rating: (json["rating"] is num)
        ? (json["rating"] as num).toDouble()
        : (double.tryParse(json["rating"]?.toString() ?? '0') ?? 0.0),
    reviewsCount: (json["reviews_count"] is num)
        ? (json["reviews_count"] as num).toInt()
        : (int.tryParse(json["reviews_count"]?.toString() ?? '0') ?? 0),
    address: (json["address"] ?? '').toString(),
    image: json["image"]?.toString(),
    latitude: double.tryParse(json["latitude"]?.toString() ?? '0') ?? 0.0,
    longitude: double.tryParse(json["longitude"]?.toString() ?? '0') ?? 0.0,
    createdAt: json["created_at"]?.toString() ?? '',
    updatedAt: json["updated_at"]?.toString() ?? '',
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "category_id": categoryId,
    "category": category.toJson(),
    "name": name,
    "type": type,
    "price": price,
    "status": status,
    "rating": rating,
    "reviews_count": reviewsCount,
    "address": address,
    "image": image,
    "latitude": latitude,
    "longitude": longitude,
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
    id: json["id"] is int
        ? json["id"]
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

class Links {
  final String? first;
  final String? last;
  final dynamic prev;
  final dynamic next;

  Links({this.first, this.last, this.prev, this.next});

  factory Links.fromJson(Map<String, dynamic> json) => Links(
    first: json["first"]?.toString(),
    last: json["last"]?.toString(),
    prev: json["prev"],
    next: json["next"],
  );

  Map<String, dynamic> toJson() => {
    "first": first,
    "last": last,
    "prev": prev,
    "next": next,
  };
}

class Meta {
  final int? currentPage;
  final int? from;
  final int? lastPage;
  final List<Link> links;
  final String? path;
  final int? perPage;
  final int? to;
  final int? total;

  Meta({
    this.currentPage,
    this.from,
    this.lastPage,
    this.links = const [],
    this.path,
    this.perPage,
    this.to,
    this.total,
  });

  factory Meta.fromJson(Map<String, dynamic> json) => Meta(
    currentPage: (json["current_page"] as num?)?.toInt(),
    from: (json["from"] as num?)?.toInt(),
    lastPage: (json["last_page"] as num?)?.toInt(),
    links: json["links"] is List
        ? List<Link>.from(
            json["links"].map(
              (x) => Link.fromJson(Map<String, dynamic>.from(x)),
            ),
          )
        : const [],
    path: json["path"]?.toString(),
    perPage: (json["per_page"] as num?)?.toInt(),
    to: (json["to"] as num?)?.toInt(),
    total: (json["total"] as num?)?.toInt(),
  );

  Map<String, dynamic> toJson() => {
    "current_page": currentPage,
    "from": from,
    "last_page": lastPage,
    "links": List<dynamic>.from(links.map((x) => x.toJson())),
    "path": path,
    "per_page": perPage,
    "to": to,
    "total": total,
  };
}

class Link {
  final String? url;
  final String label;
  final bool active;

  Link({this.url, required this.label, required this.active});

  factory Link.fromJson(Map<String, dynamic> json) => Link(
    url: json["url"]?.toString(),
    label: (json["label"] ?? '').toString(),
    active: json["active"] == true,
  );

  Map<String, dynamic> toJson() => {
    "url": url,
    "label": label,
    "active": active,
  };
}
