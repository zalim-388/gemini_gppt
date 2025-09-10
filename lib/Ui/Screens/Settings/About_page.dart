import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gemini_gpt/Ui/Screens/Settings/PrivacyPolicyPage.dart';
import 'package:gemini_gpt/Ui/Screens/Settings/help.dart';
import 'package:gemini_gpt/Ui/Screens/Settings/settings_page.dart';
import 'package:gemini_gpt/Ui/Screens/Settings/terms_of_use.dart';
import 'package:gemini_gpt/widgets/theme_mode.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
           Icons.arrow_back_ios,
            color: theme.appBarTheme.foregroundColor,
            size: 24.sp,
          ),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => SettingsPage()),
            );
          },
        ),
        title: Text(
          'About',
          style: GoogleFonts.poppins(
            color: theme.appBarTheme.foregroundColor,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          children: [
            SizedBox(height: 16.h),
            _buildMenuItem(
              context,
              icon: Icons.help_outline,
              title: 'Help Center',
              isDarkMode: isDarkMode,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HelpCenterPage()),
                );
              },
            ),
            SizedBox(height: 8.h),
            _buildMenuItem(
              context,
              icon: Icons.description_outlined,
              title: 'Terms of Use',
              isDarkMode: isDarkMode,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TermsOfUsePage()),
                );
              },
            ),
            SizedBox(height: 8.h),

            _buildMenuItem(
              context,
              icon: Icons.security_outlined,
              title: 'Privacy Policy',
              isDarkMode: isDarkMode,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PrivacyPolicyPage()),
                );
              },
            ),
            SizedBox(height: 8.h),

            _buildMenuItem(
              context,
              icon: Icons.library_books_outlined,
              title: 'Licenses',
              onTap: () => _navigateToLicenses(context),
              isDarkMode: isDarkMode,
            ),
            SizedBox(height: 8.h),
            _buildVersionInfo(context),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required bool isDarkMode,
  }) {
    return ListTile(
      onTap: onTap,

      leading: Icon(
        icon,
        color: isDarkMode ? Colors.white : Colors.black,
        size: 24.sp,
      ),

      title: Text(
        title,
        style: GoogleFonts.poppins(
          color: isDarkMode ? Colors.white : Colors.black,
          fontSize: 16.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildVersionInfo(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.circle_outlined,
            color: theme.textTheme.bodyLarge?.color,
            size: 30.sp,
          ),
          SizedBox(width: 15.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Gemini GPT for Android',
                style: GoogleFonts.poppins(
                  color: theme.textTheme.bodyLarge?.color,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                '1.2025.231 (13)',
                style: GoogleFonts.poppins(
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                  fontSize: 14.sp,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _navigateToLicenses(BuildContext context) {
    showLicensePage(
      context: context,
      applicationName: 'Gemini GPT',
      applicationVersion: '1.2025.231 (13)',
      applicationLegalese: '© 2025 Gemini GPT. All rights reserved.',
    );
  }
}
