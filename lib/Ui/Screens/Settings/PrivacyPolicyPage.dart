
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gemini_gpt/Ui/Screens/Settings/About_page.dart';
import 'package:google_fonts/google_fonts.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: theme.appBarTheme.foregroundColor,
            size: 24.sp,
          ),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => AboutPage()),
            );
          },
        ),
        title: Text(
          'Privacy Policy',
          style: GoogleFonts.poppins(
            color: theme.appBarTheme.foregroundColor,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Privacy Policy',
              style: GoogleFonts.poppins(
                color: theme.textTheme.headlineSmall?.color,
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'Last updated: ${DateTime.now().toString().substring(0, 10)}',
              style: GoogleFonts.poppins(
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                fontSize: 14.sp,
                fontStyle: FontStyle.italic,
              ),
            ),
            SizedBox(height: 24.h),
            _buildSection(
              context,
              'Information We Collect',
              'We collect information you provide directly to us, such as when you create an account, use our services, or contact us for support.',
            ),
            _buildSection(
              context,
              'How We Use Your Information',
              'We use the information we collect to provide, maintain, and improve our services, process transactions, and communicate with you.',
            ),
            _buildSection(
              context,
              'Information Sharing',
              'We do not sell, trade, or otherwise transfer your personal information to third parties without your consent, except as described in this policy.',
            ),
            _buildSection(
              context,
              'Data Security',
              'We implement appropriate security measures to protect your personal information against unauthorized access, alteration, disclosure, or destruction.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String content) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              color: theme.textTheme.titleMedium?.color,
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            content,
            style: GoogleFonts.poppins(
              color: theme.textTheme.bodyMedium?.color,
              fontSize: 16.sp,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
