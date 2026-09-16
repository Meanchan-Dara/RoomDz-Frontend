import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:roomdz_frontend/const/port.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();

  factory ApiService() {
    return _instance;
  }

  ApiService._internal();

  final FlutterSecureStorage storage =
  const FlutterSecureStorage();

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
    final token = await storage.read(key: 'token');

    if (token != null) {
      dio.options.headers['Authorization'] =
      'Bearer $token';
    }
  }

  Future<void> saveToken(String token) async {
    await storage.write(
      key: 'token',
      value: token,
    );

    dio.options.headers['Authorization'] =
    'Bearer $token';
  }

  Future<void> removeToken() async {
    await storage.delete(key: 'token');

    dio.options.headers.remove('Authorization');
  }
}