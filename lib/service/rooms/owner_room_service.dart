import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:roomdz_frontend/const/port.dart';
import 'package:roomdz_frontend/model/roomModel.dart';

class OwnerRoomService {
  final Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  OwnerRoomService({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: '$port/api',
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
              headers: {
                'Accept': 'application/json',
                'Content-Type': 'application/json',
              },
            ),
          );

  Future<void> _addToken() async {
    final token =
        await _storage.read(key: 'token') ??
        await _storage.read(key: 'auth_token');
    if (token == null || token.isEmpty) {
      throw Exception('No login token found. Please login again.');
    }
    _dio.options.headers['Authorization'] = 'Bearer $token';
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
}
