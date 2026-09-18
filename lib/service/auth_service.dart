import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:roomdz_frontend/model/user_model.dart';
import 'package:roomdz_frontend/service/database/database_service.dart';
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

      final token =
          res.data['token']?.toString() ??
          res.data['access_token']?.toString() ??
          '';
      if (token.isNotEmpty) {
        await ApiClient.saveToken(token);
      }

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
        'name': name.trim(),
        'email': email.trim(),
        'password': password,
        'password_confirmation': password,
        'role': role,
        if (phone != null && phone.trim().isNotEmpty) 'phone': phone.trim(),
      },
    );

    final token =
        res.data['token']?.toString() ??
        res.data['access_token']?.toString() ??
        '';
    if (token.isNotEmpty) {
      await ApiClient.saveToken(token);
    }

    return UserModel.fromJson(res.data['user']);
  }

  Future<UserModel?> getProfile() async {
    try {
      final res = await _dio.get('/profile');
      if (res.statusCode == 200) {
        final data = res.data;
        final user = UserModel.fromJson(data['user'] ?? data);
        await DatabaseService.instance.saveUser(user);
        return user;
      }
    } catch (_) {}
    return null;
  }

  Future<Map<String, dynamic>?> getProfileWithStats() async {
    try {
      final res = await _dio.get('/profile');
      if (res.statusCode == 200) {
        final data = res.data;
        if (data is Map<String, dynamic>) {
          if (data['user'] != null) {
            final user = UserModel.fromJson(data['user']);
            await DatabaseService.instance.saveUser(user);
          }
          return data;
        }
      }
    } catch (_) {}
    return null;
  }

  Future<UserModel> updateProfile({
    String? name,
    String? phone,
    String? email,
    String? telegram,
    String? locationTag,
    String? bakongAccountId,
    String? bakongMerchantName,
    String? avatarPath,
  }) async {
    try {
      dynamic postData;

      if (avatarPath != null && avatarPath.isNotEmpty) {
        final filename = avatarPath.split('/').last.split(r'\').last;
        final map = <String, dynamic>{
          if (name != null && name.trim().isNotEmpty) 'name': name.trim(),
          if (phone != null) 'phone': phone.trim(),
          if (email != null && email.trim().isNotEmpty) 'email': email.trim(),
          if (telegram != null) 'telegram': telegram.trim(),
          if (locationTag != null) 'location_tag': locationTag.trim(),
          if (bakongAccountId != null)
            'bakong_account_id': bakongAccountId.trim(),
          if (bakongMerchantName != null)
            'bakong_merchant_name': bakongMerchantName.trim(),
          'avatar': await MultipartFile.fromFile(
            avatarPath,
            filename: filename,
          ),
        };
        postData = FormData.fromMap(map);
      } else {
        postData = {
          if (name != null && name.trim().isNotEmpty) 'name': name.trim(),
          if (phone != null) 'phone': phone.trim(),
          if (email != null && email.trim().isNotEmpty) 'email': email.trim(),
          if (telegram != null) 'telegram': telegram.trim(),
          if (locationTag != null) 'location_tag': locationTag.trim(),
          if (bakongAccountId != null)
            'bakong_account_id': bakongAccountId.trim(),
          if (bakongMerchantName != null)
            'bakong_merchant_name': bakongMerchantName.trim(),
        };
      }

      final res = await _dio.post('/profile', data: postData);
      final data = res.data;
      final user = UserModel.fromJson(data['user'] ?? data);
      await DatabaseService.instance.saveUser(user);
      return user;
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? e.message ?? 'Update failed';
      throw Exception(msg);
    }
  }

  /// Refresh the current JWT token using the refresh route.
  Future<String?> refreshToken() async {
    return await ApiClient.refreshToken();
  }

  Future<void> logout() async {
    try {
      await _dio.post('/logout');
    } catch (e) {
      debugPrint('Logout request error: $e');
    } finally {
      await ApiClient.clearToken();
      await DatabaseService.instance.clearUser();
    }
  }
}
