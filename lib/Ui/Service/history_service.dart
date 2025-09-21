import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

class ChatMessage {
  final String id;
  final String type;
  final String message;
  final conversationId;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.type,
    required this.message,
    required this.conversationId,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'message': message,
      "conversation_Id": conversationId,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory ChatMessage.fromMap(Map<String, dynamic> Map) {
    return ChatMessage(
      id: Map['id'],
      type: Map['type'],
      message: Map['message'],
      conversationId: Map['conversation_Id'],
      timestamp: DateTime.parse(Map['timestamp']),
    );
  }
}

class ChatConversation {
  final String id;
  String title;
  bool isActive;
  final List<ChatMessage> messages;
  final DateTime createdAt;
  final String userId;

  ChatConversation({
    required this.id,
    required this.title,
    required this.messages,
    required this.userId,
    this.isActive = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'isActive': isActive,
      'messages': messages.map((msg) => msg.toMap()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'userId': userId,
    };
  }

  factory ChatConversation.fromMap(Map<String, dynamic> json) {
    return ChatConversation(
      id: json['id'],
      title: json['title'],
      userId: json['userId'],
      messages:
          (json['messages'] as List<dynamic>)
              .map((msgJson) => ChatMessage.fromMap(msgJson))
              .toList(),
      isActive: json['isActive'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class ChatDBHelper {
  ChatDBHelper._();
  static final ChatDBHelper instance = ChatDBHelper._();
  //DATA BASE TABLE
  static const String TABLE_CONVARSTION = "Converstion";
  static const String TABLE_MESSAGES = "messages";

  static const String CONV_ID = 'id';
  static const String CONV_TITLE = 'title';
  static const String CONV_MESSAGES = 'messages';
  static const String CONV_USER_ID = "userid";
  static const String CONV_IS_ACTIVE = "is_active";
  static const String CONV_CREATED_AT = "created_at";

  static const String MSG_ID = "id";
  static const String MSG_TYPE = "type";
  static const String MSG_MESSAGE = "message";
  static const String MSG_CONVERSATION_ID = "conversation_id";
  static const String MSG_TIMESTAMP = "timestamp";

  Database? mychatDB;

  Future<Database> getDB() async {
    if (mychatDB != null) {
      return mychatDB!;
    } else {
      mychatDB = await openchatDB();
      return mychatDB!;
    }
  }

  //initialize database
  Future<Database> openchatDB() async {
    Directory appDir = await getApplicationDocumentsDirectory();
    String dbpath = join(appDir.path, "chatDB.db");
    return await openDatabase(
      dbpath,
      version: 1,

      onCreate: (db, version) async {
        await db.execute(
          "CREATE TABLE$TABLE_CONVARSTION("
          "$CONV_ID TEXT PRIMARY KEY,"
          "$CONV_TITLE TEXT,"
          "$CONV_MESSAGES TEXT,"
          "$CONV_USER_ID TEXT,"
          "$CONV_IS_ACTIVE INTEGER,"
          "$CONV_CREATED_AT TEXT)",
        );

        await db.execute('''
          CREATE TABLE $TABLE_MESSAGES (
            $MSG_ID TEXT PRIMARY KEY,
            $MSG_TYPE TEXT NOT NULL,
            $MSG_MESSAGE TEXT NOT NULL,
            $MSG_CONVERSATION_ID TEXT NOT NULL,
            $MSG_TIMESTAMP INTEGER NOT NULL,
            FOREIGN KEY ($MSG_CONVERSATION_ID) REFERENCES $TABLE_CONVARSTION ($CONV_ID) ON DELETE CASCADE
          )
        ''');

        print("Chat history database initialized");
      },
    );
  }


  //   Future<bool> updateUserConversationTitle({
  //     required int userId,
  //     required String newTitle,
  //     required List<ChatConversation> conversations,
  //   }) async {
  // var db =await getchatDB();
  // int rowsEffected= await db.update(TABLE_CHAT_HISTORY, {
  //   COLUMN_MESSAGE: newTitle})

  //   }

  //conv......
  // Create new conversation
  Future<ChatConversation> createConversation({
    String? title,
    required String userid,
  }) async {
    final db = await getDB();
    final newConversation = ChatConversation(
      id: 'conv_${DateTime.now().millisecondsSinceEpoch}',
      title: 'New Chat',
      messages: [],
      userId: userid,
      isActive: false,
    );
    await db.insert(TABLE_CONVARSTION, newConversation.toMap());
    return newConversation;
  }

  // get All converstion for user
  Future<List<ChatConversation>> getUserConversation(String userId) async {
    final db = await getDB();

    final List<Map<String, dynamic>> maps = await db.query(
      TABLE_CONVARSTION,
      where: "$CONV_USER_ID=?",
      whereArgs: [userId],
    );

    return maps.map((m) => ChatConversation.fromMap(m)).toList();
  }
  // get Active

  Future<ChatConversation?> getActiveConversations(String userid) async {
    final db = await getDB();

    final List<Map<String, dynamic>> maps = await db.query(
      TABLE_CONVARSTION,
      where: "$CONV_USER_ID=? AND $CONV_IS_ACTIVE =?",
      whereArgs: [userid, 1],
    );
    if (maps.isNotEmpty) {
      return ChatConversation.fromMap(maps.first);
    }
    return null;
  }

  Future<bool> setsaveConversations({
    required String userid,
    required String ConverstionId,
  }) async {
    final db = await getDB();
    await db.transaction((txn) async {
      await txn.update(
        TABLE_CONVARSTION,
        {CONV_IS_ACTIVE: 0},
        where: "$CONV_USER_ID =?",
        whereArgs: [userid],
      );

      await txn.update(
        TABLE_CONVARSTION,
        {CONV_IS_ACTIVE: 1},
        where: "$CONV_USER_ID=? AND $CONV_IS_ACTIVE=?",
        whereArgs: [userid, ConverstionId],
      );
    });
    return true;
  }

  // upadte title
  Future<bool> updateConversationTitle(
    String conversationId,
    String newTitle,
  ) async {
    final db = await getDB();
    int rowsEffected = await db.update(
      TABLE_CONVARSTION,
      {CONV_TITLE: newTitle},
      where: '$CONV_ID=?',
      whereArgs: [conversationId],
    );
    return rowsEffected > 0;
  }

  Future<bool> deleteConversation(String conversationId) async {
    final db = await getDB();
    await db.transaction((txn) async {
      await txn.delete(
        TABLE_MESSAGES,
        where: '$MSG_CONVERSATION_ID=?',
        whereArgs: [conversationId],
      );
      await txn.delete(
        TABLE_CONVARSTION,
        where: '$CONV_ID=?',
        whereArgs: [conversationId],
      );
    });
    return true;
  }

  //add message
  Future<bool> addmessage(ChatMessage message) async {
    try {
      final db = await getDB();
      await db.insert(TABLE_MESSAGES, message.toMap());
      return true;
    } catch (e) {
      print('Error adding message to database: $e');
      return false;
    }
  }

  Future<List<ChatMessage>> getAllMessage(String conversationId) async {
    try {
      final db = await getDB();
      List<Map<String, dynamic>> result = await db.query(
        TABLE_MESSAGES,
        where: '$MSG_CONVERSATION_ID = ?',
        whereArgs: [conversationId],
      );
      return result.map((map) => ChatMessage.fromMap(map)).toList();
    } catch (e) {
      print('Error getting messages from database: $e');
      return [];
    }
  }

    Future<List<ChatMessage>> getAllMessagetype(String type) async {
      try {
        final db = await getDB();
        List<Map<String, dynamic>> result = await db.query(
          TABLE_MESSAGES,
          where: '$MSG_MESSAGE = ?',
          whereArgs: [type],
        );

        return result.map((map) => ChatMessage.fromJson(map)).toList();
      } catch (e) {
        print('Error getting messages type from database: $e');
        return [];
      }
    }


  Future<void> saveUserConversations(
    String userId,
    List<ChatConversation> conversations,
  ) async {
    final db = await getDB();

    final userConversations =
        conversations.where((conv) => conv.userId == userId).toList();
    final conversationsJson = json.encode(
      userConversations.map((conv) => conv.toJson()).toList(),
    );
    await prefs.setString(_getUserConversationsKey(userId), conversationsJson);
  }

  static Future<void> saveUserActiveConversationId(
    String userId,
    String conversationId,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _getUserActiveConversationKey(userId),
      conversationId,
    );
  }

  static Future<void> saveUserMessageToConversation(
    String userId,
    String conversationId,
    ChatMessage message,
    List<ChatConversation> conversations,
  ) async {
    final conversationIndex = conversations.indexWhere(
      (conv) => conv.id == conversationId,
    );
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
    final conversationIndex = conversations.indexWhere(
      (conv) => conv.id == conversationId,
    );
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
    conversations.removeWhere(
      (conv) => conv.id == conversationId && conv.userId == userId,
    );
    await saveUserConversations(userId, conversations);
  }

  static Future<void> updateUserConversationTitlee(
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
    final conversationIndex = conversations.indexWhere(
      (conv) => conv.id == conversationId,
    );
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
          conv.messages.any(
            (msg) => msg.message.toLowerCase().contains(lowerQuery),
          );
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
    final chatKeys =
        keys
            .where(
              (key) =>
                  key.startsWith('user_') ||
                  key == _conversationsKey ||
                  key == _activeConversationKey,
            )
            .toList();

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
        final userConversations =
            legacyConversations.map((conv) {
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

        print(
          'Migrated ${userConversations.length} conversations to user-specific storage',
        );
      }
    } catch (e) {
      print('Error migrating legacy conversations: $e');
    }
  }
}
