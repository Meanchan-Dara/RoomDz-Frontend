import 'package:dio/dio.dart';
import 'package:roomdz_frontend/model/view_quest_model.dart';
import 'package:roomdz_frontend/service/api_client.dart';

class ViewingRequestService {
  final Dio dio;

  ViewingRequestService({Dio? dio}) : dio = dio ?? ApiClient.instance;

  // check login token before request
  Future<void> _addToken() async {
    final hasToken = await ApiClient.hasToken();
    if (!hasToken) {
      throw Exception('No login token found. Please login again.');
    }
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

  // customer gets all their own viewing requests
  Future<List<ViewingRequestModel>> getMyViewingRequests({
    String? status,
  }) async {
    try {
      await _addToken();

      final response = await dio.get(
        '/my-viewing-requests',
        queryParameters: {
          if (status != null && status.isNotEmpty) 'status': status,
        },
      );

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
      if (e.response?.statusCode == 401) {
        throw Exception('Unauthorized. Please login again.');
      }

      throw Exception(
        e.response?.data?['message'] ?? 'Failed to load your viewing requests',
      );
    }
  }

  // customer cancels their viewing request
  Future<void> cancelViewingRequest(int id) async {
    try {
      await _addToken();
      await dio.put('/my-viewing-requests/$id/cancel');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ?? 'Failed to cancel viewing request',
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
          if (status != null && status.isNotEmpty) 'status': status,
          'room_id': ?roomId,
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
