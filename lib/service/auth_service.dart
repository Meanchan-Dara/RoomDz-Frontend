import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:roomdz_frontend/model/user_model.dart';
import 'package:roomdz_frontend/service/api_service.dart';
import 'api_client.dart';

class AuthService {
  final Dio _dio = ApiClient.instance;

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final res = await _dio.post(
        '/login',
        data: {'email': email.trim(), 'password': password},
      );

      debugPrint('LOGIN STATUS: ${res.statusCode}');
      debugPrint('LOGIN RESPONSE: ${res.data}');

      final token = res.data['token']?.toString() ?? '';
      await ApiClient.saveToken(token);
      await ApiService().saveToken(token);

      return UserModel.fromJson(res.data['user']);
    } on DioException catch (e) {
      debugPrint('LOGIN ERROR STATUS: ${e.response?.statusCode}');
      debugPrint('LOGIN ERROR DATA: ${e.response?.data}');
      debugPrint('LOGIN ERROR MESSAGE: ${e.message}');
      rethrow;
    }
  }

  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    String role = 'customer',
    String? phone,
  }) async {
    final res = await _dio.post(
      '/register',
      data: {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': password,
        'role': role,
        if (phone != null) 'phone': phone,
      },
    );

    final token = res.data['token']?.toString() ?? '';
    await ApiClient.saveToken(token);
    await ApiService().saveToken(token);

    return UserModel.fromJson(res.data['user']);
  }

  Future<UserModel?> getProfile() async {
    try {
      final res = await _dio.get('/profile');
      if (res.statusCode == 200) {
        final data = res.data;
        return UserModel.fromJson(data['user'] ?? data);
      }
    } catch (_) {}
    return null;
  }

  Future<void> logout() async {
    try {
      await _dio.post('/logout');
    } finally {
      await ApiClient.clearToken();
      await ApiService().removeToken();
    }
  }
}
