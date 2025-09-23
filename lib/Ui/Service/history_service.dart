import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class ChatMessage {
  final String id;
  final String type;
  final String message;
  final String conversationId;
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
      "conversation_id": conversationId,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: map['id'],
      type: map['type'],
      message: map['message'],
      conversationId: map['conversation_id'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
    );
  }
}


class ChatConversation {
  final String id;
  String title;
  bool isActive;
  final DateTime createdAt;
  final String userId;
  List<ChatMessage> messages;

  ChatConversation({
    required this.id,
    required this.title,
    required this.userId,
    this.isActive = false,
    DateTime? createdAt,
    List<ChatMessage>? messages,
  }) : createdAt = createdAt ?? DateTime.now(),
       messages = messages ?? [];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt.millisecondsSinceEpoch,
      'userid': userId,
    };
  }

  factory ChatConversation.fromMap(Map<String, dynamic> json) {
    return ChatConversation(
      id: json['id'],
      title: json['title'],
      userId: json['userid'],
      isActive: (json['is_active'] ?? 0) == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['created_at']),
      messages: [],
    );
  }
}


class ChatHistoryDBHelper {
  ChatHistoryDBHelper._();
  static final ChatHistoryDBHelper instance = ChatHistoryDBHelper._();
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
      mychatDB = await initDB();
      return mychatDB!;
    }
  }

  //initialize database
  Future<Database> initDB() async {
    Directory appDir = await getApplicationDocumentsDirectory();
    String dbpath = join(appDir.path, "chatDB.db");
    return await openDatabase(
      dbpath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
        CREATE TABLE $TABLE_CONVARSTION (
          $CONV_ID TEXT PRIMARY KEY,
          $CONV_TITLE TEXT,
          $CONV_MESSAGES TEXT,
          $CONV_USER_ID TEXT,
          $CONV_IS_ACTIVE INTEGER,
          $CONV_CREATED_AT INTEGER
        )
      ''');

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

  //conv......
  // Create new conversation
  Future<ChatConversation> createConversation({
    String? title,
    required String userId,
  }) async {
    final db = await getDB();
    final newConversation = ChatConversation(
      id: 'conv_${DateTime.now().millisecondsSinceEpoch}',
      title: 'New Chat',

      userId: userId,
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

  Future<bool> setActiveConversations({
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
        where: "$CONV_ID = ? AND $CONV_USER_ID = ?",
        whereArgs: [userid, ConverstionId],
      );
    });
    return true;
  }

  // upadte title
  Future<bool> updateConversationTitle({
    required String conversationid,
    required String newtitle,
  }) async {
    final db = await getDB();
    int rowsEffected = await db.update(
      TABLE_CONVARSTION,
      {CONV_TITLE: newtitle},
      where: '$CONV_ID=?',
      whereArgs: [conversationid],
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

  Future<List<ChatMessage>> getMessagetype({
    required String conversationId,
    required String type,
  }) async {
    try {
      final db = await getDB();
      List<Map<String, dynamic>> result = await db.query(
        TABLE_MESSAGES,
        where: '$MSG_CONVERSATION_ID = ? AND $MSG_TYPE = ?',
        whereArgs: [conversationId, type],
      );

      return result.map((map) => ChatMessage.fromMap(map)).toList();
    } catch (e) {
      print('Error getting messages type from database: $e');
      return [];
    }
  }


  //update message
  Future<bool> updatemessage({
    required String messageId,
    required String newMessage,
  }) async {
    final db = await getDB();
    int rowEffcted = await db.update(
      TABLE_MESSAGES,
      {MSG_MESSAGE: newMessage},

      where: '$MSG_ID=?',
      whereArgs: [messageId],
    );
    return rowEffcted > 0;
  }

  // delete mesg
  Future<bool> deleteUserConversation(String MessageId) async {
    final db = await getDB();
    int rowEffected = await db.delete(
      TABLE_MESSAGES,

      where: '$MSG_ID=?',
      whereArgs: [MessageId],
    );
    return rowEffected > 0;
  }

  Future<List<ChatConversation>> searchConversations({
    required String query,
    required String userId,
  }) async {
    final db = await getDB();
    final searchQuery = '%$query%';
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
    SELECT DISTINCT c.*
    FROM $TABLE_CONVARSTION c
    LEFT JOIN $TABLE_MESSAGES m ON c.$CONV_ID = m.$MSG_CONVERSATION_ID
    WHERE c.$CONV_USER_ID = ?
    AND (c.$CONV_TITLE LIKE ? OR m.$MSG_MESSAGE LIKE ?)
    ''',
      [userId, searchQuery, searchQuery],
    );
    return maps.map((m) => ChatConversation.fromMap(m)).toList();
  }

  String generateConversationTitle(String firstMessage) {
    if (firstMessage.length <= 30) {
      return firstMessage;
    }

    final sentences = firstMessage.split(RegExp(r'[.!?]+'));
    if (sentences.isNotEmpty && sentences.first.length <= 30) {
      return sentences.first.trim();
    }

    return '${firstMessage.substring(0, 27)}...';
  }

  Future<ChatConversation> CreateConverstionwithMessage({
    required String userId,
    required ChatMessage firstMessage,
    String? title,
  }) async {
    final db = await getDB();
    return await db.transaction((txn) async {
      final conversation = ChatConversation(
        id: firstMessage.conversationId,
        title: title ?? generateConversationTitle(firstMessage.message),
        userId: userId,
        isActive: true,
      );
      await txn.insert(TABLE_CONVARSTION, conversation.toMap());
      await txn.insert(TABLE_MESSAGES, firstMessage.toMap());

      return conversation;
    });
  }

  Future<Map<String, dynamic>?> getConverstionMessage(
    String ConverstionId,
  ) async {
    final db = await getDB();
    final convMap = await db.query(
      TABLE_CONVARSTION,
      where: '$CONV_ID =?',
      whereArgs: [ConverstionId],
      limit: 1,
    );
    if (convMap.isEmpty) return null;
    final conversation = ChatConversation.fromMap(convMap.first);
    final messages = await getConverstionMessage(ConverstionId);

    return {'conversation': conversation, 'messages': messages};
  }

  Future<void> clearUserData(String userId) async {
    final db = await getDB();

    await db.transaction((txn) async {
      // Get user conversations
      final conversations = await getUserConversation(userId);

      // Delete all messages for user conversations
      for (final conv in conversations) {
        await txn.delete(
          TABLE_MESSAGES,
          where: '$MSG_CONVERSATION_ID = ?',
          whereArgs: [conv.id],
        );
      }

      // Delete user conversations
      await txn.delete(
        TABLE_CONVARSTION,
        where: '$CONV_USER_ID = ?',
        whereArgs: [userId],
      );
    });
  }

  // Clear all data
  Future<void> clearAllData() async {
    final db = await getDB();

    await db.transaction((txn) async {
      await txn.delete(TABLE_MESSAGES);
      await txn.delete(TABLE_CONVARSTION);
    });
  }
}

