import 'package:dio/dio.dart';
import 'api_service.dart';

class AuthService {
  final ApiService apiService = ApiService();

  // ================= REGISTER =================

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await apiService.dio.post(
        '/register',
        data: {'name': name, 'email': email, 'password': password},
      );

      final token = response.data['token'];

      await apiService.saveToken(token);

      return response.data;
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Register failed';
    }
  }

  // ================= LOGIN =================

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await apiService.dio.post(
        '/login',
        data: {'email': email, 'password': password},
      );

      final token = response.data['token'];

      await apiService.saveToken(token);

      return response.data;
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Login failed';
    }
  }

  // ================= LOGOUT =================

  Future<void> logout() async {
    try {
      await apiService.dio.post('/logout');
    } finally {
      await apiService.removeToken();
    }
  }

  // ================= PROFILE =================

  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await apiService.dio.get('/profile');

      return response.data;
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Failed to get profile';
    }
  }
}
