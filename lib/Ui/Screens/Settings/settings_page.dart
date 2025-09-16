import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gemini_gpt/Ui/Authentication/Login_screen.dart';
import 'package:gemini_gpt/Ui/Screens/Settings/About_page.dart';
import 'package:gemini_gpt/Ui/Screens/Settings/Upgrade_to_Pro.dart';
import 'package:gemini_gpt/widgets/theme_mode.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
            Icons.arrow_back_ios,
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
            _builduser(isDarkMode, context),
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
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UpgradeToProPage()),
                );
              },
              isDarkMode: isDarkMode,
            ),
            SizedBox(height: 8.h),
            _buildThemeSettingItem(context, themeProvider, isDarkMode),

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
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
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
      title: Text(
        title,
        style: GoogleFonts.poppins(
          color: isDarkMode ? Colors.white : Colors.black,
          fontSize: 16.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
      value: themeMode,
      groupValue: currentThemeMode,
      onChanged: onChanged,
      activeColor: isDarkMode ? Colors.white : Colors.black,
      contentPadding: EdgeInsets.zero,
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
          width: double.maxFinite,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
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
                      'You will need to sign in again to access your account.',
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
              ),
              SizedBox(width: 10.w),
              Column(
                mainAxisSize: MainAxisSize.min,
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
                  SizedBox(height: 12.h),
                  TextButton(
                    onPressed: () async {
                      _logout(context);
                      // await FirebaseAuth.instance.signOut();
                      // Navigator.pushAndRemoveUntil(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => const LoginScreen(),
                      //   ),
                      //   (route) => false,
                      // );
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

Future<void> _logout(BuildContext context) async {
  try {
    await FirebaseAuth.instance.signOut();

    final GoogleSignIn googleSignIn = GoogleSignIn();
    try {
      await googleSignIn.disconnect();
    } catch (e) {
      debugPrint("Google disconnect error: $e");
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);

    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  } catch (e) {
    debugPrint("Logout error: $e");
  }
}

Widget _builduser(bool isDarkMode, BuildContext context) {
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
        SizedBox(width: 7.w),

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
      ],
    ),
  );
}
