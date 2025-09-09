import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gemini_gpt/Ui/Screens/Settings/About_page.dart';

import 'package:google_fonts/google_fonts.dart';

class TermsOfUsePage extends StatelessWidget {
  const TermsOfUsePage({Key? key}) : super(key: key);

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
          'Terms of Use',
          style: GoogleFonts.poppins(
            color: theme.appBarTheme.foregroundColor,
            fontSize: 20.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Terms of Use',
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
              '1. Acceptance of Terms',
              'By using Gemini GPT, you agree to be bound by these terms of use. If you do not agree to these terms, please do not use the application.',
            ),
            _buildSection(
              context,
              '2. Use License',
              'Permission is granted to temporarily use Gemini GPT for personal, non-commercial transitory viewing only.',
            ),
            _buildSection(
              context,
              '3. Privacy Policy',
              'Your privacy is important to us. Please review our Privacy Policy to understand our practices.',
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
