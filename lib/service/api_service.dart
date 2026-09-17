import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:roomdz_frontend/const/port.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();

  factory ApiService() {
    return _instance;
  }

  ApiService._internal();

  final FlutterSecureStorage storage = const FlutterSecureStorage();

  String get baseUrl => '$port/api';

  late final Dio dio = Dio(
    BaseOptions(
      baseUrl: '$port/api',
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ),
  );

  Future<void> initialize() async {
    final token = await storage.read(key: 'token') ?? await storage.read(key: 'auth_token');

    if (token != null) {
      dio.options.headers['Authorization'] = 'Bearer $token';
    }
  }

  Future<void> saveToken(String token) async {
    await storage.write(key: 'token', value: token);
    await storage.write(key: 'auth_token', value: token);

    dio.options.headers['Authorization'] = 'Bearer $token';
  }

  Future<void> removeToken() async {
    await storage.delete(key: 'token');
    await storage.delete(key: 'auth_token');

    dio.options.headers.remove('Authorization');
  }

  Future<void> clearToken() async {
    await removeToken();
  }

  Future<Response> get(
    String endpoint, {
    bool requiresAuth = false,
  }) async {
    if (requiresAuth) {
      await initialize();
    }
    return await dio.get(endpoint);
  }

  Future<Response> post(
    String endpoint, {
    dynamic body,
    bool requiresAuth = false,
  }) async {
    if (requiresAuth) {
      await initialize();
    }
    return await dio.post(endpoint, data: body);
  }

  Future<Response> put(
    String endpoint, {
    dynamic body,
    bool requiresAuth = false,
  }) async {
    if (requiresAuth) {
      await initialize();
    }
    return await dio.put(endpoint, data: body);
  }

  Future<Response> delete(
    String endpoint, {
    bool requiresAuth = false,
  }) async {
    if (requiresAuth) {
      await initialize();
    }
    return await dio.delete(endpoint);
  }
}
