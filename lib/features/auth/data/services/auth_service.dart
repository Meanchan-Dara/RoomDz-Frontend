import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:roomdz_frontend/features/auth/data/models/user_model.dart';
import 'package:roomdz_frontend/core/database/database_service.dart';
import 'package:roomdz_frontend/core/network/api_client.dart';

class AuthService {
  final Dio _dio = ApiClient.instance;

  static const String googleServerClientId =
      '719036419945-n12ho8rim4e6g8k2570vbdq6lj8vllvg.apps.googleusercontent.com';

  /// Sign in with Google (Backend API verification without Firebase SDK)
  Future<UserModel?> loginWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        serverClientId: googleServerClientId,
        scopes: ['email', 'profile'],
      );

      // Force account picker by signing out first if needed
      if (await googleSignIn.isSignedIn()) {
        await googleSignIn.signOut();
      }

      final GoogleSignInAccount? account = await googleSignIn.signIn();
      if (account == null) {
        return null; // User canceled sign-in
      }

      final GoogleSignInAuthentication auth = await account.authentication;
      final String? accessToken = auth.accessToken;
      final String? idToken = auth.idToken;

      debugPrint(
        'GOOGLE AUTH: accessToken=${accessToken != null ? "yes" : "no"}, idToken=${idToken != null ? "yes" : "no"}',
      );

      if ((accessToken == null || accessToken.isEmpty) &&
          (idToken == null || idToken.isEmpty)) {
        throw Exception('មិនអាចទទួល token ពី Google បានទេ');
      }

      final res = await _dio.post(
        '/auth/google/callback',
        data: {
          if (accessToken != null && accessToken.isNotEmpty)
            'access_token': accessToken,
          if (idToken != null && idToken.isNotEmpty) 'id_token': idToken,
        },
      );

      debugPrint('GOOGLE LOGIN STATUS: ${res.statusCode}');
      debugPrint('GOOGLE LOGIN RESPONSE: ${res.data}');

      final token =
          res.data['token']?.toString() ??
          res.data['access_token']?.toString() ??
          '';
      if (token.isNotEmpty) {
        await ApiClient.saveToken(token);
      }

      final user = UserModel.fromJson(res.data['user']);
      await DatabaseService.instance.saveUser(user);
      return user;
    } on DioException catch (e) {
      debugPrint(
        'GOOGLE LOGIN DIO ERROR: ${e.response?.statusCode} - ${e.response?.data}',
      );
      rethrow;
    }
  }

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
      try {
        final GoogleSignIn googleSignIn = GoogleSignIn();
        if (await googleSignIn.isSignedIn()) {
          await googleSignIn.signOut();
        }
      } catch (_) {}
      await ApiClient.clearToken();
      await DatabaseService.instance.clearUser();
    }
  }
}
