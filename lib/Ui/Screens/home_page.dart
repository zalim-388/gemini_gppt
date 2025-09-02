// Updated HomePage with dark mode support
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gemini_gpt/Ui/Screens/drawer.dart';
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
  List<Map<String, String>> _messages = [];

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final inputMessage = _controller.text.trim();
    if (inputMessage.isEmpty) return;

    setState(() {
      _messages.add({'type': 'user', 'message': inputMessage});
    });

    BlocProvider.of<GeminiGptBloc>(
      context,
    ).add(FetchGeminiGpt(prompt: inputMessage));
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
      drawer: CustomDrawer(),
      body: Column(
        children: [
          Expanded(
            child: BlocListener<GeminiGptBloc, GeminiGptState>(
              listener: (context, state) {
                if (state is GeminiGptBlocLoaded) {
                  setState(() {
                    _messages.add({'type': 'bot', 'message': state.gemini.url});
                  });
                  _scrollToBottom();
                } else if (state is GeminiGptBlocError) {
                  setState(() {
                    _messages.add({
                      'type': 'error',
                      'message': 'Error: ${state.message}',
                    });
                  });
                  _scrollToBottom();
                }
              },
              child: BlocBuilder<GeminiGptBloc, GeminiGptState>(
                builder: (context, state) {
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
                          final isUser = message['type'] == 'user';
                          final isError = message['type'] == 'error';

                          return _buildMessageBubble(
                            message['message']!,
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
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color:
                    isUser
                        ? (isDarkMode
                            ? Colors.blue.shade700
                            : Colors.blue.shade100)
                        : (isDarkMode
                            ? Colors.grey.shade800
                            : Colors.grey.shade100),
                borderRadius: BorderRadius.circular(20.r),
              ),
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
                    fontSize: 16.sp,
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
                            ? (isDarkMode ? Colors.blue.shade700 : Colors.black)
                            : (_controller.text.trim().isEmpty
                                ? Colors.grey.shade400
                                : (isDarkMode
                                    ? Colors.blue.shade700
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
                              color: Colors.white,
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
