import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gemini_gpt/Ui/Authentication/Login_screen.dart';
import 'package:gemini_gpt/Ui/Screens/Settings/About_page.dart';
import 'package:gemini_gpt/widgets/theme_mode.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

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
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => AboutPage()),
                );
              },
              isDarkMode: isDarkMode,
            ),
            SizedBox(height: 8.h),
            _buildSettingItem(
              icon: Icons.logout,

              title: 'Log Out',
              onTap: () {
                _showLogoutDialog(context, isDarkMode);
              },

              isLogout: true,
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
    return ListTile(
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

      onTap:
          () => _showThemeSelectionDialog(context, themeProvider, isDarkMode),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
    );
  }

  void _showThemeSelectionDialog(
    BuildContext context,
    ThemeProvider themeProvider,
    bool isDarkMode,
  ) {
    ThemeMode tempMode = themeProvider.themeMode;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: isDarkMode ? Colors.grey.shade900 : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24.r),
              ),
              title: Text(
                'Color Scheme',
                style: GoogleFonts.poppins(
                  color: isDarkMode ? Colors.white : Colors.black,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              content: Container(
                height: 150.h,
                width: 220.w,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
          SizedBox(width: 8.w),
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
    bool isLogout = false,
    required String title,
    required VoidCallback onTap,
    required bool isDarkMode,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color:
            isLogout
                ? (isDarkMode ? Colors.red.shade300 : Colors.red)
                : isDarkMode
                ? Colors.white
                : Colors.black,
        size: 20.sp,
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          color:
              isLogout
                  ? (isDarkMode ? Colors.red.shade300 : Colors.red)
                  : isDarkMode
                  ? Colors.white
                  : Colors.black,
          fontSize: 16.sp,
          fontWeight: FontWeight.w500,
        ),
      ),

      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
    );
  }
}

void _showLogoutDialog(BuildContext context, bool isDarkMode) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: isDarkMode ? Colors.grey.shade900 : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        elevation: 8,
        title: Row(
          children: [
            SizedBox(width: 5.w),
            Text(
              'Log Out',
              style: GoogleFonts.poppins(
                color: isDarkMode ? Colors.white : Colors.black,
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: SizedBox(
          height: 100.h,
          width: 100.h,
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Are you sure you\nwant to log out?',
                    style: GoogleFonts.poppins(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: isDarkMode ? Colors.white70 : Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'You will need to sign in \nagain to access your\naccount.',
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      color:
                          isDarkMode
                              ? Colors.grey.shade400
                              : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),

                    child: Icon(
                      Icons.cancel_outlined,
                      size: 20.sp,
                      color:
                          isDarkMode
                              ? Colors.grey.shade300
                              : Colors.grey.shade600,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      );
                    },

                    child: Icon(
                      Icons.logout,
                      size: 20.sp,
                      color: isDarkMode ? Colors.red.shade400 : Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}
