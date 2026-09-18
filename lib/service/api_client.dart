// lib/services/api_client.dart
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart' as getx;
import 'package:roomdz_frontend/const/port.dart';
import 'package:roomdz_frontend/service/database/database_service.dart';
import 'package:roomdz_frontend/view/user/signInScreen.dart';

class ApiClient {
  static final baseUrl = '$port/api';

  static final _storage = const FlutterSecureStorage();
  static Dio? _dio;

  static Dio get instance {
    if (_dio != null) return _dio!;

    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      QueuedInterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          final statusCode = error.response?.statusCode;
          final path = error.requestOptions.path;

          // Check if this is an unauthorized error
          if (statusCode == 401) {
            final isAuthRoute =
                path.contains('/login') ||
                path.contains('/register') ||
                path.contains('/refresh');

            if (!isAuthRoute) {
              // Attempt to refresh the JWT token
              final newToken = await refreshToken();
              if (newToken != null && newToken.isNotEmpty) {
                // Replay the original failed request with the new token
                final requestOptions = error.requestOptions;
                requestOptions.headers['Authorization'] = 'Bearer $newToken';

                try {
                  final retryResponse = await dio.fetch(requestOptions);
                  return handler.resolve(retryResponse);
                } catch (retryError) {
                  return handler.next(error);
                }
              } else {
                // Token refresh failed or expired -> log user out cleanly
                await logoutAndRedirect();
              }
            }
          }

          return handler.next(error);
        },
      ),
    );

    _dio = dio;
    return dio;
  }

  /// Retrieves the JWT token, checking both keys for backwards compatibility.
  static Future<String?> getToken() async {
    return (await _storage.read(key: 'auth_token')) ??
        (await _storage.read(key: 'token'));
  }

  /// Saves the token in both storage keys to keep all parts of the app synced.
  static Future<void> saveToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
    await _storage.write(key: 'token', value: token);
  }

  /// Removes tokens from secure storage.
  static Future<void> clearToken() async {
    await _storage.delete(key: 'auth_token');
    await _storage.delete(key: 'token');
  }

  /// Checks if a valid token string is present in secure storage.
  static Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.trim().isNotEmpty;
  }

  /// Calls the backend /refresh endpoint to obtain a new JWT token.
  static Future<String?> refreshToken() async {
    final oldToken = await getToken();
    if (oldToken == null || oldToken.isEmpty) return null;

    try {
      // Use an independent Dio client without interceptor to prevent infinite recursion
      final refreshDio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $oldToken',
          },
        ),
      );

      final response = await refreshDio.post('/refresh');
      if (response.statusCode == 200 && response.data is Map) {
        final data = response.data as Map;
        final newToken =
            data['token']?.toString() ?? data['access_token']?.toString();
        if (newToken != null && newToken.isNotEmpty) {
          await saveToken(newToken);
          return newToken;
        }
      }
    } catch (_) {
      // Refresh failed (token blacklisted, expired beyond refresh window, etc.)
    }
    return null;
  }

  /// Clears secure tokens, SQLite session, and navigates to the login screen.
  static Future<void> logoutAndRedirect() async {
    await clearToken();
    try {
      await DatabaseService.instance.clearUser();
    } catch (_) {}

    if (getx.Get.context != null) {
      getx.Get.offAll(() => const Signinscreen());
    }
  }
}
