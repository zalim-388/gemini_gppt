import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ChatMessage {
  final String id;
  final String type;
  final String message;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.type,
    required this.message,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      type: json['type'],
      message: json['message'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

class ChatConversation {
  final String id;
  String title;
  final List<ChatMessage> messages;
  bool isActive;
  final DateTime createdAt;
  final String userId; // Add userId to track conversation owner

  ChatConversation({
    required this.id,
    required this.title,
    required this.messages,
    required this.userId,
    this.isActive = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'messages': messages.map((msg) => msg.toJson()).toList(),
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'userId': userId,
    };
  }

  factory ChatConversation.fromJson(Map<String, dynamic> json) {
    return ChatConversation(
      id: json['id'],
      title: json['title'],
      userId: json['userId'],
      messages: (json['messages'] as List<dynamic>)
          .map((msgJson) => ChatMessage.fromJson(msgJson))
          .toList(),
      isActive: json['isActive'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class ChatHistoryService {
  static const String _conversationsKey = 'chat_conversations';
  static const String _activeConversationKey = 'active_conversation_id';

  // User-specific keys
  static String _getUserConversationsKey(String userId) => 'user_${userId}_conversations';
  static String _getUserActiveConversationKey(String userId) => 'user_${userId}_active_conversation';

  // Legacy methods (keep for backward compatibility)
  static Future<List<ChatConversation>> loadConversations() async {
    final prefs = await SharedPreferences.getInstance();
    final conversationsJson = prefs.getString(_conversationsKey);
    
    if (conversationsJson == null) {
      return [];
    }
    
    try {
      final List<dynamic> decodedData = json.decode(conversationsJson);
      return decodedData
          .map((convJson) => ChatConversation.fromJson(convJson))
          .toList();
    } catch (e) {
      print('Error loading conversations: $e');
      return [];
    }
  }

  static Future<String?> loadActiveConversationId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_activeConversationKey);
  }

  static Future<void> saveConversations(List<ChatConversation> conversations) async {
    final prefs = await SharedPreferences.getInstance();
    final conversationsJson = json.encode(
      conversations.map((conv) => conv.toJson()).toList(),
    );
    await prefs.setString(_conversationsKey, conversationsJson);
  }

  static Future<void> saveActiveConversationId(String conversationId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_activeConversationKey, conversationId);
  }

  // NEW: User-specific methods
  static Future<List<ChatConversation>> loadUserConversations(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final conversationsJson = prefs.getString(_getUserConversationsKey(userId));
    
    if (conversationsJson == null) {
      return [];
    }
    
    try {
      final List<dynamic> decodedData = json.decode(conversationsJson);
      return decodedData
          .map((convJson) => ChatConversation.fromJson(convJson))
          .where((conv) => conv.userId == userId) // Extra safety check
          .toList();
    } catch (e) {
      print('Error loading user conversations: $e');
      return [];
    }
  }

  static Future<String?> loadUserActiveConversationId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_getUserActiveConversationKey(userId));
  }

  static Future<void> saveUserConversations(String userId, List<ChatConversation> conversations) async {
    final prefs = await SharedPreferences.getInstance();
    // Filter conversations to only include those belonging to this user
    final userConversations = conversations.where((conv) => conv.userId == userId).toList();
    final conversationsJson = json.encode(
      userConversations.map((conv) => conv.toJson()).toList(),
    );
    await prefs.setString(_getUserConversationsKey(userId), conversationsJson);
  }

  static Future<void> saveUserActiveConversationId(String userId, String conversationId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_getUserActiveConversationKey(userId), conversationId);
  }

  static Future<ChatConversation> createNewUserConversation(String userId) async {
    final newConversation = ChatConversation(
      id: 'conv_${DateTime.now().millisecondsSinceEpoch}',
      title: 'New Chat',
      messages: [],
      userId: userId,
      isActive: true,
    );
    return newConversation;
  }

  static Future<ChatConversation> createNewConversation() async {
    final newConversation = ChatConversation(
      id: 'conv_${DateTime.now().millisecondsSinceEpoch}',
      title: 'New Chat',
      messages: [],
      userId: 'legacy', // For backward compatibility
      isActive: true,
    );
    return newConversation;
  }

  static Future<void> saveUserMessageToConversation(
    String userId,
    String conversationId,
    ChatMessage message,
    List<ChatConversation> conversations,
  ) async {
    final conversationIndex = conversations.indexWhere((conv) => conv.id == conversationId);
    if (conversationIndex != -1) {
      conversations[conversationIndex].messages.add(message);
      await saveUserConversations(userId, conversations);
    }
  }

  static Future<void> saveMessageToConversation(
    String conversationId,
    ChatMessage message,
    List<ChatConversation> conversations,
  ) async {
    final conversationIndex = conversations.indexWhere((conv) => conv.id == conversationId);
    if (conversationIndex != -1) {
      conversations[conversationIndex].messages.add(message);
      await saveConversations(conversations);
    }
  }

  static Future<void> deleteUserConversation(
    String userId,
    String conversationId,
    List<ChatConversation> conversations,
  ) async {
    conversations.removeWhere((conv) => conv.id == conversationId && conv.userId == userId);
    await saveUserConversations(userId, conversations);
  }

  static Future<void> deleteConversation(
    String conversationId,
    List<ChatConversation> conversations,
  ) async {
    conversations.removeWhere((conv) => conv.id == conversationId);
    await saveConversations(conversations);
  }

  static Future<void> updateUserConversationTitle(
    String userId,
    String conversationId,
    String newTitle,
    List<ChatConversation> conversations,
  ) async {
    final conversationIndex = conversations.indexWhere(
      (conv) => conv.id == conversationId && conv.userId == userId,
    );
    if (conversationIndex != -1) {
      conversations[conversationIndex].title = newTitle;
      await saveUserConversations(userId, conversations);
    }
  }

  static Future<void> updateConversationTitle(
    String conversationId,
    String newTitle,
    List<ChatConversation> conversations,
  ) async {
    final conversationIndex = conversations.indexWhere((conv) => conv.id == conversationId);
    if (conversationIndex != -1) {
      conversations[conversationIndex].title = newTitle;
      await saveConversations(conversations);
    }
  }

  static List<ChatConversation> searchConversations(
    List<ChatConversation> conversations,
    String query,
  ) {
    final lowerQuery = query.toLowerCase();
    return conversations.where((conv) {
      return conv.title.toLowerCase().contains(lowerQuery) ||
          conv.messages.any((msg) => msg.message.toLowerCase().contains(lowerQuery));
    }).toList();
  }

  static String generateConversationTitle(String firstMessage) {
    if (firstMessage.length <= 30) {
      return firstMessage;
    }
    
    // Find the first sentence or take first 30 characters
    final sentences = firstMessage.split(RegExp(r'[.!?]+'));
    if (sentences.isNotEmpty && sentences.first.length <= 30) {
      return sentences.first.trim();
    }
    
    return '${firstMessage.substring(0, 27)}...';
  }

  // Clear all user data (useful for logout)
  static Future<void> clearUserData(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_getUserConversationsKey(userId));
    await prefs.remove(_getUserActiveConversationKey(userId));
  }

  // Clear all data (useful for app reset)
  static Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    final chatKeys = keys.where((key) => 
      key.startsWith('user_') || 
      key == _conversationsKey || 
      key == _activeConversationKey
    ).toList();
    
    for (String key in chatKeys) {
      await prefs.remove(key);
    }
  }

  // Migration method to convert legacy conversations to user-specific ones
  static Future<void> migrateLegacyConversations(String userId) async {
    try {
      // Load legacy conversations
      final legacyConversations = await loadConversations();
      final legacyActiveId = await loadActiveConversationId();
      
      if (legacyConversations.isNotEmpty) {
        // Update conversations with user ID
        final userConversations = legacyConversations.map((conv) {
          return ChatConversation(
            id: conv.id,
            title: conv.title,
            messages: conv.messages,
            userId: userId,
            isActive: conv.isActive,
            createdAt: conv.createdAt,
          );
        }).toList();
        
        // Save as user-specific conversations
        await saveUserConversations(userId, userConversations);
        if (legacyActiveId != null) {
          await saveUserActiveConversationId(userId, legacyActiveId);
        }
        
        // Clear legacy data
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(_conversationsKey);
        await prefs.remove(_activeConversationKey);
        
        print('Migrated ${userConversations.length} conversations to user-specific storage');
      }
    } catch (e) {
      print('Error migrating legacy conversations: $e');
    }
  }
}