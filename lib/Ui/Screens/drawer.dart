// Fixed CustomDrawer with proper history deletion and popup menu
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gemini_gpt/Ui/Screens/Settings/settings_page.dart';
import 'package:gemini_gpt/Ui/Service/history_service.dart';
import 'package:gemini_gpt/widgets/theme_mode.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class CustomDrawer extends StatefulWidget {
  final List<ChatConversation> conversation;
  final String? activeConversationId;
  final Function(String) onConversationSelected;
  final Function(String) onConversationDeleted;
  final Function(String, String) onConversationRenamed;
  final VoidCallback onNewConversation;

  const CustomDrawer({
    super.key,
    required this.conversation,
    required this.activeConversationId,
    required this.onConversationSelected,
    required this.onConversationDeleted,
    required this.onConversationRenamed,
    required this.onNewConversation,
  });

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer>
    with TickerProviderStateMixin {
  late AnimationController _drawerAnimationController;
  final TextEditingController _searchController = TextEditingController();
  final ChatHistoryDBHelper _chatDB=ChatHistoryDBHelper.instance;

  List<ChatConversation> _filteredConversations = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _drawerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _filteredConversations = widget.conversation;
  }

  @override
  void didUpdateWidget(CustomDrawer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.conversation != widget.conversation) {
      _filterConversations();
    }
  }

  @override
  void dispose() {
    _drawerAnimationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _filterConversations() {
    final userId=FirebaseAuth.instance.currentUser!.uid;
    setState(() async {
      if (_searchQuery.isEmpty) {
        _filteredConversations = widget.conversation;
      } else {
        _filteredConversations =  await _chatDB.searchConversations(query:  _searchQuery, 
        userId:userId,
       
        );
      }
    });
  }

  void _onSearchChange(String query) {
    setState(() {
      _searchQuery = query;
    });
    _filterConversations();
  }

  void _selectChat(String chatId) {
    widget.onConversationSelected(chatId);
    Navigator.of(context).pop();
  }

  void _createNewChat() {
    widget.onNewConversation();
    Navigator.of(context).pop();
    HapticFeedback.lightImpact();
  }

  void _deleteChat(String chatId) {
    _showDeleteConfirmDialog(chatId);
  }

  void _showDeleteConfirmDialog(String chatId) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDarkMode = themeProvider.isDarkMode;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: isDarkMode ? Colors.grey.shade900 : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          title: Text(
            'Delete Conversation',
            style: GoogleFonts.poppins(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          content: Text(
            'Are you sure you want to delete this conversation? This action cannot be undone.',
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              color: isDarkMode ? Colors.white70 : Colors.black87,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color:
                      isDarkMode ? Colors.grey.shade300 : Colors.grey.shade600,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                widget.onConversationDeleted(chatId);
                HapticFeedback.mediumImpact();
              },
              child: Text(
                'Delete',
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  color: Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _renameChat(String chatId, String newTitle) {
    widget.onConversationRenamed(chatId, newTitle);
  }


  void _showRenameDialog(ChatConversation chat) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDarkMode = themeProvider.isDarkMode;

    TextEditingController controller = TextEditingController(text: chat.title);

    showDialog(
      context: context,
      barrierDismissible: true,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            elevation: 8,
            backgroundColor: isDarkMode ? Colors.grey.shade900 : Colors.white,
            child: Container(
              width: 400.w,
              padding: EdgeInsets.all(24.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Rename Conversation',
                    style: GoogleFonts.poppins(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color:
                            isDarkMode
                                ? Colors.grey.shade700
                                : Colors.grey.withOpacity(0.3),
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: TextField(
                      controller: controller,
                      autofocus: true,
                      maxLines: null,
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 12.h,
                        ),
                        hintText: 'Enter conversation name',
                        hintStyle: GoogleFonts.poppins(
                          fontSize: 14.sp,
                          color:
                              isDarkMode
                                  ? Colors.grey.shade400
                                  : Colors.grey.withOpacity(0.6),
                        ),
                      ),
                      onSubmitted: (value) {
                        if (value.trim().isNotEmpty) {
                          _renameChat(chat.id, value.trim());
                          Navigator.pop(context);
                        }
                      },
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'Cancel',
                          style: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color:
                                isDarkMode
                                    ? Colors.grey.shade300
                                    : Colors.grey.withOpacity(0.8),
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      TextButton(
                        onPressed: () {
                          if (controller.text.trim().isNotEmpty) {
                            _renameChat(chat.id, controller.text.trim());
                            Navigator.pop(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(),
                        child: Text(
                          'Save',
                          style: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            color:
                                isDarkMode
                                    ? Colors.grey.shade300
                                    : Colors.grey.withOpacity(0.8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Container(
      width: 250.w,
      height: double.infinity,
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 30.h),
            _buildDrawerHeader(isDarkMode),
            SizedBox(height: 10.h),
            _buildSearchBar(isDarkMode),
            SizedBox(height: 10.h),
            _buildNewChatButton(isDarkMode),
            SizedBox(height: 5.h),
            _buildChatsText(isDarkMode),
            Expanded(child: _buildConversationsList(isDarkMode)),
            SizedBox(height: 10.h),
            _buildDrawerFooter(isDarkMode),
            SizedBox(height: 25.h),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerHeader(bool isDarkMode) {
    return Padding(
      padding: EdgeInsets.only(left: 50.w),
      child: Row(
        children: [
          Text(
            'Gemini GPT',
            style: GoogleFonts.poppins(
              color: isDarkMode ? Colors.white : Colors.black,
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatsText(bool isDarkMode) {
    return Text(
      "Chats",
      style: GoogleFonts.poppins(
        color: isDarkMode ? Colors.white : Colors.black,
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildNewChatButton(bool isDarkMode) {
    return GestureDetector(
      onTap: _createNewChat,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color:
              isDarkMode
                  ? Colors.grey.withOpacity(0.2)
                  : Colors.grey.withOpacity(0.05),
          borderRadius: BorderRadius.circular(25.r),
        ),
        child: Row(
          children: [
            Icon(
              Icons.add,
              color:
                  isDarkMode
                      ? Colors.grey.shade400
                      : Colors.grey.withOpacity(0.6),
              size: 18.sp,
            ),
            SizedBox(width: 8.w),
            Text(
              'New chat',
              style: GoogleFonts.poppins(
                color:
                    isDarkMode
                        ? Colors.grey.shade400
                        : Colors.grey.withOpacity(0.8),
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(bool isDarkMode) {
    return TextField(
      controller: _searchController,
      onChanged: _onSearchChange,
      style: GoogleFonts.poppins(
        color: isDarkMode ? Colors.white : Colors.black,
        fontSize: 14.sp,
      ),
      decoration: InputDecoration(
        hintText: 'Search conversations...',
        hintStyle: GoogleFonts.poppins(
          color:
              isDarkMode ? Colors.grey.shade400 : Colors.grey.withOpacity(0.8),
          fontSize: 14.sp,
        ),
        prefixIcon: Icon(
          Icons.search,
          color:
              isDarkMode ? Colors.grey.shade400 : Colors.grey.withOpacity(0.6),
          size: 18.sp,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25.r),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25.r),
          borderSide: BorderSide.none,
        ),
        fillColor:
            isDarkMode
                ? Colors.grey.withOpacity(0.2)
                : Colors.grey.withOpacity(0.05),
        filled: true,
      ),
    );
  }

  Widget _buildConversationsList(bool isDarkMode) {
    if (_filteredConversations.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Text(
            _searchQuery.isEmpty
                ? 'No conversations yet.\nStart a new chat!'
                : 'No conversations found.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
              fontSize: 14.sp,
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: _filteredConversations.length,
      padding: EdgeInsets.zero,
      itemBuilder: (context, index) {
        final chat = _filteredConversations[index];
        return _buildConversationItem(chat, isDarkMode);
      },
    );
  }

  Widget _buildConversationItem(ChatConversation chat, bool isDarkMode) {
    final isActive = chat.id == widget.activeConversationId;

    return ListTile(
      onTap: () => _selectChat(chat.id),
      title: GestureDetector(
        onLongPressStart: (details) {
          _showPopupMenu(details.globalPosition, chat, isDarkMode);
        },
        child: Text(
          chat.title,
          style: GoogleFonts.poppins(
            color: isDarkMode ? Colors.white : Colors.black,
            fontSize: 14.sp,
            fontWeight: isActive ? FontWeight.w500 : FontWeight.w400,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  void _showPopupMenu(
    Offset tapPosition,
    ChatConversation chat,
    bool isDarkMode,
  ) {
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        tapPosition.dx,
        tapPosition.dy,
        tapPosition.dx,
        tapPosition.dy,
      ),
      items: [
        PopupMenuItem(
          value: 'rename',
          child: Row(
            children: [
              Icon(
                Icons.edit,
                size: 16.sp,
                color:
                    isDarkMode ? Colors.white70 : Colors.black.withOpacity(0.8),
              ),
              SizedBox(width: 8.w),
              Text(
                'Rename',
                style: GoogleFonts.poppins(
                  color:
                      isDarkMode
                          ? Colors.white70
                          : Colors.black.withOpacity(0.8),
                  fontSize: 14.sp,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(
                Icons.delete,
                size: 16.sp,
                color: isDarkMode ? Colors.red.shade300 : Colors.red,
              ),
              SizedBox(width: 8.w),
              Text(
                'Delete',
                style: GoogleFonts.poppins(
                  color: isDarkMode ? Colors.red.shade300 : Colors.red,
                  fontSize: 14.sp,
                ),
              ),
            ],
          ),
        ),
      ],
      color: isDarkMode ? Colors.grey.shade900 : Colors.white,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
    ).then((value) {
      if (value == 'delete') {
        _deleteChat(chat.id);
      } else if (value == 'rename') {
        _showRenameDialog(chat);
      }
    });
  }

  Widget _buildDrawerFooter(bool isDarkMode) {
    final User? user = FirebaseAuth.instance.currentUser;
    final String displayName = user?.displayName ?? user?.email ?? "Guest User";
    final String firstLetter =
        displayName.isNotEmpty ? displayName[0].toUpperCase() : "U";

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => SettingsPage()),
        );
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 16.r,
            backgroundColor: isDarkMode ? Colors.white30 : Colors.black,

            child: Text(
              firstLetter,
              style: TextStyle(color: Colors.white, fontSize: 16.sp),
            ),
          ),
          SizedBox(width: 10.w),

          // User Name / Email
          Expanded(
            child: Text(
              displayName,
              style: GoogleFonts.poppins(
                color:
                    isDarkMode
                        ? Colors.white.withOpacity(0.9)
                        : Colors.black.withOpacity(0.9),
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          Icon(
            Icons.keyboard_arrow_down,
            color: isDarkMode ? Colors.white : Colors.black,
            size: 20.sp,
          ),
        ],
      ),
    );
  }
}
