import 'dart:convert';

class ChatBubbleData {
  final String message;
  final bool isSender;
  final DateTime timestamp;

  ChatBubbleData({ required this.message, required this.isSender, required this.timestamp});

  factory ChatBubbleData.fromJson(Map<String, dynamic> json) {
    return ChatBubbleData(
      message: json['message'] ?? '',
      isSender: json['isSender'] ?? false,
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),

    );
  }


  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'isSender': isSender,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

class Conversation {
  final String id;
  final String userId;
  final List<ChatBubbleData> messages;

  Conversation({required this.id, required this.userId, required this.messages});

  factory Conversation.fromJson(Map<String, dynamic> json) {
    // Gère le cas où _id est un objet
    final id = json['_id'] is Map ? json['_id']['\$oid'] : json['_id'] ?? '';

    return Conversation(
      id: id,
      userId: json['user_id'] ?? '',
      messages: (json['messages'] as List? ?? [])
          .map((message) => ChatBubbleData.fromJson(message))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'user_id': userId,
      'messages': messages.map((message) => message.toJson()).toList(),
    };
  }
}

