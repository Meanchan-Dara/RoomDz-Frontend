import 'package:dio/dio.dart';
import 'package:roomdz_frontend/model/user_model.dart';
import 'api_client.dart'; // the Dio wrapper from before

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

      print('LOGIN STATUS: ${res.statusCode}');
      print('LOGIN RESPONSE: ${res.data}');

      await ApiClient.saveToken(res.data['token']);

      return UserModel.fromJson(res.data['user']);
    } on DioException catch (e) {
      print('LOGIN ERROR STATUS: ${e.response?.statusCode}');
      print('LOGIN ERROR DATA: ${e.response?.data}');
      print('LOGIN ERROR MESSAGE: ${e.message}');

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
        'name': name,
        'email': email,
        'password': password,
        'role': role,
        if (phone != null) 'phone': phone,
      },
    );
    await ApiClient.saveToken(res.data['token']);
    return UserModel.fromJson(res.data['user']);
  }

  Future<void> logout() async {
    try {
      await _dio.post('/logout');
    } finally {
      await ApiClient.clearToken();
    }
  }
}