//   Future<void> saveUserConversations(
//     String userId,
//     List<ChatConversation> conversations,
//   ) async {
//     final db = await getDB();

//     final userConversations =
//         conversations.where((conv) => conv.userId == userId).toList();
//     final conversationsJson = json.encode(
//       userConversations.map((conv) => conv.toJson()).toList(),
//     );
//     await prefs.setString(_getUserConversationsKey(userId), conversationsJson);
//   }

//   static Future<void> saveUserActiveConversationId(
//     String userId,
//     String conversationId,
//   ) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString(
//       _getUserActiveConversationKey(userId),
//       conversationId,
//     );
//   }

//   static Future<void> saveUserMessageToConversation(
//     String userId,
//     String conversationId,
//     ChatMessage message,
//     List<ChatConversation> conversations,
//   ) async {
//     final conversationIndex = conversations.indexWhere(
//       (conv) => conv.id == conversationId,
//     );
//     if (conversationIndex != -1) {
//       conversations[conversationIndex].messages.add(message);
//       await saveUserConversations(userId, conversations);
//     }
//   }

//   static Future<void> saveMessageToConversation(
//     String conversationId,
//     ChatMessage message,
//     List<ChatConversation> conversations,
//   ) async {
//     final conversationIndex = conversations.indexWhere(
//       (conv) => conv.id == conversationId,
//     );
//     if (conversationIndex != -1) {
//       conversations[conversationIndex].messages.add(message);
//       await saveConversations(conversations);
//     }
//   }

//   static Future<void> updateConversationTitle(
//     String conversationId,
//     String newTitle,
//     List<ChatConversation> conversations,
//   ) async {
//     final conversationIndex = conversations.indexWhere(
//       (conv) => conv.id == conversationId,
//     );
//     if (conversationIndex != -1) {
//       conversations[conversationIndex].title = newTitle;
//       await saveConversations(conversations);
//     }
//   }

//   // Migration method to convert legacy conversations to user-specific ones
//   static Future<void> migrateLegacyConversations(String userId) async {
//     try {
//       // Load legacy conversations
//       final legacyConversations = await loadConversations();
//       final legacyActiveId = await loadActiveConversationId();

//       if (legacyConversations.isNotEmpty) {
//         // Update conversations with user ID
//         final userConversations =
//             legacyConversations.map((conv) {
//               return ChatConversation(
//                 id: conv.id,
//                 title: conv.title,
//                 messages: conv.messages,
//                 userId: userId,
//                 isActive: conv.isActive,
//                 createdAt: conv.createdAt,
//               );
//             }).toList();

//         // Save as user-specific conversations
//         await saveUserConversations(userId, userConversations);
//         if (legacyActiveId != null) {
//           await saveUserActiveConversationId(userId, legacyActiveId);
//         }

//         // Clear legacy data
//         final prefs = await SharedPreferences.getInstance();
//         await prefs.remove(_conversationsKey);
//         await prefs.remove(_activeConversationKey);

//         print(
//           'Migrated ${userConversations.length} conversations to user-specific storage',
//         );
//       }
//     } catch (e) {
//       print('Error migrating legacy conversations: $e');
//     }
//   }
// }
