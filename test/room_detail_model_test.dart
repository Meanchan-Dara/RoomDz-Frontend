import 'package:flutter_test/flutter_test.dart';
import 'package:roomdz_frontend/features/rooms/data/models/room_detail_model.dart';

void main() {
  test(
    'RoomDetialModel.fromJson parses successfully when nullable fields are null',
    () {
      final jsonWithNulls = {
        "data": {
          "id": 7,
          "category_id": 11,
          "user_id": 20,
          "category": {
            "id": 11,
            "name": "Standard Room",
            "slug": "standard-room",
            "image": null,
          },
          "landlord": {
            "id": 20,
            "name": "Multi-Unit Landlord",
            "email": "multi@example.com",
            "phone": "+85511223344",
            "avatar": null,
            "is_verified": false,
            "location_tag": null,
            "telegram": "@multi_landlord",
          },
          "name": "Budget Studio 10-Pack",
          "type": "Studio",
          "status": "AVAILABLE NOW",
          "total_units": 10,
          "available_units": 0,
          "is_available": false,
          "price": 100,
          "price_period": "month",
          "is_negotiable": false,
          "is_featured": false,
          "listing_type": "standard",
          "rating": 5,
          "reviews_count": 0,
          "address": "Tuol Tompoung, Phnom Penh",
          "about": "10 identical fully furnished studio units",
          "description": "10 identical fully furnished studio units",
          "image": null,
          "images": [],
          "images_count": 0,
          "facilities": [],
          "room_information": {
            "type": "Studio",
            "size": "24 sqm",
            "floor": "3rd Floor",
            "deposit": "1 Month",
          },
          "house_rules": [],
          "location": {
            "address": "Tuol Tompoung, Phnom Penh",
            "latitude": null,
            "longitude": null,
          },
          "latitude": null,
          "longitude": null,
          "is_favorite": false,
          "created_at": "2026-09-13T15:55:27.000000Z",
          "updated_at": "2026-09-13T15:55:27.000000Z",
        },
      };

      final result = RoomDetialModel.fromJson(jsonWithNulls);
      expect(result.data.id, 7);
      expect(result.data.image, isNull);
      expect(result.data.location.latitude, 0.0);
      expect(result.data.location.longitude, 0.0);
      expect(result.data.landlord?.name, "Multi-Unit Landlord");
    },
  );

  test(
    'RoomDetialModel.fromJson parses successfully when category is null',
    () {
      final jsonNullCategory = {
        "data": {
          "id": 2,
          "category_id": null,
          "user_id": 1,
          "category": null,
          "name": "Cozy Studio Apartment",
          "price": 220,
          "rating": 4.9,
          "reviews_count": 38,
          "address": "BKK1, Phnom Penh",
          "image": "https://example.com/img.jpg",
          "images": ["https://example.com/img.jpg"],
          "images_count": 1,
          "facilities": ["Wi-Fi"],
          "room_information": null,
          "house_rules": [],
          "location": null,
        },
      };

      final result = RoomDetialModel.fromJson(jsonNullCategory);
      expect(result.data.id, 2);
      expect(result.data.category, isNull);
      expect(result.data.roomInformation.type, 'Standard');
    },
  );
}
