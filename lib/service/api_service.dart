import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _configuredBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
  );

  String get baseUrl {
    if (_configuredBaseUrl.isNotEmpty) {
      return _configuredBaseUrl;
    }

    if (kIsWeb) {
      return 'http://localhost:8000/api';
    }

    return defaultTargetPlatform == TargetPlatform.android
        ? 'http://10.0.2.2:8000/api'
        : 'http://localhost:8000/api';
  }

  final FlutterSecureStorage storage =
      const FlutterSecureStorage();

  // Get token from secure storage
  Future<String?> getToken() async {
    return await storage.read(key: 'token');
  }

  // Common headers
  Future<Map<String, String>> getHeaders({
    bool requiresAuth = false,
  }) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (requiresAuth) {
      final token = await getToken();

      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  // GET request
  Future<http.Response> get(
    String endpoint, {
    bool requiresAuth = false,
  }) async {
    final headers = await getHeaders(
      requiresAuth: requiresAuth,
    );

    return await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
    );
  }

  // POST request
  Future<http.Response> post(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requiresAuth = false,
  }) async {
    final headers = await getHeaders(
      requiresAuth: requiresAuth,
    );

    return await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: body != null ? jsonEncode(body) : null,
    );
  }

  // PUT request
  Future<http.Response> put(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requiresAuth = false,
  }) async {
    final headers = await getHeaders(
      requiresAuth: requiresAuth,
    );

    return await http.put(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: body != null ? jsonEncode(body) : null,
    );
  }

  // DELETE request
  Future<http.Response> delete(
    String endpoint, {
    bool requiresAuth = false,
  }) async {
    final headers = await getHeaders(
      requiresAuth: requiresAuth,
    );

    return await http.delete(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
    );
  }

  // Remove token
  Future<void> clearToken() async {
    await storage.delete(key: 'token');
  }
}
