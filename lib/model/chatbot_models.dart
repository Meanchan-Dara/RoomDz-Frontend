class ChatbotSuggestions {
  final String welcomeMessage;
  final List<String> suggestions;

  const ChatbotSuggestions({
    required this.welcomeMessage,
    required this.suggestions,
  });

  factory ChatbotSuggestions.fromJson(Map<String, dynamic> json) {
    return ChatbotSuggestions(
      welcomeMessage: (json['welcome_message'] ?? '').toString(),
      suggestions: _stringList(json['suggestions']),
    );
  }
}

class ChatbotReply {
  final int? conversationId;
  final ChatbotMessage message;

  const ChatbotReply({required this.conversationId, required this.message});

  factory ChatbotReply.fromJson(Map<String, dynamic> json) {
    return ChatbotReply(
      conversationId: _intOrNull(json['conversation_id']),
      message: ChatbotMessage.fromJson(
        Map<String, dynamic>.from(json['message'] ?? const {}),
      ),
    );
  }
}

class ChatbotMessage {
  final int? id;
  final String role;
  final String content;
  final List<ChatbotRoom> rooms;
  final List<String> suggestions;
  final String intent;
  final DateTime? createdAt;

  const ChatbotMessage({
    this.id,
    required this.role,
    required this.content,
    this.rooms = const [],
    this.suggestions = const [],
    this.intent = 'general',
    this.createdAt,
  });

  factory ChatbotMessage.local({
    required String role,
    required String content,
  }) {
    return ChatbotMessage(
      role: role,
      content: content,
      createdAt: DateTime.now(),
    );
  }

  factory ChatbotMessage.fromJson(Map<String, dynamic> json) {
    return ChatbotMessage(
      id: _intOrNull(json['id']),
      role: (json['role'] ?? 'assistant').toString(),
      content: (json['content'] ?? '').toString(),
      rooms: _roomList(json['rooms']),
      suggestions: _stringList(json['suggestions']),
      intent: (json['intent'] ?? 'general').toString(),
      createdAt: DateTime.tryParse((json['created_at'] ?? '').toString()),
    );
  }
}

class ChatbotRoom {
  final int id;
  final String name;
  final String type;
  final double price;
  final String pricePeriod;
  final String address;
  final String? image;
  final double rating;
  final bool isAvailable;

  const ChatbotRoom({
    required this.id,
    required this.name,
    required this.type,
    required this.price,
    required this.pricePeriod,
    required this.address,
    this.image,
    required this.rating,
    required this.isAvailable,
  });

  factory ChatbotRoom.fromJson(Map<String, dynamic> json) {
    return ChatbotRoom(
      id: _intOrNull(json['id']) ?? 0,
      name: (json['name'] ?? 'Room').toString(),
      type: (json['type'] ?? '').toString(),
      price: _doubleOrZero(json['price']),
      pricePeriod: (json['price_period'] ?? 'month').toString(),
      address: (json['address'] ?? '').toString(),
      image: json['image']?.toString(),
      rating: _doubleOrZero(json['rating']),
      isAvailable: json['is_available'] != false,
    );
  }
}

List<String> _stringList(dynamic value) {
  if (value is! List) return const [];
  return value.map((item) => item.toString()).toList();
}

List<ChatbotRoom> _roomList(dynamic value) {
  if (value is! List) return const [];
  return value
      .whereType<Map>()
      .map((item) => ChatbotRoom.fromJson(Map<String, dynamic>.from(item)))
      .toList();
}

int? _intOrNull(dynamic value) {
  if (value is int) return value;
  return int.tryParse(value?.toString() ?? '');
}

double _doubleOrZero(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}
