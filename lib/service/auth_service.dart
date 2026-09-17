import 'dart:convert';

import 'package:roomdz_frontend/model/usreModel.dart';
import 'package:roomdz_frontend/service/api_service.dart';

class AuthService {
  final ApiService apiService = ApiService();

  // login
  Future<UserModel?> login(String email, String password) async {
    final response = await apiService.post(
      '/login',
      body: {'email': email, 'password': password},
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      // Save Sanctum token
      await apiService.storage.write(key: 'token', value: data['token']);
      // Return user
      return UserModel.fromJson(data['user']);
    }

    return null;
  }

  // register - returns user or null (simple version)
  Future<UserModel?> resgister(
    String name,
    String email,
    String phone,
    String password,
    String confirmPassword,
  ) async {
    final response = await apiService.post(
      '/register',
      body: {
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
        'password_confirmation': confirmPassword,
      },
    );
    final data = jsonDecode(response.body);
    if (response.statusCode == 201) {
      // Save token returned from backend
      await apiService.storage.write(key: 'token', value: data['token']);
      return UserModel.fromJson(data['user']);
    }
    return null;
  }

  // register with full error reporting - returns {'user': UserModel?, 'error': String?}
  Future<Map<String, dynamic>> registerWithResult(
    String name,
    String email,
    String phone,
    String password,
    String confirmPassword,
  ) async {
    try {
      final response = await apiService.post(
        '/register',
        body: {
          'name': name,
          'email': email,
          'phone': phone,
          'password': password,
          'password_confirmation': confirmPassword,
        },
      );
      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        // Save token returned from backend
        await apiService.storage.write(key: 'token', value: data['token']);
        return {'user': UserModel.fromJson(data['user']), 'error': null};
      }

      // Extract real validation error from backend (422, 409, etc.)
      String errorMsg = data['message'] ?? 'Register failed';
      if (data['errors'] != null) {
        final errors = data['errors'] as Map<String, dynamic>;
        errorMsg = errors.values
            .expand((e) => e is List ? e.cast<String>() : [e.toString()])
            .join('\n');
      }
      return {'user': null, 'error': errorMsg};
    } catch (e) {
      return {'user': null, 'error': 'Network error: $e'};
    }
  }

  // get profile
  Future<UserModel?> getProfile() async {
    final response = await apiService.get('/profile', requiresAuth: true);
    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return UserModel.fromJson(data['user'] ?? data);
    }
    return null;
  }

  // logout
  Future<bool> logout() async {
    final response = await apiService.post('/logout', requiresAuth: true);
    if (response.statusCode == 200) {
      await apiService.clearToken();
      return true;
    }
    return false;
  }
}
