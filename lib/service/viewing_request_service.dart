import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:roomdz_frontend/const/port.dart';
import 'package:roomdz_frontend/model/view_quest_model.dart';

class ViewingRequestService {
  final Dio dio;

  final FlutterSecureStorage storage = const FlutterSecureStorage();

  ViewingRequestService()
    : dio = Dio(
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

  // add login token to request
  Future<void> _addToken() async {
    final token =
        await storage.read(key: 'token') ??
        await storage.read(key: 'auth_token');

    if (token == null || token.isEmpty) {
      throw Exception('No login token found. Please login again.');
    }

    dio.options.headers['Authorization'] = 'Bearer $token';
  }

  // customer sends viewing request
  Future<void> requestViewing({
    required int roomId,
    required String name,
    required String phone,
    String? email,
    String? preferredDate,
    String? preferredTime,
    String? notes,
  }) async {
    try {
      await _addToken();

      final response = await dio.post(
        '/room/$roomId/request-viewing',
        data: {
          'name': name,
          'phone': phone,
          if (email != null && email.isNotEmpty) 'email': email,
          if (preferredDate != null && preferredDate.isNotEmpty)
            'preferred_date': preferredDate,
          if (preferredTime != null && preferredTime.isNotEmpty)
            'preferred_time': preferredTime,
          if (notes != null && notes.isNotEmpty) 'notes': notes,
        },
      );

      print('request viewing response: ${response.data}');
    } on DioException catch (e) {
      print('request viewing error: ${e.response?.data}');

      throw Exception(
        e.response?.data?['message'] ?? 'Failed to send viewing request',
      );
    }
  }

  // owner gets all viewing requests
  Future<List<ViewingRequestModel>> getViewingRequests({
    String? status,
    int? roomId,
  }) async {
    try {
      await _addToken();

      final response = await dio.get(
        '/owner/viewing-requests',
        queryParameters: {
          if (status != null) 'status': status,
          if (roomId != null) 'room_id': roomId,
        },
      );

      print('owner requests response: ${response.data}');

      final responseData = response.data;

      if (responseData is! Map<String, dynamic>) {
        return [];
      }

      final data = responseData['data'];

      if (data is! List) {
        return [];
      }

      return data
          .map(
            (item) =>
                ViewingRequestModel.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList();
    } on DioException catch (e) {
      print('get owner requests error: ${e.response?.data}');

      if (e.response?.statusCode == 401) {
        throw Exception('Unauthorized. Please login again.');
      }

      if (e.response?.statusCode == 403) {
        throw Exception('You do not have permission to access owner requests.');
      }

      throw Exception(
        e.response?.data?['message'] ?? 'Failed to load viewing requests',
      );
    }
  }

  // owner confirms request
  Future<void> confirmViewingRequest(int id) async {
    try {
      await _addToken();

      final response = await dio.put('/owner/viewing-requests/$id/confirm');

      print('confirm response: ${response.data}');
    } on DioException catch (e) {
      print('confirm error: ${e.response?.data}');

      throw Exception(
        e.response?.data?['message'] ?? 'Failed to confirm viewing request',
      );
    }
  }

  // owner rejects request
  Future<void> rejectViewingRequest(int id) async {
    try {
      await _addToken();

      final response = await dio.put('/owner/viewing-requests/$id/reject');

      print('reject response: ${response.data}');
    } on DioException catch (e) {
      print('reject error: ${e.response?.data}');

      throw Exception(
        e.response?.data?['message'] ?? 'Failed to reject viewing request',
      );
    }
  }
}
