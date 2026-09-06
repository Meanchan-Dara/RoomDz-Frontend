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

  // resgister
  Future<UserModel?> resgister(
    String name,
    String email,
    String password,
    String comfirmPassword,
  ) async {
    final response = await apiService.post(
      '/register',
      body: {
        'name': name,
        'email': email,
        'password': password,
        'comfirmPassword': comfirmPassword,
      },
    );
    final data = jsonDecode(response.body);
    if (response.statusCode == 201) {
      //save toke return from backend
      await apiService.storage.write(key: 'token', value: data['token']);
      return UserModel.fromJson(data['user']);
    }
    return null;
  }

  //get profile
  Future<UserModel?> getProfile() async {
    final response = await apiService.get('/profile', requiresAuth: true);

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return UserModel.fromJson(data['user'] ?? data);
    }

    return null;
  }

  //logout
  Future<bool> logout() async {
    final response = await apiService.post('/logout', requiresAuth: true);

    if (response.statusCode == 200) {
      await apiService.clearToken();
      return true;
    }

    return false;
  }
}
