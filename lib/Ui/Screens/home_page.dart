import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gemini_gpt/Ui/Screens/Settings/Upgrade_to_Pro.dart';
import 'package:gemini_gpt/Ui/Screens/drawer.dart';
import 'package:gemini_gpt/Ui/Service/history_service.dart';
import 'package:gemini_gpt/bloc/GeminiGptBloc.dart';
import 'package:gemini_gpt/bloc/GeminiGptEvent.dart';
import 'package:gemini_gpt/bloc/GeminiGptState.dart';
import 'package:gemini_gpt/widgets/theme_mode.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ChatHistoryDBHelper _chatDB = ChatHistoryDBHelper.instance;

  List<ChatConversation> _conversations = [];
  String? _activeConversationId;
  ChatConversation? _activeConversation;
  bool _isLoadingHistory = true;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
    if (_currentUser != null) {
      _loadChatHistory();
    } else {
      setState(() {
        _isLoadingHistory = false;
      });
    }

    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (mounted) {
        setState(() {
          _currentUser = user;
        });
        if (user != null) {
          _loadChatHistory();
        } else {
          setState(() {
            _conversations = [];
            _activeConversation = null;
            _activeConversationId = null;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadChatHistory() async {
    if (_currentUser == null) return;

    setState(() {
      _isLoadingHistory = true;
    });

    try {
      final conversations = await _chatDB.getUserConversation(
        _currentUser!.uid,
      );
      final activeConversation = await _chatDB.getActiveConversations(
        _currentUser!.uid,
      );

      setState(() {
        _conversations = conversations;
        _activeConversation = activeConversation;
        _activeConversationId = _activeConversationId;
        if (_activeConversation == null) {
          _loadmeasageActive();
        } else {
          _activeConversationId = null;
          _activeConversation = ChatConversation(
            id: DateTime.now().toString(),
            messages: [],
            title: '',
            userId: '',
          ); // Ensure empty messages
        }
        _isLoadingHistory = false;
      });
    } catch (e) {
      print("Error loading chat history: $e");
      setState(() {
        _isLoadingHistory = false;
      });
    }
  }
  //Load messages for the active conversation

  Future<void> _loadmeasageActive() async {
    if (_activeConversation == null) return;
    try {
      final message = await _chatDB.getAllMessage(_activeConversation!.id);

      setState(() {
        _activeConversation!.messages = message;
      });
    } catch (e) {
      print("Error loading messages: $e");
    }
  }

  Future<void> CreateNewConversation() async {
    if (_currentUser == null) return;

    final newConversation = await _chatDB.createConversation(
      userId: _currentUser!.uid,
      title: 'New title',
    );
    await _chatDB.setActiveConversations(
      ConverstionId: newConversation.id,
      userid: _currentUser!.uid,
    );

    setState(() {
      for (var conv in _conversations) {
        conv.isActive = false;
      }
      _conversations.insert(0, newConversation);
      _activeConversationId = newConversation.id;
      _activeConversation = newConversation;
      _activeConversation!.messages = [];
    });
  }

  Future<void> switchConversation(String conversationId) async {
    if (_currentUser == null) return;

    try {
      await _chatDB.setActiveConversations(
        userid: _currentUser!.uid,
        ConverstionId: conversationId,
      );
      //update ui
      final SelectConv = _conversations.firstWhere(
        (conv) => conv.id == conversationId,
      );
      final message = await _chatDB.getAllMessage(conversationId);
      SelectConv.messages = message;
      setState(() {
        _activeConversationId = _activeConversationId;
        _activeConversation = SelectConv;
      });
    } catch (e) {
      print("Error switching converstion :$e");
    }
  }

  Future<void> deleteConversation(String conversationId) async {
    if (_currentUser == null) return;

    try {
      await _chatDB.deleteConversation(conversationId);

      _conversations.removeWhere((conv) => conv.id == conversationId);

      if (_activeConversationId == conversationId) {
        if (_conversations.isNotEmpty) {
          await switchConversation(_conversations.first.id);
        } else {
          await CreateNewConversation();
        }
      }
      setState(() {});
    } catch (e) {
      print("Error delete conv: $e");
    }
  }

  Future<void> renameConversation(
    String conversationId,
    String newTitle,
  ) async {
    if (_currentUser == null) return;

    try {
      await _chatDB.updateConversationTitle(
        conversationid: conversationId,
        newtitle: newTitle,
      );

      setState(() {
        final conversation = _conversations.firstWhere(
          (conv) => conv.id == conversationId,
        );
        conversation.title = newTitle;
      });
    } catch (e) {
      print(" Error rename conv:$e");
    }
  }

  void _sendMessage(BuildContext context) async {
    if (_currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please log in to send messages"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final inputMessage = _controller.text.trim();
    if (inputMessage.isEmpty) return;

    if (_activeConversation == null) {
      await CreateNewConversation();
    }

    if (_activeConversation == null) return;

    final isFirstMessage = _activeConversation!.messages.isEmpty;

    final userMessage = ChatMessage(
      id: 'Msg${DateTime.now().microsecondsSinceEpoch}_user',
      type: "user",
      message: inputMessage,
      conversationId: _activeConversation!.id,
    );
    try {
      await _chatDB.addmessage(userMessage);
      setState(() {
        _activeConversation?.messages.add(userMessage);
      });

      if (isFirstMessage) {
        final newTitle = _chatDB.generateConversationTitle(inputMessage);
        _activeConversation?.title = newTitle;
        BlocProvider.of<GeminiGptBloc>(
          context,
        ).add(FetchGeminiGpt(prompt: userMessage.message));

        _controller.clear();
        _scrollToBottom();
      }
    } catch (e) {
      print("Error sending message: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error sending message: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final theme = Theme.of(context);

    if (_currentUser == null) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                "Please log in to continue",
                style: GoogleFonts.poppins(
                  fontSize: 16.sp,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Gemini GPT",
          style: GoogleFonts.poppins(
            color: theme.appBarTheme.foregroundColor,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        backgroundColor: theme.appBarTheme.backgroundColor,
        leading: Builder(
          builder:
              (context) => IconButton(
                icon: Icon(
                  Icons.menu,
                  color: theme.appBarTheme.foregroundColor,
                  size: 24.sp,
                ),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.bolt,
              color: theme.appBarTheme.foregroundColor,
              size: 24.sp,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UpgradeToProPage()),
              );
            },
          ),
        ],
        elevation: 0,
      ),
      drawer: CustomDrawer(
        conversation: _conversations,
        activeConversationId: _activeConversationId,
        onConversationSelected: switchConversation,
        onConversationDeleted: deleteConversation,
        onConversationRenamed: renameConversation,
        onNewConversation: CreateNewConversation,
      ),
      body: Column(
        children: [
          Expanded(
            child: MultiBlocListener(
              listeners: [
                BlocListener<GeminiGptBloc, GeminiGptState>(
                  listener: (context, state) async {
                    if (state is GeminiGptBlocLoaded &&
                        _activeConversation != null &&
                        _currentUser != null) {
                      final botMessage = ChatMessage(
                        id: 'Msg${DateTime.now().microsecondsSinceEpoch}_bot',
                        type: 'bot',
                        message: state.gemini.url,
                        conversationId: _activeConversation!.id,
                      );
                      try {
                        // Add to database
                        await _chatDB.addmessage(botMessage);

                        // Update UI
                        setState(() {
                          _activeConversation!.messages.add(botMessage);
                        });

                        _scrollToBottom();
                      } catch (e) {
                        print("Error saving bot message: $e");
                      }
                    } else if (state is GeminiGptBlocError) {
                      final lastMessage =
                          _activeConversation?.messages.isNotEmpty == true
                              ? _activeConversation!.messages.last
                              : null;

                      if (lastMessage == null ||
                          lastMessage.message != 'Error: ${state.message}') {
                        final errorMessage = ChatMessage(
                          id: 'Msg${DateTime.now().microsecondsSinceEpoch}_error',
                          type: "error",
                          message: 'Error: ${state.message}',
                          conversationId: _activeConversation!.id,
                        );
                        if (_activeConversation != null) {
                          try {
                            await _chatDB.addmessage(errorMessage);
                          } catch (e) {
                            print("Error saving error message: $e");
                          }
                        }
                      }
                    }
                  },
                ),
              ],
              child: BlocBuilder<GeminiGptBloc, GeminiGptState>(
                builder: (context, state) {
                  if (_isLoadingHistory) {
                    return Center(child: CircularProgressIndicator());
                  }

                  final messages = _activeConversation?.messages ?? [];
                  return messages.isEmpty
                      ? Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "What can I help with?",
                                style: GoogleFonts.poppins(
                                  fontSize: 18.sp,
                                  color:
                                      isDarkMode
                                          ? Colors.grey[300]
                                          : Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                "Chat with Gemini GPT",
                                style: GoogleFonts.poppins(
                                  fontSize: 16.sp,
                                  color:
                                      isDarkMode
                                          ? Colors.grey[400]
                                          : Colors.grey[600],
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      : ListView.builder(
                        controller: _scrollController,
                        padding: EdgeInsets.all(16.w),
                        itemCount:
                            messages.length +
                            (state is GeminiGptBlocLoading ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == messages.length &&
                              state is GeminiGptBlocLoading) {
                            return _buildLoadingMessage(isDarkMode);
                          }
                          final message = messages[index];
                          final isUser = message.type == 'user';
                          final isError = message.type == 'error';
                          return _buildMessageBubble(
                            message.message,
                            isUser,
                            isError,
                            isDarkMode,
                          );
                        },
                      );
                },
              ),
            ),
          ),
          SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: _buildInputField(isDarkMode),
            ),
          ),
          SizedBox(height: 30.h),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(
    String message,
    bool isUser,
    bool isError,
    bool isDarkMode,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) SizedBox(width: 4.w),
          Flexible(
            child: Text(
              message,
              style: TextStyle(
                color:
                    isUser
                        ? (isDarkMode ? Colors.white : Colors.black87)
                        : isError
                        ? (isDarkMode
                            ? Colors.red.shade300
                            : Colors.red.shade800)
                        : (isDarkMode ? Colors.white : Colors.black87),
                fontSize: 16.sp,
              ),
            ),
          ),
          if (isUser) SizedBox(width: 4.w),
        ],
      ),
    );
  }

  Widget _buildLoadingMessage(bool isDarkMode) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 20.w,
                  height: 20.h,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Text(
                  "Thinking...",
                  style: GoogleFonts.poppins(
                    color: isDarkMode ? Colors.white70 : Colors.black54,
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(bool isDarkMode) {
    return SafeArea(
      child: BlocBuilder<GeminiGptBloc, GeminiGptState>(
        builder: (context, state) {
          final isLoading = state is GeminiGptBlocLoading;
          return TextField(
            controller: _controller,
            maxLines: null,
            textInputAction: TextInputAction.send,
            onSubmitted: (_) => isLoading ? null : _sendMessage(context),
            style: GoogleFonts.poppins(
              color: isDarkMode ? Colors.white : Colors.black,
              fontSize: 16.sp,
            ),
            decoration: InputDecoration(
              hintText:
                  _currentUser != null
                      ? "Ask anything..."
                      : "Please log in to chat",
              hintStyle: GoogleFonts.poppins(
                color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                fontSize: 16.sp,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25.r),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25.r),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25.r),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor:
                  isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 22.w,
                vertical: 12.h,
              ),
              suffixIcon: Padding(
                padding: EdgeInsets.all(4.0),
                child: Container(
                  decoration: BoxDecoration(
                    color:
                        isLoading
                            ? (isDarkMode ? Colors.grey.shade700 : Colors.black)
                            : (_controller.text.trim().isEmpty ||
                                    _currentUser == null
                                ? Colors.grey.shade400
                                : (isDarkMode
                                    ? Colors.white
                                    : Colors.grey.shade700)),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon:
                        isLoading
                            ? SizedBox(
                              width: 20.w,
                              height: 20.h,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                            : Icon(
                              Icons.arrow_upward,
                              color: isDarkMode ? Colors.black : Colors.white,
                              size: 20.sp,
                            ),
                    onPressed:
                        isLoading || _currentUser == null
                            ? null
                            : () => _sendMessage(context),
                  ),
                ),
              ),
            ),
            onChanged: (value) {
              setState(() {});
            },
            enabled: _currentUser != null,
          );
        },
      ),
    );
  }
}
