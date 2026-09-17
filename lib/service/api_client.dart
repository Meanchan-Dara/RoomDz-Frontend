// lib/services/api_client.dart
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:roomdz_frontend/const/port.dart';

class ApiClient {
  static final baseUrl = '$port/api';
  // iOS simulator   -> http://127.0.0.1:8000/api
  // Real device     -> http://<your-lan-ip>:8000/api

  static final _storage = const FlutterSecureStorage();
  static Dio? _dio;

  static Dio get instance {
    if (_dio != null) return _dio!;

    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'Accept': 'application/json'},
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read(key: 'auth_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            // token invalid/expired -> clear it
            await _storage.delete(key: 'auth_token');
            // TODO: navigate to login screen (e.g. via a global navigatorKey
            // or a stream/event bus the app listens to)
          }
          return handler.next(error);
        },
      ),
    );

    _dio = dio;
    return dio;
  }

  static Future<void> saveToken(String token) =>
      _storage.write(key: 'auth_token', value: token);

  static Future<void> clearToken() => _storage.delete(key: 'auth_token');

  static Future<bool> hasToken() async =>
      (await _storage.read(key: 'auth_token')) != null;
}
