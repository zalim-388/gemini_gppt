import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gemini_gpt/Ui/Screens/drawer.dart';
import 'package:gemini_gpt/Ui/Service/history_service.dart';
import 'package:gemini_gpt/bloc/GeminiGptBloc.dart';
import 'package:gemini_gpt/bloc/GeminiGptEvent.dart';
import 'package:gemini_gpt/bloc/GeminiGptState.dart';
import 'package:gemini_gpt/widgets/theme_mode.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<ChatConversation> _conversations = [];
  String? _activeConversationId;
  ChatConversation? _activeConversation;
  bool _isLodingHistory = true;

  @override
  void initState() {
    super.initState();
    _loadChatHistory();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadChatHistory() async {
    try {
      final conversations = await ChatHistoryService.loadConversations();
      final activeId = await ChatHistoryService.loadActiveConversationId();

      setState(() {
        _conversations = conversations;
        _activeConversationId = activeId ?? conversations.first.id;
        _activeConversation = conversations.firstWhere(
          (conv) => conv.id == _activeConversationId,
          orElse: () => conversations.first,
        );
        _isLodingHistory = false;
      });
    } catch (e) {
      print("Error loading chat history $e");
      setState(() {
        _isLodingHistory = false;
      });
    }
  }

  Future<void> createNewConversation() async {
    final newconversation = await ChatHistoryService.createNewConversation();
    setState(() {
      for (var conv in _conversations) {
        conv.isActive = false;
      }

      _conversations.insert(0, newconversation);
      _activeConversationId = newconversation.id;
      _activeConversation = newconversation;
    });
    await ChatHistoryService.saveConversations(_conversations);
    await ChatHistoryService.saveActiveConversationId(newconversation.id);
  }

  Future<void> swichConversation(String conversationId) async {
    setState(() {
      for (var conv in _conversations) {
        conv.isActive = conv.id == conversationId;
      }
      _activeConversationId = conversationId;
      _activeConversation = _conversations.firstWhere(
        (conv) => conv.id == conversationId,
      );
    });
    await ChatHistoryService.saveActiveConversationId(conversationId);
    await ChatHistoryService.saveConversations(_conversations);
  }

  Future<void> deleteConversation(String conversationId) async {
    await ChatHistoryService.deleteConversation(conversationId, _conversations);

    if (_activeConversationId == conversationId) {
      if (_conversations.isNotEmpty) {
        await swichConversation(_conversations.first.id);
      } else {
        await createNewConversation();
      }
    }
  }

  Future<void> renameConversation(
    String conversationId,
    String newTitle,
  ) async {
    await ChatHistoryService.updateConversationTitle(
      conversationId,
      newTitle,
      _conversations,
    );

    setState(() {
      final conversation = _conversations.firstWhere(
        (conv) => conv.id == conversationId,
      );
      conversation.title = newTitle;
    });
  }

  void _sendMessage() async {
    final inputMessage = _controller.text.trim();
    if (inputMessage.isEmpty || _activeConversation == null) return;

    // Check if this is the first message BEFORE adding the user message
    final isFirstMessage = _activeConversation!.messages.isEmpty;

    final userMessage = ChatMessage(
      id: 'Msg${DateTime.now().microsecondsSinceEpoch}_user',
      type: "user",
      message: inputMessage,
    );

    setState(() {
      _activeConversation?.messages.add(userMessage);
    });

    // Generate title only for the first message
    if (isFirstMessage) {
      final newTitle = ChatHistoryService.generateConversationTitle(
        inputMessage,
      );
      _activeConversation?.title = newTitle;
    }

    // Save the user message to conversation
    await ChatHistoryService.saveMessageToConversation(
      _activeConversation!.id,
      userMessage,
      _conversations,
    );

    BlocProvider.of<GeminiGptBloc>(
      context,
    ).add(FetchGeminiGpt(prompt: userMessage.message));

    _controller.clear();
    _scrollToBottom();
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
            onPressed: () {},
          ),
        ],
        elevation: 0,
      ),
      drawer: CustomDrawer(
        conversation: _conversations,
        activeConversationId: _activeConversationId,
        onConversationSelected: swichConversation,
        onConversationDeleted: deleteConversation,
        onConversationRenamed: renameConversation,
        onNewConversation: createNewConversation,
      ),
      body: Column(
        children: [
          Expanded(
            child: MultiBlocListener(
              listeners: [
                BlocListener<GeminiGptBloc, GeminiGptState>(
                  listener: (context, state) async {
                    if (state is GeminiGptBlocLoaded &&
                        _activeConversation != null) {
                      final botMessage = ChatMessage(
                        id: 'Msg${DateTime.now().microsecondsSinceEpoch}_bot',
                        type: 'bot',
                        message: state.gemini.url,
                      );
                      setState(() {
                        _activeConversation?.messages.add(botMessage);
                      });
                      await ChatHistoryService.saveMessageToConversation(
                        _activeConversation!.id,
                        botMessage,
                        _conversations,
                      );

                      _scrollToBottom();
                    } else if (state is GeminiGptBlocError) {
                      // Avoid duplicate error messages
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
                        );

                        setState(() {
                          _activeConversation?.messages.add(errorMessage);
                        });

                        await ChatHistoryService.saveMessageToConversation(
                          _activeConversation!.id,
                          errorMessage,
                          _conversations,
                        );

                        _scrollToBottom();
                      }
                    }
                  },
                ),
              ],
              child: BlocBuilder<GeminiGptBloc, GeminiGptState>(
                builder: (context, state) {
                  final _messages = _activeConversation?.messages ?? [];
                  return _messages.isEmpty
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
                            _messages.length +
                            (state is GeminiGptBlocLoading ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == _messages.length &&
                              state is GeminiGptBlocLoading) {
                            return _buildLoadingMessage(isDarkMode);
                          }

                          final message = _messages[index];
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
            onSubmitted: (_) => isLoading ? null : _sendMessage(),
            style: GoogleFonts.poppins(
              color: isDarkMode ? Colors.white : Colors.black,
              fontSize: 16.sp,
            ),
            decoration: InputDecoration(
              hintText: "Ask anything...",
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
                            : (_controller.text.trim().isEmpty
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
                              color: (isDarkMode ? Colors.black : Colors.white),
                              size: 20.sp,
                            ),
                    onPressed: isLoading ? null : _sendMessage,
                  ),
                ),
              ),
            ),
            onChanged: (value) {
              setState(() {});
            },
          );
        },
      ),
    );
  }
}
