import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer>
    with TickerProviderStateMixin {
  late AnimationController _drawerAnimationController;
  late Animation<double> _drawerAnimation;

  String _selectedChatId = '1';

  final List<ChatConversation> _conversations = [
    ChatConversation(
      id: '1',
      title: 'Flutter Development Tips',

      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      isActive: true,
    ),
    ChatConversation(
      id: '2',
      title: 'API Integration Guide',

      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      isActive: true,
    ),
    ChatConversation(
      id: '3',
      title: 'State Management',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      isActive: false,
    ),
    ChatConversation(
      id: '4',
      title: 'UI/UX Design Principles',

      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      isActive: false,
    ),
    ChatConversation(
      id: '5',
      title: 'Database Integration',

      timestamp: DateTime.now().subtract(const Duration(days: 3)),
      isActive: false,
    ),
    ChatConversation(
      id: '6',

      title: 'SQLite vs Hive performance',
      timestamp: DateTime.now().subtract(const Duration(days: 3)),
      isActive: false,
    ),
    ChatConversation(
      id: '7',

      title: 'SQLite vs Hive performance,',
      timestamp: DateTime.now().subtract(const Duration(days: 3)),
      isActive: false,
    ),
    ChatConversation(
      id: '8',

      title: 'Material Design guidelines',
      timestamp: DateTime.now().subtract(const Duration(days: 3)),
      isActive: false,
    ),
    ChatConversation(
      id: '9',

      title: 'Provider vs BLoC comparison',

      timestamp: DateTime.now().subtract(const Duration(days: 3)),
      isActive: false,
    ),
    ChatConversation(
      id: '10',

      title: 'Provider vs BLoC comparison',

      timestamp: DateTime.now().subtract(const Duration(days: 3)),
      isActive: false,
    ),
  ];

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
  }

  @override
  void dispose() {
    _drawerAnimationController.dispose();
    super.dispose();
  }

  void _selectChat(String chatId) {
    setState(() {
      _selectedChatId = chatId;

      for (var chat in _conversations) {
        chat.isActive = chat.id == chatId;
      }
    });

    Navigator.of(context).pop();
  }

  void _createNewChat() {
    setState(() {
      Navigator.of(context).pop();
    });
    HapticFeedback.lightImpact();
  }

  void _deleteChat(String chatId) {
    setState(() {
      _conversations.removeWhere((chat) => chat.id == chatId);
      if (_selectedChatId == chatId && _conversations.isNotEmpty) {
        _selectedChatId = _conversations.first.id;
        _conversations.first.isActive = true;
      }
    });
    HapticFeedback.mediumImpact();
  }

  void _renameChat(String chatId, String newTitle) {
    setState(() {
      final chat = _conversations.firstWhere((chat) => chat.id == chatId);
      chat.title = newTitle;
    });
  }

  // Show rename dialog - ChatGPT style
  void _showRenameDialog(ChatConversation chat) {
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
            backgroundColor: Colors.white,
            child: Container(
              width: 400.w,
              padding: EdgeInsets.all(24.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    'Rename conversation',
                    style: GoogleFonts.poppins(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // Input field
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey.withOpacity(0.3),
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
                        color: Colors.black87,
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
                          color: Colors.grey.withOpacity(0.6),
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

                  // Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Cancel button
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 8.h,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.withOpacity(0.8),
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),

                      // Save button
                      ElevatedButton(
                        onPressed: () {
                          if (controller.text.trim().isNotEmpty) {
                            _renameChat(chat.id, controller.text.trim());
                            Navigator.pop(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black87,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 8.h,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6.r),
                          ),
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
    return Container(
      width: 250.w,
      height: double.infinity,
      decoration: BoxDecoration(color: Colors.white),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 30.h),
            _buildDrawerHeader(),
            SizedBox(height: 10.h),
            _buildSearchBar(),
            SizedBox(height: 10.h),
            _buildNewChatButton(),

            SizedBox(height: 5.h),
            text(),
            Expanded(child: _buildConversationsList()),
            SizedBox(height: 10.h),
            _buildDrawerFooter(),
            SizedBox(height: 10.h),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerHeader() {
    return Padding(
      padding: EdgeInsets.only(left: 50.w),
      child: Row(
        children: [
          Text(
            'Gemini GPT',
            style: GoogleFonts.poppins(
              color: Colors.black,
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget text() {
    return Text(
      "Chats",
      style: GoogleFonts.poppins(color: Colors.black, fontSize: 14.sp),
    );
  }

  Widget _buildNewChatButton() {
    return InkWell(
      onTap: _createNewChat,
      child: TextField(
        style: GoogleFonts.poppins(color: Colors.black, fontSize: 14.sp),
        decoration: InputDecoration(
          hintText: 'New chat',
          hintStyle: GoogleFonts.poppins(
            color: Colors.grey.withOpacity(0.8),
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Icon(
            Icons.add,
            color: Colors.grey.withOpacity(0.6),
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
          // contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
          fillColor: Colors.grey.withOpacity(0.05),
          filled: true,
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      style: GoogleFonts.poppins(color: Colors.black, fontSize: 14.sp),
      decoration: InputDecoration(
        hintText: 'Search conversations...',
        hintStyle: GoogleFonts.poppins(
          color: Colors.grey.withOpacity(0.8),
          fontSize: 14.sp,
        ),
        prefixIcon: Icon(
          Icons.search,
          color: Colors.grey.withOpacity(0.6),
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
        // contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
        fillColor: Colors.grey.withOpacity(0.05),
        filled: true,
      ),
    );
  }

  Widget _buildConversationsList() {
    return ListView.builder(
      itemCount: _conversations.length,
      padding: EdgeInsets.zero,
      itemBuilder: (context, index) {
        final chat = _conversations[index];
        return _buildConversationItem(chat);
      },
    );
  }

  Widget _buildConversationItem(ChatConversation chat) {
    return Container(
      child: InkWell(
        onTap: () => _selectChat(chat.id),
        onLongPress: () => _buildPopup(chat),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 10.h),
          child: Row(
            children: [
              Text(
                chat.title,
                style: GoogleFonts.poppins(
                  color: Colors.black,
                  fontSize: 14.sp,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPopup(ChatConversation chat) {
    return PopupMenuButton<String>(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      icon: Icon(
        Icons.more_vert,
        color: Colors.grey.withOpacity(0.6),
        size: 16.sp,
      ),
      onSelected: (value) {
        if (value == 'delete') {
          _deleteChat(chat.id);
        } else if (value == 'rename') {
          _showRenameDialog(chat);
        }
      },
      itemBuilder:
          (context) => [
            _buildPopupMenuItem(
              title: "Rename",
              icon: Icons.edit,
              value: "rename",
            ),
            _buildPopupMenuItem(
              title: "Delete",
              icon: Icons.delete,
              value: "delete",
            ),
          ],
    );
  }

  PopupMenuEntry<String> _buildPopupMenuItem({
    required String title,
    required IconData icon,
    required String value,
  }) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 16.sp, color: Colors.black.withOpacity(0.8)),
          SizedBox(width: 8.w),
          Text(
            title,
            style: GoogleFonts.poppins(
              color: Colors.black.withOpacity(0.8),
              fontSize: 14.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerFooter() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => buildSettingsPage(context)),
        );
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.person_outlined, color: Colors.black, size: 20.sp),
          SizedBox(width: 8.w),
          Text(
            'User Account',
            style: GoogleFonts.poppins(
              color: Colors.black.withOpacity(0.9),
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: 4.w),
          Icon(Icons.keyboard_arrow_down, color: Colors.black, size: 14.sp),
        ],
      ),
    );
  }
}

class ChatConversation {
  final String id;
  String title;

  final DateTime timestamp;
  bool isActive;

  ChatConversation({
    required this.id,
    required this.title,

    required this.timestamp,
    required this.isActive,
  });
}

Widget buildSettingsPage(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text(
        'Settings',
        style: GoogleFonts.poppins(
          color: Colors.black,
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.of(context).pop(),
      ),
    ),
    backgroundColor: Colors.white,
    body: Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        children: [
          SizedBox(height: 16.h),
          _buildSettingItem(
            icon: Icons.person_outlined,
            title: "User Account",
            onTap: () {},
          ),
          SizedBox(height: 8.h),
          _buildSettingItem(
            icon: Icons.email_outlined,
            title: 'Email',
            onTap: () {},
          ),
          SizedBox(height: 8.h),
          _buildSettingItem(
            icon: Icons.bolt,
            title: "Upgrade to Pro",
            onTap: () {},
          ),
          SizedBox(height: 8.h),
          _buildSettingItem(
            icon: Icons.wb_sunny_outlined,
            title: 'Color Scheme',
            onTap: () {},
          ),
          SizedBox(height: 8.h),
          _buildSettingItem(
            icon: Icons.lock_outline,
            title: 'Privacy Policy',
            onTap: () {},
          ),
          SizedBox(height: 8.h),
          _buildSettingItem(
            icon: Icons.info_outline,
            title: 'About',
            onTap: () {},
          ),
          SizedBox(height: 8.h),
          _buildSettingItem(icon: Icons.logout, title: 'Log Out', onTap: () {}),
        ],
      ),
    ),
  );
}

Widget _buildSettingItem({
  required IconData icon,
  required String title,
  required VoidCallback onTap,
}) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.grey.withOpacity(0.05),
      borderRadius: BorderRadius.circular(8.r),
    ),
    child: ListTile(
      leading: Icon(icon, color: Colors.black, size: 20.sp),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          color: Colors.black,
          fontSize: 16.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: Colors.grey.withOpacity(0.6),
        size: 18.sp,
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
    ),
  );
}
