import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:roomdz_frontend/const/port.dart';
import 'package:roomdz_frontend/service/api_client.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();

  factory ApiService() {
    return _instance;
  }

  ApiService._internal();

  final FlutterSecureStorage storage = const FlutterSecureStorage();

  String get baseUrl => '$port/api';

  Dio get dio => ApiClient.instance;

  Future<void> initialize() async {
    // ApiClient.instance handles authorization dynamically via QueuedInterceptorsWrapper
  }

  Future<void> saveToken(String token) async {
    await ApiClient.saveToken(token);
  }

  Future<void> removeToken() async {
    await ApiClient.clearToken();
  }

  Future<void> clearToken() async {
    await ApiClient.clearToken();
  }

  Future<Response> get(String endpoint, {bool requiresAuth = false}) async {
    return await dio.get(endpoint);
  }

  Future<Response> post(
    String endpoint, {
    dynamic body,
    bool requiresAuth = false,
  }) async {
    return await dio.post(endpoint, data: body);
  }

  Future<Response> put(
    String endpoint, {
    dynamic body,
    bool requiresAuth = false,
  }) async {
    return await dio.put(endpoint, data: body);
  }

  Future<Response> delete(String endpoint, {bool requiresAuth = false}) async {
    return await dio.delete(endpoint);
  }
}
