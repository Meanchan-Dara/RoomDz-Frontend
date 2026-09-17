import 'dart:convert';

import 'package:roomdz_frontend/model/chatbot_models.dart';
import 'package:roomdz_frontend/service/api_service.dart';

class ChatbotService {
  final ApiService apiService;

  ChatbotService({ApiService? apiService})
    : apiService = apiService ?? ApiService();

  Future<ChatbotSuggestions> getSuggestions({String lang = 'en'}) async {
    final response = await apiService.post(
      '/chatbot/suggestions',
      body: {'lang': lang},
      requiresAuth: true,
    );

    final json = _decodeObject(response.body);
    if (!_isOk(response.statusCode) || json['success'] != true) {
      throw Exception(_errorMessage(json, 'Could not load suggestions.'));
    }

    return ChatbotSuggestions.fromJson(
      Map<String, dynamic>.from(json['data'] ?? const {}),
    );
  }

  Future<ChatbotReply> sendMessage({
    required String message,
    int? conversationId,
  }) async {
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

    final json = _decodeObject(response.body);
    if (!_isOk(response.statusCode) || json['success'] != true) {
      throw Exception(_errorMessage(json, 'Could not send message.'));
    }

    return ChatbotReply.fromJson(
      Map<String, dynamic>.from(json['data'] ?? const {}),
    );
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

  Map<String, dynamic> _decodeObject(String body) {
    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) return decoded;
    if (decoded is Map) return Map<String, dynamic>.from(decoded);
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
