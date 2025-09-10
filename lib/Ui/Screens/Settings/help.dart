import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gemini_gpt/Ui/Screens/Settings/About_page.dart';
import 'package:google_fonts/google_fonts.dart';

class HelpCenterPage extends StatelessWidget {
  const HelpCenterPage({Key? key}) : super(key: key);

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
          Icons.arrow_back_ios,
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
          'Help Center',
          style: GoogleFonts.poppins(
            color: theme.appBarTheme.foregroundColor,
            fontSize: 20.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHelpItem(
              context,
              'Frequently Asked Questions',
              'Find answers to common questions',
              Icons.quiz_outlined,
            ),
            SizedBox(height: 16.h),
            _buildHelpItem(
              context,
              'Contact Support',
              'Get help from our support team',
              Icons.support_agent_outlined,
            ),
            SizedBox(height: 16.h),
            _buildHelpItem(
              context,
              'User Guide',
              'Learn how to use the app',
              Icons.menu_book_outlined,
            ),
            SizedBox(height: 16.h),
            _buildHelpItem(
              context,
              'Report an Issue',
              'Report bugs or problems',
              Icons.bug_report_outlined,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpItem(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
  ) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      color: theme.cardColor,
      child: ListTile(
        leading: Icon(
          icon,
          color: theme.textTheme.bodyLarge?.color,
          size: 24.sp,
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            color: theme.textTheme.titleMedium?.color,
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.poppins(
            color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
            fontSize: 14.sp,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: theme.iconTheme.color?.withOpacity(0.6),
          size: 20.sp,
        ),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Opening $title...'),
              duration: const Duration(seconds: 2),
            ),
          );
        },
      ),
    );
  }
}
