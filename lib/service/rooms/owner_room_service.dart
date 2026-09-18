import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:roomdz_frontend/model/roomModel.dart';
import 'package:roomdz_frontend/service/api_client.dart';

class OwnerRoomService {
  final Dio _dio;

  OwnerRoomService({Dio? dio}) : _dio = dio ?? ApiClient.instance;

  Future<void> _addToken() async {
    final hasToken = await ApiClient.hasToken();
    if (!hasToken) {
      throw Exception('No login token found. Please login again.');
    }
  }

  Future<List<Datum>> getOwnerRooms({String? search, String? status}) async {
    try {
      await _addToken();
      final response = await _dio.get(
        '/owner/rooms',
        queryParameters: {
          if (search != null && search.trim().isNotEmpty)
            'search': search.trim(),
          if (status != null && status.trim().isNotEmpty)
            'status': status.trim(),
        },
      );

      final data = response.data;
      if (data is Map && data['data'] is List) {
        return (data['data'] as List)
            .map((item) => Datum.fromJson(Map<String, dynamic>.from(item)))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ?? 'Failed to load owner rooms',
      );
    }
  }

  Future<void> rentOutRoom(int id) async {
    await _addToken();
    await _dio.post('/owner/rooms/$id/rent-out');
  }

  Future<void> releaseUnit(int id) async {
    await _addToken();
    await _dio.post('/owner/rooms/$id/release-unit');
  }

  Future<void> deleteRoom(int id) async {
    await _addToken();
    await _dio.delete('/owner/rooms/$id');
  }

  Future<List<Map<String, dynamic>>> getCategories() async {
    try {
      final response = await _dio.get('/category');
      final data = response.data;
      if (data is Map && data['data'] is List) {
        return (data['data'] as List)
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  Future<Map<String, dynamic>?> getDashboardStats() async {
    try {
      await _addToken();
      final response = await _dio.get('/owner/dashboard');
      final data = response.data;
      if (data is Map && data['data'] is Map) {
        return Map<String, dynamic>.from(data['data']);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, dynamic>> createRoom({
    required String name,
    required double price,
    required String address,
    int? categoryId,
    String? type,
    String? pricePeriod,
    String? status,
    int? totalUnits,
    int? availableUnits,
    bool? isNegotiable,
    String? description,
    String? size,
    String? floor,
    String? deposit,
    List<String>? facilities,
    List<String>? houseRules,
    String? paymentCycle,
    double? latitude,
    double? longitude,
    String? mainImagePath,
    List<String>? galleryImagePaths,
  }) async {
    try {
      await _addToken();

      final formData = FormData();

      // Required and basic fields
      formData.fields.add(MapEntry('name', name.trim()));
      formData.fields.add(MapEntry('price', price.toString()));
      formData.fields.add(MapEntry('address', address.trim()));

      if (categoryId != null && categoryId > 0) {
        formData.fields.add(MapEntry('category_id', categoryId.toString()));
      }
      if (type != null && type.trim().isNotEmpty) {
        formData.fields.add(MapEntry('type', type.trim()));
      }
      if (pricePeriod != null && pricePeriod.trim().isNotEmpty) {
        formData.fields.add(MapEntry('price_period', pricePeriod.trim()));
      }
      if (status != null && status.trim().isNotEmpty) {
        formData.fields.add(MapEntry('status', status.trim()));
      }
      if (totalUnits != null) {
        formData.fields.add(MapEntry('total_units', totalUnits.toString()));
      }
      if (availableUnits != null) {
        formData.fields.add(
          MapEntry('available_units', availableUnits.toString()),
        );
      }
      if (isNegotiable != null) {
        formData.fields.add(
          MapEntry('is_negotiable', isNegotiable ? '1' : '0'),
        );
      }

      // Details
      if (description != null && description.trim().isNotEmpty) {
        formData.fields.add(MapEntry('description', description.trim()));
      }
      if (size != null && size.trim().isNotEmpty) {
        formData.fields.add(MapEntry('size', size.trim()));
      }
      if (floor != null && floor.trim().isNotEmpty) {
        formData.fields.add(MapEntry('floor', floor.trim()));
      }
      if (deposit != null && deposit.trim().isNotEmpty) {
        formData.fields.add(MapEntry('deposit', deposit.trim()));
      }
      if (paymentCycle != null && paymentCycle.trim().isNotEmpty) {
        formData.fields.add(MapEntry('payment_cycle', paymentCycle.trim()));
      }
      if (latitude != null) {
        formData.fields.add(MapEntry('latitude', latitude.toString()));
      }
      if (longitude != null) {
        formData.fields.add(MapEntry('longitude', longitude.toString()));
      }

      // JSON encoded arrays for facilities and house rules
      if (facilities != null && facilities.isNotEmpty) {
        formData.fields.add(MapEntry('facilities', jsonEncode(facilities)));
      }
      if (houseRules != null && houseRules.isNotEmpty) {
        formData.fields.add(MapEntry('house_rules', jsonEncode(houseRules)));
      }

      // Main image file
      if (mainImagePath != null && mainImagePath.isNotEmpty) {
        final filename = mainImagePath.split(r'/').last.split(r'\').last;
        formData.files.add(
          MapEntry(
            'image',
            await MultipartFile.fromFile(mainImagePath, filename: filename),
          ),
        );
      }

      // Gallery image files
      if (galleryImagePaths != null && galleryImagePaths.isNotEmpty) {
        for (final gPath in galleryImagePaths) {
          final gFilename = gPath.split(r'/').last.split(r'\').last;
          formData.files.add(
            MapEntry(
              'images[]',
              await MultipartFile.fromFile(gPath, filename: gFilename),
            ),
          );
        }
      }

      final response = await _dio.post('/owner/rooms', data: formData);

      if (response.data is Map) {
        return Map<String, dynamic>.from(response.data);
      }
      return {};
    } on DioException catch (e) {
      String errorMessage = 'បរាជ័យក្នុងការបង្ហោះបន្ទប់';
      if (e.response?.data is Map) {
        final data = e.response!.data as Map;
        if (data.containsKey('errors') && data['errors'] is Map) {
          final errors = data['errors'] as Map;
          final firstError = errors.values.first;
          if (firstError is List && firstError.isNotEmpty) {
            errorMessage = firstError.first.toString();
          } else {
            errorMessage = firstError.toString();
          }
        } else if (data.containsKey('message')) {
          errorMessage = data['message'].toString();
        }
      } else if (e.message != null) {
        errorMessage = e.message!;
      }
      throw Exception(errorMessage);
    }
  }
}
