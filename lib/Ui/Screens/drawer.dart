// Updated CustomDrawer with dark mode support
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
  late Animation<double> _drawerAnimation;
  String _selectedChatId = '1';
  List<ChatConversation> _filteredConversations = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _drawerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _drawerAnimation = CurvedAnimation(
      parent: _drawerAnimationController,
      curve: Curves.easeInOut,
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
    super.dispose();
  }

  void _filterConversations() async {
    setState(() {
      if (_searchQuery.isEmpty) {
        _filteredConversations = widget.conversation;
      } else {
        _filteredConversations = ChatHistoryService.searchConversations(
          widget.conversation,
          _searchQuery,
        );
      }
    });
  }

  void _onSearchChange(String query) {
    _searchQuery = query;
    _filteredConversations;
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
    widget.onConversationDeleted(chatId);

    HapticFeedback.mediumImpact();
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
                    'Rename conversation',
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
                      ElevatedButton(
                        onPressed: () {
                          if (controller.text.trim().isNotEmpty) {
                            _renameChat(chat.id, controller.text.trim());
                            Navigator.pop(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              isDarkMode
                                  ? Colors.blue.shade700
                                  : Colors.black87,
                          foregroundColor: Colors.white,
                          elevation: 0,
                        ),
                        child: Text(
                          'Save',
                          style: GoogleFonts.poppins(
                            fontSize: 14.sp,
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
            SizedBox(height: 10.h),
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
      ),
    );
  }

  Widget _buildNewChatButton(bool isDarkMode) {
    return TextField(
      style: GoogleFonts.poppins(
        color: isDarkMode ? Colors.white : Colors.black,
        fontSize: 14.sp,
      ),
      decoration: InputDecoration(
        hintText: 'New chat',
        hintStyle: GoogleFonts.poppins(
          color:
              isDarkMode ? Colors.grey.shade400 : Colors.grey.withOpacity(0.8),
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
        ),
        prefixIcon: Icon(
          Icons.add,
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
      onTap: _createNewChat,
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
    return InkWell(
      onTap: () => _selectChat(chat.id),
      onLongPress: () => _showPopupMenu(chat, isDarkMode),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        child: Row(
          children: [
            Expanded(
              child: Text(
                chat.title,
                style: GoogleFonts.poppins(
                  color: isDarkMode ? Colors.white : Colors.black,
                  fontSize: 14.sp,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPopupMenu(ChatConversation chat, bool isDarkMode) {
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(100, 100, 0, 0),
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
          Icon(
            Icons.person_outlined,
            color: isDarkMode ? Colors.white : Colors.black,
            size: 20.sp,
          ),
          SizedBox(width: 8.w),
          Text(
            'User Account',
            style: GoogleFonts.poppins(
              color:
                  isDarkMode
                      ? Colors.white.withOpacity(0.9)
                      : Colors.black.withOpacity(0.9),
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: 4.w),
          Icon(
            Icons.keyboard_arrow_down,
            color: isDarkMode ? Colors.white : Colors.black,
            size: 14.sp,
          ),
        ],
      ),
    );
  }
}

// Updated Settings Page with Dark Mode Selection
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: GoogleFonts.poppins(
            color: theme.appBarTheme.foregroundColor,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: theme.appBarTheme.foregroundColor,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          children: [
            SizedBox(height: 16.h),
            _buildSettingItem(
              icon: Icons.person_outlined,
              title: "User Account",
              onTap: () {},
              isDarkMode: isDarkMode,
            ),
            SizedBox(height: 8.h),
            _buildSettingItem(
              icon: Icons.email_outlined,
              title: 'Email',
              onTap: () {},
              isDarkMode: isDarkMode,
            ),
            SizedBox(height: 8.h),
            _buildSettingItem(
              icon: Icons.bolt,
              title: "Upgrade to Pro",
              onTap: () {},
              isDarkMode: isDarkMode,
            ),
            SizedBox(height: 8.h),
            // Theme Selection Setting
            _buildThemeSettingItem(context, themeProvider, isDarkMode),
            SizedBox(height: 8.h),
            _buildSettingItem(
              icon: Icons.lock_outline,
              title: 'Privacy Policy',
              onTap: () {},
              isDarkMode: isDarkMode,
            ),
            SizedBox(height: 8.h),
            _buildSettingItem(
              icon: Icons.info_outline,
              title: 'About',
              onTap: () {},
              isDarkMode: isDarkMode,
            ),
            SizedBox(height: 8.h),
            _buildSettingItem(
              icon: Icons.logout,
              title: 'Log Out',
              onTap: () {},
              isDarkMode: isDarkMode,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeSettingItem(
    BuildContext context,
    ThemeProvider themeProvider,
    bool isDarkMode,
  ) {
    return Container(
      decoration: BoxDecoration(
        color:
            isDarkMode
                ? Colors.grey.withOpacity(0.2)
                : Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: ListTile(
        leading: Icon(
          Icons.wb_sunny_outlined,
          color: isDarkMode ? Colors.white : Colors.black,
          size: 20.sp,
        ),
        title: Text(
          'Color Scheme',
          style: GoogleFonts.poppins(
            color: isDarkMode ? Colors.white : Colors.black,
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
          ),
        ),

        trailing: Icon(
          Icons.chevron_right,
          color:
              isDarkMode ? Colors.grey.shade300 : Colors.grey.withOpacity(0.6),
          size: 18.sp,
        ),
        onTap:
            () => _showThemeSelectionDialog(context, themeProvider, isDarkMode),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      ),
    );
  }

  void _showThemeSelectionDialog(
    BuildContext context,
    ThemeProvider themeProvider,
    bool isDarkMode,
  ) {
    ThemeMode tempMode = themeProvider.themeMode; // store current mode

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: isDarkMode ? Colors.grey.shade900 : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              title: Text(
                'Color Scheme',
                style: GoogleFonts.poppins(
                  color: isDarkMode ? Colors.white : Colors.black,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildThemeOption(
                    context,
                    title: 'System (Default)',
                    themeMode: ThemeMode.system,
                    currentThemeMode: tempMode,
                    onChanged: (ThemeMode? value) {
                      if (value != null) {
                        setState(() => tempMode = value);
                      }
                    },
                    isDarkMode: isDarkMode,
                  ),

                  _buildThemeOption(
                    context,
                    title: 'Light',
                    themeMode: ThemeMode.light,
                    currentThemeMode: tempMode,
                    onChanged: (ThemeMode? value) {
                      if (value != null) {
                        setState(() => tempMode = value);
                      }
                    },
                    isDarkMode: isDarkMode,
                  ),
                  _buildThemeOption(
                    context,
                    title: 'Dark',
                    themeMode: ThemeMode.dark,
                    currentThemeMode: tempMode,
                    onChanged: (ThemeMode? value) {
                      if (value != null) {
                        setState(() => tempMode = value);
                      }
                    },
                    isDarkMode: isDarkMode,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    themeProvider.setThemeMode(tempMode);
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'OK',
                    style: GoogleFonts.poppins(
                      color: isDarkMode ? Colors.white : Colors.black,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildThemeOption(
    BuildContext context, {
    required String title,

    required ThemeMode themeMode,
    required ThemeMode currentThemeMode,
    required Function(ThemeMode?) onChanged,
    required bool isDarkMode,
  }) {
    return RadioListTile<ThemeMode>(
      title: Row(
        children: [
          SizedBox(width: 12.w),
          Text(
            title,
            style: GoogleFonts.poppins(
              color: isDarkMode ? Colors.white : Colors.black,
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      value: themeMode,
      groupValue: currentThemeMode,
      onChanged: onChanged,
      activeColor: isDarkMode ? Colors.white : Colors.black,
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required bool isDarkMode,
  }) {
    return Container(
      decoration: BoxDecoration(
        color:
            isDarkMode
                ? Colors.grey.withOpacity(0.2)
                : Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isDarkMode ? Colors.white : Colors.black,
          size: 20.sp,
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            color: isDarkMode ? Colors.white : Colors.black,
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color:
              isDarkMode ? Colors.grey.shade300 : Colors.grey.withOpacity(0.6),
          size: 18.sp,
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      ),
    );
  }
}
