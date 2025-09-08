// chat_history_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ChatMessage {
  final String id;
  final String type; // 'user', 'bot', 'error'
  final String message;

  ChatMessage({required this.id, required this.type, required this.message});

  Map<String, dynamic> toJson() {
    return {'id': id, 'type': type, 'message': message};
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      type: json['type'],
      message: json['message'],
    );
  }
}

class ChatConversation {
  final String id;
  String title;

  bool isActive;
  List<ChatMessage> messages;

  ChatConversation({
    required this.id,
    required this.title,

    required this.isActive,
    this.messages = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,

      'isActive': isActive,
      'messages': messages.map((msg) => msg.toJson()).toList(),
    };
  }

  factory ChatConversation.fromJson(Map<String, dynamic> json) {
    return ChatConversation(
      id: json['id'],
      title: json['title'],

      isActive: json['isActive'] ?? false,
      messages:
          (json['messages'] as List<dynamic>?)
              ?.map((msgJson) => ChatMessage.fromJson(msgJson))
              .toList() ??
          [],
    );
  }
}

class ChatHistoryService {
  static const String _conversationsKey = 'chat_conversations';
  static const String _activeConversationKey = 'active_conversation_id';

  static Future<void> saveConversations(
    List<ChatConversation> conversations,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final conversationsJson =
          conversations.map((conv) => conv.toJson()).toList();
      await prefs.setString(_conversationsKey, json.encode(conversationsJson));
    } catch (e) {
      print('Error saving conversations: $e');
    }
  }

  static Future<List<ChatConversation>> loadConversations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final conversationsString = prefs.getString(_conversationsKey);

      if (conversationsString == null) {
        return _getDefaultConversations();
      }

      final conversationsJson =
          json.decode(conversationsString) as List<dynamic>;
      return conversationsJson
          .map((convJson) => ChatConversation.fromJson(convJson))
          .toList();
    } catch (e) {
      print('Error loading conversations: $e');
      return _getDefaultConversations();
    }
  }

  static Future<void> saveActiveConversationId(String conversationId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_activeConversationKey, conversationId);
    } catch (e) {
      print('Error saving active conversation ID: $e');
    }
  }

  static Future<String?> loadActiveConversationId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_activeConversationKey);
    } catch (e) {
      print('Error loading active conversation ID: $e');
      return null;
    }
  }

  static Future<void> saveMessageToConversation(
    String conversationId,
    ChatMessage message,
    List<ChatConversation> conversations,
  ) async {
    try {
      final conversationIndex = conversations.indexWhere(
        (conv) => conv.id == conversationId,
      );
      if (conversationIndex != -1) {
        conversations[conversationIndex].messages.add(message);
        await saveConversations(conversations);
      }
    } catch (e) {
      print('Error saving message: $e');
    }
  }

  static ChatConversation createNewConversation({String? title}) {
    final now = DateTime.now();
    return ChatConversation(
      id: 'chat_${now.millisecondsSinceEpoch}',
      title: title ?? 'New Chat',

      isActive: true,
      messages: [],
    );
  }

  static Future<void> deleteConversation(
    String conversationId,
    List<ChatConversation> conversations,
  ) async {
    try {
      conversations.removeWhere((conv) => conv.id == conversationId);
      await saveConversations(conversations);
    } catch (e) {
      print('Error deleting conversation: $e');
    }
  }

  static Future<void> updateConversationTitle(
    String conversationId,
    String newTitle,
    List<ChatConversation> conversations,
  ) async {
    try {
      final conversationIndex = conversations.indexWhere(
        (conv) => conv.id == conversationId,
      );
      if (conversationIndex != -1) {
        conversations[conversationIndex].title = newTitle;
        await saveConversations(conversations);
      }
    } catch (e) {
      print('Error updating conversation title: $e');
    }
  }

  static Future<void> clearAllHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_conversationsKey);
      await prefs.remove(_activeConversationKey);
    } catch (e) {
      print('Error clearing history: $e');
    }
  }

  static String generateConversationTitle(String firstMessage) {
    if (firstMessage.length <= 30) {
      return firstMessage;
    }
    return '${firstMessage.substring(0, 27)}...';
  }

  static Future<String> exportChatHistory() async {
    try {
      final conversations = await loadConversations();
      return json.encode({
        'exported_at': DateTime.now().toIso8601String(),
        'conversations': conversations.map((conv) => conv.toJson()).toList(),
      });
    } catch (e) {
      print('Error exporting chat history: $e');
      return '';
    }
  }

  static Future<bool> importChatHistory(String jsonString) async {
    try {
      final data = json.decode(jsonString) as Map<String, dynamic>;
      final conversationsJson = data['conversations'] as List<dynamic>;
      final conversations =
          conversationsJson
              .map((convJson) => ChatConversation.fromJson(convJson))
              .toList();

      await saveConversations(conversations);
      return true;
    } catch (e) {
      print('Error importing chat history: $e');
      return false;
    }
  }

  static List<ChatConversation> _getDefaultConversations() {
    return [
      ChatConversation(
        id: 'default_1',
        title: 'Welcome Chat',

        isActive: true,
        messages: [],
      ),
    ];
  }

  // Search conversations by title or message content
  static List<ChatConversation> searchConversations(
    List<ChatConversation> conversations,
    String query,
  ) {
    if (query.isEmpty) return conversations;

    return conversations.where((conv) {
      if (conv.title.toLowerCase().contains(query.toLowerCase())) {
        return true;
      }

      return conv.messages.any(
        (msg) => msg.message.toLowerCase().contains(query.toLowerCase()),
      );
    }).toList();
  }

  static Map<String, dynamic> getConversationStats(
    List<ChatConversation> conversations,
  ) {
    int totalMessages = 0;
    int userMessages = 0;
    int botMessages = 0;

    for (var conv in conversations) {
      totalMessages += conv.messages.length;
      userMessages += conv.messages.where((msg) => msg.type == 'user').length;
      botMessages += conv.messages.where((msg) => msg.type == 'bot').length;
    }

    return {
      'total_conversations': conversations.length,
      'total_messages': totalMessages,
      'user_messages': userMessages,
      'bot_messages': botMessages,
      'average_messages_per_conversation':
          conversations.isNotEmpty ? totalMessages / conversations.length : 0,
    };
  }
}
