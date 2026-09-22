import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:roomdz_frontend/features/chatbot/data/models/chatbot_model.dart';
import 'package:roomdz_frontend/core/network/api_service.dart';

class ChatbotService {
  final ApiService apiService;

  ChatbotService({ApiService? apiService})
    : apiService = apiService ?? ApiService();

  Future<ChatbotSuggestions> getSuggestions({String lang = 'en'}) async {
    try {
      final response = await apiService.post(
        '/chatbot/suggestions',
        body: {'lang': lang},
        requiresAuth: true,
      );

      final json = _decodeObject(response.data);
      if (!_isOk(response.statusCode ?? 0) || json['success'] != true) {
        throw Exception(_errorMessage(json, 'Could not load suggestions.'));
      }

      return ChatbotSuggestions.fromJson(
        Map<String, dynamic>.from(json['data'] ?? const {}),
      );
    } on DioException catch (e) {
      final data = e.response?.data;
      final json = _decodeObject(data);
      throw Exception(_errorMessage(json, e.message ?? 'Network error'));
    }
  }

  Future<ChatbotReply> sendMessage({
    required String message,
    int? conversationId,
  }) async {
    try {
      final body = <String, dynamic>{
        'message': message,
        'session_id': await _sessionId(),
      };

      if (conversationId != null) {
        body['conversation_id'] = conversationId;
      }

      final response = await apiService.post(
        '/chatbot/message',
        body: body,
        requiresAuth: true,
      );

      final json = _decodeObject(response.data);
      if (!_isOk(response.statusCode ?? 0) || json['success'] != true) {
        throw Exception(_errorMessage(json, 'Could not send message.'));
      }

      return ChatbotReply.fromJson(
        Map<String, dynamic>.from(json['data'] ?? const {}),
      );
    } on DioException catch (e) {
      final data = e.response?.data;
      final json = _decodeObject(data);
      throw Exception(_errorMessage(json, e.message ?? 'Network error'));
    }
  }

  Future<String> _sessionId() async {
    const key = 'chatbot_session_id';
    final saved = await apiService.storage.read(key: key);
    if (saved != null && saved.isNotEmpty) return saved;

    final generated =
        'guest_${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecond}';
    await apiService.storage.write(key: key, value: generated);
    return generated;
  }

  Future<void> resetSession() async {
    const key = 'chatbot_session_id';
    await apiService.storage.delete(key: key);
  }

  bool _isOk(int statusCode) => statusCode >= 200 && statusCode < 300;

  Map<String, dynamic> _decodeObject(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    if (data is String) {
      try {
        final decoded = jsonDecode(data);
        if (decoded is Map<String, dynamic>) return decoded;
        if (decoded is Map) return Map<String, dynamic>.from(decoded);
      } catch (_) {}
    }
    return const {};
  }

  String _errorMessage(Map<String, dynamic> json, String fallback) {
    final message = json['message'];
    if (message is String && message.isNotEmpty) return message;

    final errors = json['errors'];
    if (errors is Map && errors.isNotEmpty) {
      final first = errors.values.first;
      if (first is List && first.isNotEmpty) return first.first.toString();
      return first.toString();
    }

    return fallback;
  }
}
